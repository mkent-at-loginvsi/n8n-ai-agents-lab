# Module 4: Production Patterns & Reliability

**Duration:** 30 minutes  
**Prerequisites:** Completed Modules 1-3, documents ingested into Qdrant

---

## 🎯 Learning Objectives

- Understand types of AI hallucinations
- Build grounded agents that cite sources
- Implement output validation
- Create production-ready multi-tool agents

---

## Lecture: Hallucinations & Mitigation

### Types of Hallucinations

| Type | Description | Example |
|------|-------------|---------|
| **Factual** | Wrong facts stated confidently | "The Eiffel Tower is 500m tall" (actually 330m) |
| **Fabrication** | Inventing sources/quotes | "According to your docs..." (docs never say this) |
| **Conflation** | Mixing up distinct information | Combining features from Product A and B |
| **Logical** | Flawed reasoning | Invalid logical deductions |

### Defense in Depth

```
┌─────────────────────────────────────────────────────────────┐
│                    Mitigation Layers                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│   Layer 1: Model Selection                                   │
│   └── Use capable models (GPT-4o, Claude 3.5)               │
│                                                              │
│   Layer 2: Prompt Engineering                                │
│   └── Clear instructions, require citations                  │
│                                                              │
│   Layer 3: RAG Grounding                                     │
│   └── Provide factual context from your data                │
│                                                              │
│   Layer 4: Output Validation                                 │
│   └── Check responses before returning to user              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### The Grounding Prompt

This system prompt forces the agent to cite sources and admit uncertainty:

```
You are a helpful assistant with access to a knowledge base.

CRITICAL RULES:
1. ALWAYS search the knowledge base before answering
2. ONLY answer based on information found in the knowledge base
3. CITE your sources: mention which document the info came from
4. If the knowledge base doesn't have the answer, say: "I don't have information about that in my knowledge base."
5. NEVER make up information not explicitly stated in retrieved documents
6. Do NOT ask clarifying questions - search first, then answer
```

---

## Lab 4.1: Grounded Agent with Citations

**Goal:** Build an agent that only answers from retrieved context and cites sources.

> **Note:** Build this workflow from scratch - it's more reliable than importing in n8n 2.3+

### Step 1: Create New Workflow

1. Click **Add Workflow** (or press `Ctrl/Cmd + N`)
2. Name it `Lab 4.1 - Grounded Agent`
3. Click **Save**

### Step 2: Add Chat Trigger

1. Click **+** to add a node
2. Search for **Chat Trigger**
3. Add it to the canvas
4. No configuration needed (defaults work)

### Step 3: Add AI Agent

1. Click **+** → Search for **AI Agent**
2. Add it to the canvas
3. **Connect** Chat Trigger → AI Agent (drag from right dot to left dot)
4. Click on the **AI Agent** node to configure:
   - Find **System Message** (may be under Options or Prompt)
   - Enter the grounding prompt:

```
You are a helpful assistant with access to a knowledge base about DataSync Pro.

CRITICAL RULES:
1. ALWAYS search the knowledge base before answering ANY question
2. ONLY answer based on information found in the knowledge base
3. CITE your sources by saying "According to [document name]..."
4. If the knowledge base doesn't have the answer, say: "I don't have information about that in my knowledge base."
5. NEVER make up information not explicitly stated in retrieved documents
6. Do NOT ask clarifying questions - search first, then answer based on what you find
```

### Step 4: Add Model Sub-Node (Required)

1. With AI Agent selected, look at the **bottom of the node**
2. Find the **Model** connector (shows a ⚠️ if not connected)
3. Click the **+** button on the Model connector
4. Search for **OpenAI Chat Model**
5. Select it - it will attach as a sub-node below the AI Agent
6. Click on the **OpenAI Chat Model** sub-node to configure:
   - **Credential to connect with:** Select your OpenAI credential
   - **Model:** `gpt-4o`
   - Under Options: **Temperature:** `0.2` (lower = more consistent)

### Step 5: Add Tool Sub-Node

1. Click back on the **AI Agent** node (the main one, not the model)
2. Find the **Tool** connector at the bottom
3. Click **+** → Search for **Vector Store Tool**
4. Select it - it attaches as a sub-node
5. Click on **Vector Store Tool** to configure:
   - **Name:** `knowledge_search`
   - **Description:** `Search the knowledge base for information about DataSync Pro, including features, pricing, installation, and troubleshooting.`

### Step 6: Add Vector Store Sub-Node

1. Click on the **Vector Store Tool** node (the sub-node you just added)
2. Find the **Vector Store** connector at the bottom
3. Click **+** → Search for **Qdrant Vector Store**
4. Select it
5. Click on **Qdrant Vector Store** to configure:
   - **Credential to connect with:** Select your Qdrant credential
   - **Operation/Mode:** Retrieve (or Get Many)
   - **Collection Name:** `lab_documents`
   - **Top K / Limit:** `4`

### Step 7: Add Embeddings Sub-Node (Required for Vector Store)

1. Click on the **Qdrant Vector Store** node
2. Find the **Embedding** connector at the bottom (shows ⚠️ if not connected)
3. Click **+** → Search for **Embeddings OpenAI**
4. Select it
5. Click on **Embeddings OpenAI** to configure:
   - **Credential to connect with:** Select your OpenAI credential
   - **Model:** `text-embedding-3-small`

### Visual Check - Final Structure

Your workflow should look like this:

```
┌──────────────┐      ┌──────────────┐
│ Chat Trigger │─────→│   AI Agent   │
└──────────────┘      └──────┬───────┘
                             │
                    ┌────────┴────────┐
                    ↓                 ↓
            ┌──────────────┐  ┌──────────────┐
            │ OpenAI Chat  │  │ Vector Store │
            │    Model     │  │     Tool     │
            └──────────────┘  └──────┬───────┘
                                     │
                                     ↓
                             ┌──────────────┐
                             │    Qdrant    │
                             │ Vector Store │
                             └──────┬───────┘
                                    │
                                    ↓
                             ┌──────────────┐
                             │  Embeddings  │
                             │   OpenAI     │
                             └──────────────┘
