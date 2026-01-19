# Module 4: Advanced Agents & Reliability

**Duration:** 30 minutes  
**Prerequisites:** Completed Modules 1-3

---

## 🎯 Learning Objectives

- Understand types and causes of LLM hallucinations
- Implement grounding strategies with citations
- Build robust multi-tool production agents
- Apply error handling and reliability patterns

---

## Lecture: Hallucinations - Detection & Mitigation

### What are Hallucinations?

LLM hallucinations are confident-sounding outputs that are factually incorrect, fabricated, or inconsistent.

```
User: "Who wrote the novel 'The Azure Protocols'?"

Hallucinated Response:
"The Azure Protocols was written by Margaret Chen in 1987. 
It won the National Book Award and has sold over 2 million copies."

Reality: This book doesn't exist. The LLM invented everything.
```

### Types of Hallucinations

| Type            | Example                               | Cause                                |
|-----------------|---------------------------------------|--------------------------------------|
| **Factual**     | Incorrect dates, names, statistics    | Training data errors, interpolation  |
| **Fabrication** | Made-up citations, fake quotes        | Pattern completion without grounding |
| **Logical**     | Self-contradicting statements         | Context window limitations           |
| **Conflation**  | Mixing details from different sources | Embedding space proximity            |

### Why Do LLMs Hallucinate?

```
┌─────────────────────────────────────────────────────────────┐
│                  Causes of Hallucination                    │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  1. Pattern Completion Pressure                             │
│     LLMs are trained to generate plausible text.            │
│     When uncertain, they generate plausible-sounding        │
│     content rather than admitting uncertainty.              │
│                                                             │
│  2. Knowledge Boundaries                                    │
│     No clear signal when information is outside             │
│     training data. Model can't distinguish "I know"         │
│     from "I can generate something that sounds right."      │
│                                                             │
│  3. Context Window Confusion                                │
│     In long conversations, earlier context may be           │
│     misremembered or conflated with other information.      │
│                                                             │
│  4. Statistical Interpolation                               │
│     Training creates probability distributions.             │
│     Low-probability but coherent outputs can emerge.        │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Mitigation Strategies

```
┌────────────────────────────────────────────────────────────┐
│               Hallucination Mitigation Stack               │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  Layer 4: Output Validation                                │
│  ──────────────────────────                                │
│  • Fact-checking against sources                           │
│  • Citation verification                                   │
│  • Consistency checks                                      │
│                                                            │
│  Layer 3: Retrieval Augmentation (RAG)                     │
│  ──────────────────────────────────────                    │
│  • Ground responses in retrieved facts                     │
│  • Provide source context                                  │
│  • Limit generation to known information                   │
│                                                            │
│  Layer 2: Prompt Engineering                               │
│  ──────────────────────────                                │
│  • "Only answer from provided context"                     │
│  • "Say 'I don't know' if uncertain"                       │
│  • Request confidence levels                               │
│                                                            │
│  Layer 1: Model Selection                                  │
│  ────────────────────────                                  │
│  • Larger models hallucinate less                          │
│  • Lower temperature reduces fabrication                   │
│  • Some models better calibrated                           │
│                                                            │
└────────────────────────────────────────────────────────────┘
```

### Grounding Techniques

| Technique                   | How It Works                    | Effectiveness |
|-----------------------------|---------------------------------|---------------|
| **RAG**                     | Provide source documents        | High          |
| **Citations Required**      | Force source attribution        | Medium-High   |
| **Confidence Scores**       | Request uncertainty estimates   | Medium        |
| **Multi-step Verification** | Cross-check with separate calls | High (costly) |
| **Constrained Generation**  | Limit output to known entities  | Very High     |

---

## Lab 4.1: Grounded Agent with Citations

**Goal:** Build an agent that always cites its sources and acknowledges uncertainty.

### Step 1: Create Workflow

1. Create new workflow: `Lab 4.1 - Grounded Agent`
2. Add **Chat Trigger**

### Step 2: Configure Retrieval

1. Add **Qdrant Vector Store** node
2. Configure for retrieval:
   - **Collection:** `lab_documents`
   - **Top K:** `5`
   - **Include Metadata:** Yes

### Step 3: Format Context with Sources

Add **Code** node to prepare grounded context:

```javascript
const query = $('Chat Trigger').first().json.chatInput;
const retrievedDocs = $input.all();

// Format each document with a citation ID
const formattedContext = retrievedDocs.map((doc, index) => {
  const content = doc.json.document.pageContent;
  const source = doc.json.document.metadata?.source || 'Unknown';
  const score = doc.json.score?.toFixed(3) || 'N/A';
  
  return `[SOURCE ${index + 1}] (Relevance: ${score})
File: ${source}
Content: ${content}
---`;
}).join('\n\n');

