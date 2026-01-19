# Module 1: AI Agent Fundamentals

**Duration:** 25 minutes  
**Prerequisites:** Completed environment setup

---

## 🎯 Learning Objectives

- Understand the difference between AI Chains and AI Agents
- Learn the core components of an AI Agent
- Build your first AI Chain in n8n
- Add tool capabilities to create a true Agent

---

## Lecture: What are AI Agents?

### The Evolution: From Prompts to Agents

```
Simple Prompt → Chain → Agent
     ↓            ↓        ↓
  One-shot    Sequential  Autonomous
  response    processing  decision-making
```

### AI Chain vs AI Agent

| Aspect          |       AI Chain    | AI Agent                |
|-----------------|-------------------|-------------------------|
| Control Flow    | Predetermined     | Dynamic                 |
| Decision Making | None              | Autonomous              |
| Tool Use        | Fixed sequence    | Selects tools as needed |
| Iterations      | Fixed             | Variable (loops)        |
| Use Case        | Predictable tasks | Complex reasoning       |

### Anatomy of an AI Agent

```
┌─────────────────────────────────────────────────────────┐
│                      AI Agent                           │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐  │
│  │   System    │  │    LLM      │  │     Tools       │  │
│  │   Prompt    │  │   (Brain)   │  │  (Capabilities) │  │
│  └─────────────┘  └─────────────┘  └─────────────────┘  │
│         │                │                  │           │
│         └────────────────┼──────────────────┘           │
│                          ▼                              │
│                   ┌─────────────┐                       │
│                   │   Memory    │                       │
│                   │  (Context)  │                       │
│                   └─────────────┘                       │
└─────────────────────────────────────────────────────────┘
```

### Core Components

1. **System Prompt** - Defines agent personality, rules, and constraints
2. **LLM (Large Language Model)** - The reasoning engine
3. **Tools** - Functions the agent can invoke (APIs, calculators, search)
4. **Memory** - Maintains conversation history and context

### Key Parameters

| Parameter   | What it Controls          | Typical Values                 |
|-------------|---------------------------|--------------------------------|
| Temperature | Creativity vs determinism | 0.0 (factual) - 1.0 (creative) |
| Max Tokens  | Response length limit     | 500-4000                       |
| Top P       | Probability sampling      | 0.9-1.0                        |

---

## Lab 1.1: Your First AI Chain

**Goal:** Build a simple AI chain that processes user input and returns a response.

### Step 1: Create New Workflow

1. In n8n, click **+ Add Workflow**
2. Name it: `Lab 1.1 - Basic AI Chain`

### Step 2: Add Chat Trigger

1. Click **+** and search for **Chat Trigger**
2. Add it to the canvas
3. Configure:
   - **Webhook Path:** Leave default
   - **Response Mode:** `When Last Node Finishes`

### Step 3: Add Basic LLM Chain

1. Click **+** and search for **Basic LLM Chain**
2. Connect it to the Chat Trigger
3. Configure:
   - **Model:** Select your credential (OpenAI/Anthropic)
   - **Model Name:** `gpt-4o` or `claude-3-5-sonnet`
   - **Prompt:** `{{ $json.chatInput }}`

### Step 4: Add System Message (Optional)

1. Click on the Basic LLM Chain node
2. Under **Options**, add:
   - **System Message:**
   ```
   You are a helpful technical assistant for software engineers.
   Be concise and provide code examples when relevant.
   ```

### Step 5: Test Your Chain

1. Click **Chat** in the bottom panel
2. Type: `Explain what a REST API is in 2 sentences`
3. Observe the response

### Expected Output

```
A REST API (Representational State Transfer) is an architectural 
style for building web services that uses HTTP methods (GET, POST, 
PUT, DELETE) to perform operations on resources identified by URLs. 
It follows stateless communication, meaning each request contains 
all information needed to process it.
```

### 💡 Key Insight

This is a **chain**, not an agent. It follows a fixed path: Input → LLM → Output. The LLM cannot decide to use tools or take different actions based on the query.