```

The sub-nodes hang below their parent nodes visually.

### Step 8: Save and Test

1. Click **Save** (top right)
2. Open the **Chat** panel:
   - Look for a speech bubble icon in the bottom right
   - Or click the "Test Chat" button if visible
3. Test with these questions:

**Should answer (info is in knowledge base):**
```
What are the main features of DataSync Pro?
```
```
How much does the Professional plan cost?
```
```
What are the system requirements?
```

**Should decline (info is NOT in knowledge base):**
```
What color is the DataSync Pro logo?
```
```
Who is the CEO of DataSync Pro?
```

### Expected Behavior

✅ **Good response:**
> According to the product manual, DataSync Pro offers real-time bidirectional sync, intelligent conflict resolution, and end-to-end encryption. The Professional plan costs $999/month and includes up to 50 users.

✅ **Good decline:**
> I don't have information about the logo color in my knowledge base.

❌ **Bad response (hallucination):**
> The DataSync Pro logo is blue and white. (Made up!)

---

## Lab 4.2: Multi-Tool Agent

**Goal:** Build an agent with multiple tools that can answer different types of questions.

### Step 1: Create New Workflow

1. Click **Add Workflow** → Name it `Lab 4.2 - Multi-Tool Agent`
2. Click **Save**

### Step 2: Add Chat Trigger + AI Agent

1. Add **Chat Trigger** node
2. Add **AI Agent** node
3. Connect Chat Trigger → AI Agent
4. Configure AI Agent system message:

```
You are a helpful assistant with multiple capabilities:

1. KNOWLEDGE BASE: Search for information about DataSync Pro
2. CALCULATOR: Perform mathematical calculations
3. CODE: Execute JavaScript code for complex operations

RULES:
- For product questions, ALWAYS search the knowledge base first
- For math questions, use the calculator
- For complex calculations or data processing, use code execution
- Cite sources when using knowledge base information
- If you cannot find information, say so clearly
```

### Step 3: Add Model Sub-Node

1. Click **+** on AI Agent's **Model** connector
2. Add **OpenAI Chat Model**
3. Configure:
   - **Credential:** Your OpenAI credential
   - **Model:** `gpt-4o`

### Step 4: Add Vector Store Tool (First Tool)

1. Click **+** on AI Agent's **Tool** connector
2. Add **Vector Store Tool**
3. Configure:
   - **Name:** `knowledge_search`
   - **Description:** `Search the knowledge base for DataSync Pro information`
4. Click on Vector Store Tool, then add **Qdrant Vector Store** sub-node:
   - **Credential:** Your Qdrant credential
   - **Collection:** `lab_documents`
5. Click on Qdrant, then add **Embeddings OpenAI** sub-node:
   - **Credential:** Your OpenAI credential

### Step 5: Add Calculator Tool (Second Tool)

1. Click back on the **AI Agent** node
2. Click **+** on the **Tool** connector again
3. Search for **Calculator**
4. Add it - no configuration needed

### Step 6: Add Code Tool (Third Tool)

1. Click back on the **AI Agent** node
2. Click **+** on the **Tool** connector again
3. Search for **Code Tool**
4. Add it
5. Configure:
   - **Language:** `JavaScript`

### Final Structure

```
┌──────────────┐      ┌──────────────┐
│ Chat Trigger │─────→│   AI Agent   │
└──────────────┘      └──────┬───────┘
                             │
        ┌───────────┬────────┼────────┬───────────┐
        ↓           ↓        ↓        ↓           ↓
   ┌─────────┐ ┌─────────┐ ┌──────┐ ┌──────┐ ┌─────────┐
   │ OpenAI  │ │ Vector  │ │Qdrant│ │Calc- │ │  Code   │
   │  Chat   │ │ Store   │ │  +   │ │ulator│ │  Tool   │
   │  Model  │ │  Tool   │ │Embed │ │      │ │         │
   └─────────┘ └─────────┘ └──────┘ └──────┘ └─────────┘