const sources = retrievedDocs.map((doc, index) => ({
  id: index + 1,
  source: doc.json.document.metadata?.source || 'Unknown',
  score: doc.json.score
}));

return [{
  json: {
    query,
    formattedContext,
    sources,
    sourceCount: retrievedDocs.length
  }
}];
```

### Step 4: Configure Grounded Agent

1. Add **AI Agent** node
2. Configure with grounding system prompt:

```
You are a helpful assistant that ONLY provides information from the given sources.

CRITICAL RULES:
1. ONLY answer based on the provided SOURCE documents
2. ALWAYS cite sources using [SOURCE X] format
3. If information is not in the sources, say "I don't have information about this in my knowledge base"
4. NEVER make up information or extrapolate beyond what sources state
5. If sources conflict, mention both views with their citations
6. Rate your confidence: HIGH (directly stated), MEDIUM (implied), LOW (uncertain)

CONTEXT FROM KNOWLEDGE BASE:
{{ $json.formattedContext }}

USER QUESTION: {{ $json.query }}

Remember: No citation = No claim. Every factual statement needs a [SOURCE X] reference.
```

### Step 5: Test Grounding

Test with these scenarios:

**Test 1 - Answerable:**
```
"What features does the product have?"
```
Expected: Answer with [SOURCE X] citations

**Test 2 - Not in sources:**
```
"What is the CEO's favorite color?"
```
Expected: "I don't have information about this in my knowledge base"

**Test 3 - Partial information:**
```
"Compare all pricing tiers in detail"
```
Expected: Answer what's available, note what's missing

### 💡 Citation Verification

Add a validation node to check citations are valid:

```javascript
const response = $input.first().json.output;
const sourceCount = $('Code').first().json.sourceCount;

// Extract cited sources
const citedSources = [...response.matchAll(/\[SOURCE (\d+)\]/g)]
  .map(m => parseInt(m[1]));

// Check for invalid citations
const invalidCitations = citedSources.filter(s => s > sourceCount);

// Check for uncited claims (basic heuristic)
const sentences = response.split(/[.!?]+/).filter(s => s.trim());
const citedSentences = sentences.filter(s => /\[SOURCE \d+\]/.test(s));
const citationRate = citedSentences.length / sentences.length;

return [{
  json: {
    response,
    citedSources: [...new Set(citedSources)],
    invalidCitations,
    citationRate: (citationRate * 100).toFixed(1) + '%',
    qualityFlags: {
      hasInvalidCitations: invalidCitations.length > 0,
      lowCitationRate: citationRate < 0.5
    }
  }
}];
```

---

## Lab 4.2: Multi-Tool Production Agent

**Goal:** Build a robust agent with multiple tools and error handling.

### Step 1: Create Workflow

1. Create new workflow: `Lab 4.2 - Multi-Tool Agent`
2. Add **Chat Trigger**

### Step 2: Configure Production Agent

1. Add **AI Agent** node
2. System prompt for multi-tool orchestration:

```
You are a production-grade assistant with multiple capabilities.

AVAILABLE TOOLS:
- knowledge_search: Search internal documentation (USE FIRST for factual questions)
- calculator: Perform mathematical calculations
- code_executor: Run JavaScript code for data processing
- web_search: Search the internet for current information (use sparingly)

DECISION FRAMEWORK:
1. For internal/product questions → knowledge_search FIRST
2. For calculations → calculator
3. For data transformation → code_executor  
4. For current events/external info → web_search
5. For general knowledge → answer directly (with caveats)

ERROR HANDLING:
- If a tool fails, explain the issue and try an alternative approach
- If you're uncertain, state your confidence level
- If you can't complete a task, explain what you would need

RESPONSE FORMAT:
- Be concise but complete
- Cite sources when using knowledge_search
- Show your work for calculations
- Explain your tool selection reasoning briefly
```

### Step 3: Add Tools

Add these tools to the agent:

**1. Knowledge Search Tool**
- Vector Store Tool connected to Qdrant
- Description: `Search internal documentation and knowledge base`

**2. Calculator Tool**
- Built-in Calculator
- Description: `Perform mathematical calculations`

**3. Code Tool**
- Code Tool (JavaScript)
- Description: `Execute JavaScript for data processing, parsing, or transformation`

**4. HTTP Request Tool (Optional)**
- For external API calls
- Description: `Make HTTP requests to external services`

### Step 4: Add Error Handling Wrapper

Add **Code** node before output for error handling:

```javascript
const agentOutput = $input.first();

// Check for error indicators
const output = agentOutput.json.output || '';
const hasError = agentOutput.json.error || 
                 output.toLowerCase().includes('error') ||
                 output.toLowerCase().includes('failed');

