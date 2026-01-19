# Module 2: Memory & Context

**Duration:** 30 minutes  
**Prerequisites:** Completed Module 1

---

## 🎯 Learning Objectives

- Understand different memory types and their trade-offs
- Implement conversation memory in n8n agents
- Manage token limits with window memory
- Learn context management best practices

---

## Lecture: Understanding Memory Types

### The Memory Problem

LLMs are **stateless** by default. Each request is independent - the model doesn't remember previous interactions.

```
Without Memory:
User: "My name is Michael"
AI: "Nice to meet you, Michael!"

User: "What's my name?"
AI: "I don't have access to that information."  ← Problem!
```

### Memory Architecture in n8n

```
┌───────────────────────────────────────────────────────────┐
│                      Memory System                        │
├───────────────────────────────────────────────────────────┤
│                                                           │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────────┐  │
│  │   Buffer    │   │   Window    │   │    Summary      │  │
│  │   Memory    │   │   Memory    │   │    Memory       │  │
│  │             │   │             │   │                 │  │
│  │ All history │   │ Last N msgs │   │ Compressed      │  │
│  │             │   │             │   │ summaries       │  │
│  └─────────────┘   └─────────────┘   └─────────────────┘  │
│        │                  │                   │           │
│        └──────────────────┼───────────────────┘           │
│                           ▼                               │
│                  ┌─────────────────┐                      │
│                  │  Context Window │                      │
│                  │   (LLM Input)   │                      │
│                  └─────────────────┘                      │
│                                                           │
└───────────────────────────────────────────────────────────┘
```

### Memory Type Comparison

| Memory Type | How it Works                 | Pros               | Cons               |
|-------------|------------------------------|--------------------|--------------------|
| **Buffer**  | Stores all messages verbatim | Complete history   | Token limit issues |
| **Window**  | Keeps last N messages        | Predictable tokens | Loses old context  |
| **Summary** | Compresses old messages      | Unlimited history  | Loses details      |
| **Vector**  | Semantic retrieval           | Relevant context   | Complex setup      |

### Understanding Token Limits

Every LLM has a **context window** - the maximum tokens it can process:

| Model       | Context Window | ~Words   |
|-------------|----------------|----------|
| GPT-4o      | 128K tokens    | ~96,000  |
| Claude 3.5  | 200K tokens    | ~150,000 |
| GPT-4o-mini | 128K tokens    | ~96,000  |

**Token estimation:** ~1 token ≈ 0.75 words (English)

### The Context Budget

```
┌─────────────────────────────────────────┐
│           Context Window (128K)         │
├─────────────────────────────────────────┤
│  System Prompt      │    ~500 tokens    │
│  Conversation Memory│  ~4,000 tokens    │
│  RAG Context        │  ~8,000 tokens    │
│  Current Message    │    ~200 tokens    │
│  ─────────────────────────────────────  │
│  Response Budget    │  ~4,000 tokens    │
│  ─────────────────────────────────────  │
│  REMAINING          │  ~111,300 tokens  │
└─────────────────────────────────────────┘
```

---

## Lab 2.1: Conversation Memory

**Goal:** Add persistent conversation memory to an agent.

### Step 1: Create Workflow

1. Create new workflow: `Lab 2.1 - Conversation Memory`
2. Add **Chat Trigger**

### Step 2: Add AI Agent with Memory

1. Add **AI Agent** node
2. Connect to Chat Trigger
3. Configure:
   - **Agent Type:** `Tools Agent`
   - **System Message:**
   ```
   You are a helpful assistant that remembers user information.
   When users share personal details, acknowledge and remember them.
   Reference previous conversation context when relevant.
   ```

### Step 3: Add Buffer Memory

1. On the AI Agent node, click **+ Memory**
2. Select **Simple Memory** (Buffer Memory)
3. Configure:
   - **Context Window Length:** `10` (messages to keep)
   - **Session ID:** `{{ $json.sessionId }}` (if available, else use fixed ID for testing)

### Step 4: Test Memory Persistence

Run these messages in sequence:

```
Message 1: "Hi, my name is Alex and I work as a QA engineer"
Message 2: "I'm learning about AI agents for my job"
Message 3: "What do you know about me so far?"
```

### Expected Output (Message 3)

```
Based on our conversation, I know:
- Your name is Alex
- You work as a QA engineer  
- You're learning about AI agents for professional development
```

### 💡 Memory Visualization

After the conversation, check the execution data:
1. Click on the AI Agent node execution
2. Look at the `messages` array in the input
3. You'll see previous messages included as context

---

## Lab 2.2: Window Memory & Token Management