```

### Step 7: Save and Test

Test with different types of questions:

**Knowledge base query:**
```
What encryption does DataSync Pro use?
```

**Calculator query:**
```
If the Professional plan is $999/month, how much is that per year?
```

**Code query:**
```
Generate a random 16-character password using letters and numbers
```

**Combined query:**
```
The Starter plan is $299/month. If I have a team of 8 and we upgrade to Professional at $999/month, what's the annual difference in cost?
```

---

## Exercises

### Exercise 4.1: Add Response Validation

Add a Code node after the AI Agent to validate responses:

1. Disconnect the AI Agent from any final output
2. Add a **Code** node
3. Connect AI Agent → Code
4. Add this validation code:

```javascript
const response = $input.first().json.output;

// Validation checks
const checks = {
  hasContent: response && response.length > 0,
  notTooLong: response.length < 2000,
  noErrorPhrases: !response.toLowerCase().includes('error'),
  hasCitation: response.includes('according to') || 
               response.includes('based on') ||
               response.includes("don't have information")
};

const isValid = Object.values(checks).every(v => v);

return [{
  json: {
    response,
    validation: checks,
    isValid
  }
}];
```

### Exercise 4.2: Custom Tool

Create a tool that fetches current date/time:

1. Add **Code Tool** to the AI Agent
2. In the tool's code, return current date:

```javascript
return {
  currentDate: new Date().toISOString(),
  formatted: new Date().toLocaleDateString('en-US', {
    weekday: 'long',
    year: 'numeric',
    month: 'long',
    day: 'numeric'
  })
};
```

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Model sub-node must be connected" | Click AI Agent → Click **+** on Model connector → Add OpenAI Chat Model |
| "Embedding must be connected" | Click Qdrant node → Click **+** on Embedding connector → Add Embeddings OpenAI |
| "Credential not found" | Click node → Select credential from dropdown → Save |
| "Collection not found" | Run Lab 3.1 first to ingest documents, or check collection name spelling |
| Agent doesn't search | Make system prompt more explicit about searching FIRST |
| No citations in response | Add to prompt: "You MUST cite by saying 'According to [source]...'" |
| Slow responses | Use `gpt-4o-mini` instead, reduce Top K to 3 |
| Chat panel won't open | Make sure workflow is saved, try refreshing the page |

---

## Common n8n 2.3+ Patterns

### Sub-Node Connection Pattern

Sub-nodes connect at the **bottom** of parent nodes:

```
Parent Node
     │
     ↓ (click + on connector)
Sub-Node
```

### Required Sub-Nodes

| Parent Node | Required Sub-Nodes |
|-------------|-------------------|
| AI Agent | Model (always required) |
| Vector Store Tool | Vector Store |
| Qdrant Vector Store | Embedding |

### Credential Checklist

Every node that calls an external service needs credentials:

- [ ] OpenAI Chat Model → OpenAI credential
- [ ] Embeddings OpenAI → OpenAI credential  
- [ ] Qdrant Vector Store → Qdrant credential

---

## Key Takeaways

1. **Grounding prevents hallucinations** - Force agents to use retrieved context
2. **Require citations** - Makes it easy to verify responses
3. **Admit uncertainty** - Better to say "I don't know" than hallucinate
4. **Multiple tools** - Give agents the right tool for each job
5. **Validate outputs** - Check responses before returning to users
6. **Sub-nodes are key** - In n8n 2.3+, AI nodes use sub-node connections

---

## Workshop Complete! 🎉

You've learned:
- ✅ Chains vs Agents
- ✅ Memory management  
- ✅ RAG and vector search
- ✅ Reranking for quality
- ✅ Grounding and citations
- ✅ Multi-tool agents

**Next steps:**
1. Add your own documents to the knowledge base
2. Create custom tools for your use case
3. Deploy n8n for production use
4. Explore more n8n AI nodes

Remember to run `docker compose down` when you're finished!
