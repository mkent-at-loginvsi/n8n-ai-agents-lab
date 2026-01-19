# Module 3: RAG & Reranking

**Duration:** 35 minutes  
**Prerequisites:** Completed Modules 1 & 2

---

## 🎯 Learning Objectives

- Understand RAG architecture and components
- Build a document ingestion pipeline
- Create a vector search agent
- Implement reranking for improved retrieval quality
- Learn chunking strategies and their trade-offs

---

## Lecture: RAG Architecture Deep Dive

### What is RAG?

**Retrieval-Augmented Generation (RAG)** grounds LLM responses in your own data by retrieving relevant context before generation.

```
┌─────────────────────────────────────────────────────────────┐
│                    RAG Pipeline                             │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   User Query                                                │
│       │                                                     │
│       ▼                                                     │
│   ┌───────────┐     ┌──────────────┐     ┌──────────────┐  │
│   │  Embed    │────►│   Vector     │────►│   Retrieve   │  │
│   │  Query    │     │   Search     │     │   Top K      │  │
│   └───────────┘     └──────────────┘     └──────────────┘  │
│                                                │            │
│                                                ▼            │
│                          ┌─────────────────────────────┐   │
│                          │     (Optional) Rerank      │   │
│                          └─────────────────────────────┘   │
│                                                │            │
│                                                ▼            │
│   ┌───────────────────────────────────────────────────┐    │
│   │            Augmented Prompt                        │    │
│   │  ┌─────────────┐  ┌──────────────┐               │    │
│   │  │   Query     │ +│  Retrieved   │  ──► LLM ──►  │    │
│   │  │             │  │   Context    │      Response │    │
│   │  └─────────────┘  └──────────────┘               │    │
│   └───────────────────────────────────────────────────┘    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### Why RAG?

| Problem | RAG Solution |
|---------|--------------|
| Knowledge cutoff | Retrieve current information |
| Hallucinations | Ground responses in facts |
| Domain specificity | Use your proprietary data |
| Data privacy | Keep data in your infrastructure |

### RAG Components

#### 1. Document Processing

```
Raw Documents → Chunking → Embedding → Vector Store
     │              │           │            │
   PDF/MD/TXT   Split into   Convert to   Store for
              manageable    vectors      retrieval
               pieces
```

#### 2. Chunking Strategies

| Strategy | Chunk Size | Overlap | Best For |
|----------|------------|---------|----------|
| Fixed | 500 tokens | 50 tokens | General purpose |
| Semantic | Variable | Natural breaks | Well-structured docs |
| Sentence | 3-5 sentences | 1 sentence | Q&A systems |
| Recursive | 1000 → 500 → 200 | 20% | Long documents |

**Critical:** Chunk size affects retrieval quality significantly.

```
Too Small (100 tokens):
- Loses context
- Many irrelevant matches

Too Large (2000 tokens):  
- Dilutes relevant info
- Wastes token budget

Sweet Spot (300-800 tokens):
- Maintains context
- Focused retrieval
```

#### 3. Embeddings

Embeddings convert text to numerical vectors that capture semantic meaning.

```
"How do I reset my password?" 
    ↓ (embedding model)
[0.023, -0.156, 0.892, ... 1536 dimensions]
```

| Embedding Model | Dimensions | Best For |
|-----------------|------------|----------|
| text-embedding-3-small | 1536 | Cost-effective |
| text-embedding-3-large | 3072 | Higher accuracy |
| nomic-embed-text | 768 | Local/Ollama |

#### 4. Vector Similarity

```
Query Vector:     [0.2, 0.8, 0.1, ...]
                        │
              ┌─────────┴─────────┐
              ▼                   ▼
Document A: [0.3, 0.7, 0.2, ...] → Similarity: 0.94 ✓
Document B: [0.9, 0.1, 0.8, ...] → Similarity: 0.31 ✗
```

**Similarity Metrics:**
- **Cosine Similarity** (most common): Measures angle between vectors
- **Euclidean Distance**: Measures straight-line distance
- **Dot Product**: Fast, works well for normalized vectors

### Reranking: The Second Pass

Initial vector search is fast but imprecise. Reranking adds precision:

```
Query: "How do I integrate with Salesforce?"