---

## Lab 1.2: Adding Tools to Your Agent

**Goal:** Transform the chain into an agent by adding tool capabilities.

### Step 1: Create New Workflow

1. Create new workflow: `Lab 1.2 - Agent with Tools`
2. Add **Chat Trigger** (same as Lab 1.1)

### Step 2: Add AI Agent Node

1. Click **+** and search for **AI Agent**
2. Connect it to Chat Trigger
3. Configure:
   - **Agent Type:** `Tools Agent`
   - **Model:** Select your credential
   - **System Message:**
   ```
   You are a helpful assistant with access to tools.
   Use the calculator for any math operations.
   Use the code tool to execute JavaScript when needed.
   Always explain your reasoning before using a tool.
   ```

### Step 3: Add Calculator Tool

1. On the AI Agent node, click **+ Tool**
2. Search for and add **Calculator**
3. No configuration needed

### Step 4: Add Code Tool

1. Click **+ Tool** again
2. Search for and add **Code Tool**
3. Configure:
   - **Language:** JavaScript
   - **Description:** `Execute JavaScript code for data manipulation or processing`

### Step 5: Test Agent Decision Making

Test with these prompts to observe tool selection:

**Test 1 - Math (should use Calculator):**
```
What is 15% of 847.50?
```

**Test 2 - Code (should use Code Tool):**
```
Generate an array of the first 10 Fibonacci numbers
```

**Test 3 - No Tool Needed:**
```
What is the capital of France?
```

### Expected Behavior

The agent will:
1. Analyze the request
2. Decide if a tool is needed
3. Call the appropriate tool (or none)
4. Synthesize the final response

Watch the execution trace to see the agent's reasoning.

### 💡 Agent Loop

```
┌──────────────────────────────────────────────────┐
│                                                  │
│    User Input                                    │
│        │                                         │
│        ▼                                         │
│    ┌───────┐                                     │
│    │  LLM  │ ◄─────────────────┐                 │
│    └───┬───┘                   │                 │
│        │                       │                 │
│        ▼                       │                 │
│    Need Tool?                  │                 │
│    ┌──┴──┐                     │                 │
│   Yes    No                    │                 │
│    │      │                    │                 │
│    ▼      ▼                    │                 │
│  Execute  Generate             │                 │
│   Tool    Response             │                 │
│    │      │                    │                 │
│    │      └──► Final Output    │                 │
│    │                           │                 │
│    └───────────────────────────┘                 │
│         (loop with tool result)                  │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## Exercises

### Exercise 1.1: Temperature Experiment

Modify your Lab 1.1 chain:
1. Set temperature to `0.0`
2. Ask: `Write a one-line product tagline for a coffee shop`
3. Run 3 times, note responses
4. Change temperature to `1.0`
5. Run 3 more times, compare

**Discussion:** How does temperature affect consistency and creativity?

### Exercise 1.2: Custom Tool

Add a new tool to your Lab 1.2 agent:
1. Add **HTTP Request Tool**
2. Configure it to call a public API (e.g., `https://api.quotable.io/random`)
3. Test: `Give me an inspirational quote`

---

## Common Issues

| Issue                       | Solution                                           |
|-----------------------------|----------------------------------------------------|
| "Credential not configured" | Settings → Credentials → Add your API key          |
| Agent loops infinitely      | Add max iterations in agent settings (default: 10) |
| Tool not being selected     | Improve tool description to be more specific       |
| Slow responses              | Try a faster model (gpt-4o-mini, claude-3-haiku)   |

---

## Key Takeaways

1. **Chains** follow fixed paths; **Agents** make autonomous decisions
2. **System prompts** shape agent behavior and tool usage
3. **Temperature** controls randomness (0=deterministic, 1=creative)
4. Agents iterate in a **loop** until they have a final answer
5. **Tool descriptions** are critical for proper tool selection

---

## Next Module

Continue to [Module 2: Memory & Context](MODULE-02-memory-context.md) to learn how agents maintain conversation state.