**Goal:** Implement window memory with explicit token control.

### Step 1: Create Workflow

1. Create new workflow: `Lab 2.2 - Window Memory`
2. Add **Chat Trigger**
3. Add **AI Agent**

### Step 2: Add Window Buffer Memory

1. On AI Agent, click **+ Memory**
2. Select **Window Buffer Memory**
3. Configure:
   - **Window Size:** `4` (number of message pairs to keep)
   - **Session Key:** `window_demo`

### Step 3: Add Token Counter (Educational)

Add a **Code** node after the agent to visualize token usage:

```javascript
// Rough token estimation for educational purposes
const response = $input.first().json;
const outputText = response.output || '';

// Rough estimate: 1 token ≈ 4 characters
const estimatedTokens = Math.ceil(outputText.length / 4);

return [{
  json: {
    response: outputText,
    estimatedTokens: estimatedTokens,
    charCount: outputText.length
  }
}];
```

### Step 4: Test Window Behavior

Send 6+ messages to exceed the window:

```
Message 1: "Remember: my favorite color is blue"
Message 2: "Remember: my favorite food is pizza"  
Message 3: "Remember: my pet's name is Max"
Message 4: "Remember: I live in Seattle"
Message 5: "Remember: my hobby is photography"
Message 6: "What was my favorite color?"
```

### Expected Behavior

With window size 4, message 6 won't recall "blue" because that context has been pushed out of the window.

### 💡 When to Use Each Memory Type

```
┌─────────────────────────────────────────────────────────┐
│                   Decision Tree                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   Short conversations (<20 messages)?                   │
│              │                                          │
│        ┌─────┴─────┐                                    │
│       Yes          No                                   │
│        │            │                                   │
│        ▼            ▼                                   │
│   Buffer Memory   Need full history?                    │
│                         │                               │
│                   ┌─────┴─────┐                         │
│                  Yes          No                        │
│                   │            │                        │
│                   ▼            ▼                        │
│              Summary      Window Memory                 │
│              Memory       (most common)                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## Advanced: Postgres-Backed Memory

For production, use database-backed memory:

### Step 1: Configure Postgres Memory

1. Add **Postgres Chat Memory** node
2. Configure:
   - **Connection:** Use your Postgres credential
   - **Table Name:** `chat_memories`
   - **Session ID Field:** `{{ $json.sessionId }}`

### Step 2: Memory Table Schema

The table is auto-created, but here's the structure:

```sql
CREATE TABLE chat_memories (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    message JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_session_id ON chat_memories(session_id);
```

### Benefits of Database Memory

- Persists across n8n restarts
- Supports multiple concurrent sessions
- Enables memory analytics
- Allows manual memory management

---

## Context Management Best Practices

### 1. System Prompt Engineering

```
GOOD System Prompt:
"You are a technical support agent for SaaS products.
Keep responses under 200 words.
If you don't know something, say so clearly.
Reference user's previous issues when relevant."

BAD System Prompt:
"You are helpful."
```

### 2. Session Management

```javascript
// Generate deterministic session IDs
const sessionId = `user_${userId}_conv_${conversationId}`;

// Or time-bounded sessions
const sessionId = `user_${userId}_${new Date().toISOString().split('T')[0]}`;
```

### 3. Memory Pruning Strategies

| Strategy        | When to Use                          |
|-----------------|--------------------------------------|
| Time-based      | Clear sessions after 24 hours        |
| Count-based     | Keep last 50 messages                |
| Relevance-based | Only keep messages with certain tags |

---

## Exercises

### Exercise 2.1: Custom Session IDs

Modify Lab 2.1 to:
1. Extract user ID from the incoming message
2. Generate a session ID per user
3. Test with multiple "users"

### Exercise 2.2: Memory Analytics

Create a workflow that:
1. Queries the Postgres memory table
2. Counts messages per session
3. Identifies the most active sessions

---

## Common Issues

| Issue                   | Solution                                       |
|-------------------------|------------------------------------------------|
| Memory not persisting   | Check session ID is consistent                 |
| Token limit exceeded    | Reduce window size or switch to summary memory |
| Slow with large history | Add index on session_id, use window memory     |
| Context seems lost      | Verify memory node is properly connected       |

---

## Key Takeaways

1. **LLMs are stateless** - memory must be explicitly managed
2. **Buffer memory** works for short conversations
3. **Window memory** provides predictable token usage
4. **Session IDs** are critical for multi-user scenarios
5. **Database-backed memory** is essential for production

---

## Next Module

Continue to [Module 3: RAG & Reranking](MODULE-03-rag-reranking.md) to learn how to ground agents in your own data.