Vector Search (fast, approximate):
1. "Salesforce integration guide" ← Relevant
2. "Sales force calculation formula" ← Irrelevant!
3. "CRM integration patterns" ← Somewhat relevant

After Reranking (slower, precise):
1. "Salesforce integration guide" (0.95)
2. "CRM integration patterns" (0.78)
3. "Sales force calculation formula" (0.12) ← Demoted
```

**Reranking Methods:**
- **Cross-encoder models** (e.g., Cohere Rerank)
- **LLM-based reranking** (ask the LLM to score relevance)
- **Hybrid search** (combine keyword + semantic)

---

## Lab 3.1: Document Ingestion Pipeline

**Goal:** Build a pipeline to ingest documents into a vector store.

### Step 1: Create Workflow

1. Create new workflow: `Lab 3.1 - Document Ingestion`
2. Add **Manual Trigger** (we'll run this on-demand)

### Step 2: Load Documents

1. Add **Read Binary Files** node
2. Configure:
   - **File Path:** `/data/sample-docs/`
   - **File Extensions:** `md,txt`

Alternative: Add **HTTP Request** to fetch from URL.

### Step 3: Extract Text

1. Add **Extract Document Text** node
2. Connect to file reader
3. Configure:
   - **Operation:** `Extract text from document`

### Step 4: Chunk Documents

1. Add **Text Splitter** node
2. Configure:
   - **Chunk Size:** `500` (characters)
   - **Chunk Overlap:** `50`
   - **Separator:** `\n\n` (paragraph breaks)

### Step 5: Generate Embeddings

1. Add **Embeddings OpenAI** node
2. Configure:
   - **Model:** `text-embedding-3-small`
   - **Credential:** Your OpenAI credential

### Step 6: Store in Qdrant

1. Add **Qdrant Vector Store** node
2. Configure:
   - **Mode:** `Insert`
   - **Collection Name:** `lab_documents`
   - **Credential:** Qdrant Local

### Step 7: Run Ingestion

1. Place sample documents in `/data/sample-docs/`
2. Execute the workflow
3. Verify in Qdrant UI (http://localhost:6333/dashboard)

### Complete Pipeline

```
Manual Trigger → Read Files → Extract Text → Chunk → Embed → Qdrant
```

---

## Lab 3.2: Vector Search Agent

**Goal:** Create an agent that queries the vector store.

### Step 1: Create Workflow

1. Create new workflow: `Lab 3.2 - Vector Search Agent`
2. Add **Chat Trigger**

### Step 2: Add AI Agent

1. Add **AI Agent** node
2. Configure:
   - **Agent Type:** `Tools Agent`
   - **System Message:**
   ```
   You are a helpful assistant with access to a knowledge base.
   Always search the knowledge base before answering questions.
   Cite your sources by mentioning which document the information came from.
   If the knowledge base doesn't contain relevant information, say so clearly.
   ```

### Step 3: Add Vector Store Tool

1. On AI Agent, click **+ Tool**
2. Add **Vector Store Tool**
3. Configure:
   - **Vector Store:** Qdrant
   - **Collection:** `lab_documents`
   - **Embedding:** OpenAI Embeddings
   - **Top K:** `3`

### Step 4: Test Retrieval

Test with questions about your ingested documents:

```
User: "What are the main features of the product?"
User: "How do I troubleshoot connection issues?"
User: "What's the pricing model?"
```

### Expected Behavior

The agent will:
1. Convert query to embedding
2. Search Qdrant for similar chunks
3. Include retrieved context in prompt
4. Generate grounded response

---

## Lab 3.3: Implementing Reranking

**Goal:** Add reranking to improve retrieval quality.

### Step 1: Create Enhanced Workflow

1. Create new workflow: `Lab 3.3 - Reranking Pipeline`
2. Add **Chat Trigger**

### Step 2: Initial Retrieval (Over-fetch)

1. Add **Qdrant Vector Store** node
2. Configure:
   - **Mode:** `Retrieve`
   - **Collection:** `lab_documents`
   - **Top K:** `10` (retrieve more than needed)
   - **Query:** `{{ $json.chatInput }}`

### Step 3: Add Reranking with Code

1. Add **Code** node for LLM-based reranking
2. Implement reranking logic:

```javascript
const query = $('Chat Trigger').first().json.chatInput;
const documents = $input.all().map(item => ({
  content: item.json.document.pageContent,
  metadata: item.json.document.metadata,
  initialScore: item.json.score
}));