// Log execution metadata
const executionMeta = {
  timestamp: new Date().toISOString(),
  toolsUsed: agentOutput.json.intermediateSteps?.map(s => s.action?.tool) || [],
  iterationCount: agentOutput.json.intermediateSteps?.length || 0,
  hasError,
  responseLength: output.length
};

// Quality checks
const qualityChecks = {
  tooShort: output.length < 50,
  tooLong: output.length > 4000,
  noToolUsed: executionMeta.toolsUsed.length === 0,
  excessiveIterations: executionMeta.iterationCount > 5
};

return [{
  json: {
    output,
    executionMeta,
    qualityChecks,
    warnings: Object.entries(qualityChecks)
      .filter(([_, v]) => v)
      .map(([k]) => k)
  }
}];
```

### Step 5: Add Fallback Logic

Add **IF** node to handle failures:

```javascript
// Check if we should use fallback
const hasWarnings = $input.first().json.warnings.length > 0;
const hasError = $input.first().json.executionMeta.hasError;

return hasError || hasWarnings;
```

**True branch:** Send to a simpler agent or return error message
**False branch:** Return successful response

### Step 6: Test Multi-Tool Scenarios

```
Test 1: "What's 15% of the base price mentioned in the documentation?"
→ Should use: knowledge_search, then calculator

Test 2: "Parse this JSON and extract all email addresses: {data...}"
→ Should use: code_executor

Test 3: "What does our documentation say about API rate limits?"
→ Should use: knowledge_search only

Test 4: "What's the current Bitcoin price?"
→ Should use: web_search (if available) or acknowledge limitation
```

---

## Production Patterns

### 1. Retry with Exponential Backoff

```javascript
async function retryWithBackoff(fn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      await sleep(Math.pow(2, i) * 1000);
    }
  }
}
```

### 2. Circuit Breaker Pattern

```javascript
const circuitBreaker = {
  failures: 0,
  lastFailure: null,
  threshold: 5,
  resetTimeout: 60000,
  
  async execute(fn) {
    if (this.isOpen()) {
      throw new Error('Circuit breaker is open');
    }
    try {
      const result = await fn();
      this.reset();
      return result;
    } catch (error) {
      this.recordFailure();
      throw error;
    }
  },
  
  isOpen() {
    if (this.failures >= this.threshold) {
      const timeSinceFailure = Date.now() - this.lastFailure;
      return timeSinceFailure < this.resetTimeout;
    }
    return false;
  }
};
```

### 3. Response Validation

```javascript
function validateResponse(response, schema) {
  const checks = {
    hasContent: response.length > 0,
    notTooLong: response.length < 10000,
    noErrorIndicators: !/(error|failed|exception)/i.test(response),
    hasCitations: /\[SOURCE \d+\]/.test(response),
    isComplete: !response.endsWith('...')
  };
  
  return {
    isValid: Object.values(checks).every(v => v),
    checks
  };
}
```

---

## Exercises

### Exercise 4.1: Confidence Calibration

Modify the grounded agent to:
1. Add confidence scores to each claim
2. Track calibration over multiple queries
3. Identify when the agent is overconfident

### Exercise 4.2: Agent Observability

Create a dashboard workflow that:
1. Logs all agent executions to a database
2. Tracks tool usage patterns
3. Monitors error rates
4. Alerts on anomalies

---

## Common Issues

| Issue                   | Solution                                       |
|-------------------------|------------------------------------------------|
| Agent ignores sources   | Strengthen grounding prompt, lower temperature |
| Too many iterations     | Set max iterations, improve tool descriptions  |
| Invalid citations       | Add citation validation, post-process output   |
| Inconsistent formatting | Use structured output or JSON mode             |

---

## Key Takeaways

1. **Hallucinations are inherent** to LLMs - mitigate, don't eliminate
2. **Grounding with RAG** significantly reduces fabrication
3. **Citations create accountability** and verifiability
4. **Multi-tool agents** need clear tool selection guidance
5. **Production agents** require error handling and observability

---

## Workshop Summary

Congratulations! You've completed the AI Agents Lab. You can now:

✅ Build AI Chains and Agents in n8n
✅ Implement conversation memory
✅ Create RAG pipelines with reranking
✅ Mitigate hallucinations with grounding
✅ Build production-ready multi-tool agents

### Next Steps

1. **Experiment:** Modify the lab workflows for your use cases
2. **Scale:** Add more documents to your knowledge base
3. **Monitor:** Implement logging and observability
4. **Iterate:** Continuously improve prompts based on results

### Resources

- [n8n AI Documentation](https://docs.n8n.io/ai/)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
- [OpenAI Cookbook](https://cookbook.openai.com/)
- [LangChain Concepts](https://docs.langchain.com/docs/)
