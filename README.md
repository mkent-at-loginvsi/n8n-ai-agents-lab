# 🤖 Creating AI Agents with Self-Hosted n8n

A hands-on 2-hour workshop for mid-level software engineers and QA professionals.

## Workshop Overview

This lab teaches you to build production-ready AI Agents using self-hosted n8n. You'll progress from basic LLM integrations to sophisticated agents with memory, RAG pipelines, and intelligent context management.

**Duration:** 2 hours  
**Level:** Intermediate  
**Prerequisites:** Basic familiarity with APIs, JSON, and workflow concepts

---

## 🎯 Learning Objectives

By the end of this workshop, you will be able to:

1. Deploy and configure a self-hosted n8n instance with AI capabilities
2. Understand the architecture and components of AI Agents
3. Implement conversation memory and context management
4. Build RAG (Retrieval-Augmented Generation) pipelines
5. Apply reranking strategies to improve retrieval quality
6. Recognize and mitigate LLM hallucinations
7. Design multi-tool agents for complex workflows

---

## 📚 Syllabus

### Module 1: Foundations (25 minutes)
| Topic | Duration | Type |
|-------|----------|------|
| What are AI Agents? Architecture & Components | 10 min | Lecture |
| Lab 1.1: Your First AI Chain | 10 min | Hands-on |
| Lab 1.2: Adding Tools to Your Agent | 5 min | Hands-on |

**Key Concepts:** Agents vs Chains, Tool Calling, System Prompts, Temperature

### Module 2: Memory & Context (30 minutes)
| Topic | Duration | Type |
|-------|----------|------|
| Understanding Memory Types | 10 min | Lecture |
| Lab 2.1: Conversation Memory | 10 min | Hands-on |
| Lab 2.2: Window Memory & Token Management | 10 min | Hands-on |

**Key Concepts:** Buffer Memory, Window Memory, Summary Memory, Token Limits, Context Window

### Module 3: RAG & Reranking (35 minutes)
| Topic | Duration | Type |
|-------|----------|------|
| RAG Architecture Deep Dive | 10 min | Lecture |
| Lab 3.1: Document Ingestion Pipeline | 10 min | Hands-on |
| Lab 3.2: Vector Search Agent | 10 min | Hands-on |
| Lab 3.3: Implementing Reranking | 5 min | Hands-on |

**Key Concepts:** Embeddings, Vector Stores, Chunking, Semantic Search, Reranking, Hybrid Search

### Module 4: Advanced Agents & Reliability (30 minutes)
| Topic | Duration | Type |
|-------|----------|------|
| Hallucinations: Detection & Mitigation | 10 min | Lecture |
| Lab 4.1: Grounded Agent with Citations | 10 min | Hands-on |
| Lab 4.2: Multi-Tool Production Agent | 10 min | Hands-on |

**Key Concepts:** Hallucination Types, Grounding, Citations, Error Handling, Agent Loops

---

## 🗂 Repository Structure

```
n8n-ai-agents-lab/
├── README.md                          # This file
├── docker-compose.yml                 # n8n + dependencies stack
├── .env.example                       # Environment variables template
├── docs/
│   ├── SETUP.md                       # Detailed setup instructions
│   ├── MODULE-01-fundamentals.md      # Module 1 content
│   ├── MODULE-02-memory-context.md    # Module 2 content
│   ├── MODULE-03-rag-reranking.md     # Module 3 content
│   └── MODULE-04-advanced-agents.md   # Module 4 content
├── workflows/
│   ├── 01-basic-ai-chain.json         # Lab 1.1
│   ├── 02-agent-with-tools.json       # Lab 1.2
│   ├── 03-conversation-memory.json    # Lab 2.1
│   ├── 04-window-memory.json          # Lab 2.2
│   ├── 05-document-ingestion.json     # Lab 3.1
│   ├── 06-vector-search-agent.json    # Lab 3.2
│   ├── 07-reranking-pipeline.json     # Lab 3.3
│   ├── 08-grounded-agent.json         # Lab 4.1
│   └── 09-multi-tool-agent.json       # Lab 4.2
├── data/
│   └── sample-docs/                   # Sample documents for RAG labs
│       ├── product-manual.md
│       └── faq.md
└── scripts/
    ├── setup-check.sh                 # Validates environment
    └── import-workflows.sh            # Bulk workflow import helper
```

---

## ⚡ Quick Start

```bash
# 1. Clone this repository
git clone https://github.com/your-org/n8n-ai-agents-lab.git
cd n8n-ai-agents-lab

# 2. Copy and configure environment
cp .env.example .env
# Edit .env with your API keys

# 3. Start the stack
docker compose up -d

# 4. Access n8n
open http://localhost:5678
```

See [docs/SETUP.md](docs/SETUP.md) for detailed setup instructions.

---

## 🔑 Required API Keys

You'll need at least one LLM provider configured:

| Provider | Purpose | Get Key |
|----------|---------|---------|
| OpenAI | GPT-4, Embeddings | [platform.openai.com](https://platform.openai.com) |
| Anthropic | Claude models | [console.anthropic.com](https://console.anthropic.com) |
| Ollama | Local models (optional) | Self-hosted |

---

## 📖 How to Use This Lab

1. **Start with Setup:** Complete the environment setup in [SETUP.md](docs/SETUP.md)
2. **Follow Modules in Order:** Each module builds on previous concepts
3. **Import Workflows:** Use the JSON files in `/workflows` as starting points
4. **Experiment:** Modify workflows and observe behavior changes
5. **Check Solutions:** Each lab includes expected outputs and common issues

---

## 🛠 Technology Stack

- **n8n** (v1.70+) - Workflow automation platform
- **Qdrant** - Vector database for RAG
- **PostgreSQL** - n8n persistence + memory storage
- **Redis** - Caching layer (optional)

---

## 📝 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🤝 Contributing

Contributions welcome! Please read our contributing guidelines before submitting PRs.