// Prepare reranking prompt
const rerankPrompt = `Query: "${query}"

Rate each document's relevance to the query on a scale of 0-10.
Return ONLY a JSON array of scores in the same order.

Documents:
${documents.map((d, i) => `[${i}] ${d.content.substring(0, 300)}...`).join('\n\n')}

Respond with JSON array only, e.g., [8, 3, 9, 2, ...]`;

return [{
  json: {
    query,
    documents,
    rerankPrompt
  }
}];
```

### Step 4: Call LLM for Reranking

1. Add **OpenAI Chat Model** node
2. Send the reranking prompt
3. Parse the scores

### Step 5: Select Top Results

```javascript
const scores = JSON.parse($input.first().json.message.content);
const documents = $('Code').first().json.documents;

// Combine and sort by rerank score
const reranked = documents
  .map((doc, i) => ({ ...doc, rerankScore: scores[i] }))
  .sort((a, b) => b.rerankScore - a.rerankScore)
  .slice(0, 3);  // Keep top 3

return [{
  json: {
    rerankedDocuments: reranked
  }
}];
```

### Step 6: Generate Final Response

Connect to AI Agent with reranked context.

---

## Hybrid Search Pattern

Combine vector search with keyword search:

```
┌─────────────────────────────────────────────────────────┐
│                    Hybrid Search                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│   Query: "Salesforce API authentication"                │
│              │                                          │
│       ┌──────┴──────┐                                   │
│       ▼             ▼                                   │
│   Vector        Keyword                                 │
│   Search        Search (BM25)                           │
│       │             │                                   │
│       └──────┬──────┘                                   │
│              ▼                                          │
│         Reciprocal Rank                                 │
│            Fusion                                       │
│              │                                          │
│              ▼                                          │
│        Combined Results                                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

**Reciprocal Rank Fusion (RRF):**
```
RRF_score = Σ 1/(k + rank_i)
```
Where k is typically 60.

---

## Exercises

### Exercise 3.1: Chunking Experiment

1. Ingest the same document with different chunk sizes (200, 500, 1000)
2. Query with the same question
3. Compare retrieval quality

### Exercise 3.2: Metadata Filtering

Modify Lab 3.2 to:
1. Add metadata during ingestion (category, date, source)
2. Filter retrieval by metadata
3. Test category-specific queries

---

## Common Issues

| Issue                   | Solution                                   |
|-------------------------|--------------------------------------------|
| Irrelevant results      | Reduce chunk size, add reranking           |
| Missing relevant docs   | Increase Top K, check embedding model      |
| Slow ingestion          | Batch embeddings, use async processing     |
| Qdrant connection error | Verify `http://qdrant:6333` from container |

---

## Key Takeaways

1. **RAG grounds LLMs** in your specific data
2. **Chunk size matters** - 300-800 tokens is usually optimal
3. **Over-fetch and rerank** produces better results than direct Top-K
4. **Hybrid search** combines semantic and keyword matching
5. **Metadata** enables powerful filtering and organization

---

## Next Module

Continue to [Module 4: Advanced Agents & Reliability](MODULE-04-advanced-agents.md) to learn about hallucinations and production-ready agents.
