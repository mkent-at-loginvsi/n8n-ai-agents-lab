# Setup Guide

Complete setup instructions for the AI Agents Lab environment.

---

## System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| CPU | 4 cores | 8 cores |
| RAM | 8 GB | 16 GB |
| Disk | 20 GB free | 50 GB free |
| Docker | v24.0+ | Latest |
| Docker Compose | v2.20+ | Latest |

---

## Step 1: Install Docker

### macOS
```bash
# Using Homebrew
brew install --cask docker

# Start Docker Desktop, then verify
docker --version
docker compose version
```

### Linux (Ubuntu/Debian)
```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Log out and back in, then verify
docker --version
docker compose version
```

### Windows
Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop/) and enable WSL2 backend.

---

## Step 2: Clone Repository

```bash
git clone https://github.com/your-org/n8n-ai-agents-lab.git
cd n8n-ai-agents-lab
```

---

## Step 3: Configure Environment Variables

```bash
# Copy the template
cp .env.example .env
```

Edit `.env` with your preferred editor:

```bash
# Required: Choose at least one LLM provider
OPENAI_API_KEY=sk-...          # For GPT-4 and embeddings
ANTHROPIC_API_KEY=sk-ant-...   # For Claude models

# n8n Configuration
N8N_ENCRYPTION_KEY=your-32-char-random-string-here
N8N_USER_MANAGEMENT_JWT_SECRET=another-random-secret-here

# Database (defaults work for local development)
POSTGRES_PASSWORD=changeme_in_production
```

### Generate Secure Keys

```bash
# Generate encryption key
openssl rand -hex 16

# Generate JWT secret  
openssl rand -hex 32
```

---

## Step 4: Start the Stack

```bash
# Start all services in background
docker compose up -d

# Watch logs (optional)
docker compose logs -f n8n
```

### Services Started

| Service | URL | Purpose |
|---------|-----|---------|
| n8n | http://localhost:5678 | Workflow editor |
| Qdrant | http://localhost:6333 | Vector database UI |
| PostgreSQL | localhost:5432 | Data persistence |

---

## Step 5: Initial n8n Setup

1. Open http://localhost:5678 in your browser
2. Create your owner account (first-time only)
3. Complete the setup wizard

### Configure Credentials

Navigate to **Settings → Credentials** and add:

#### OpenAI Credential
- **Name:** `OpenAI`
- **API Key:** Your OpenAI API key

#### Anthropic Credential (optional)
- **Name:** `Anthropic`
- **API Key:** Your Anthropic API key

#### Qdrant Credential
- **Name:** `Qdrant Local`
- **API URL:** `http://qdrant:6333`
- **API Key:** (leave empty for local)

---

## Step 6: Verify Installation

Run the setup check script:

```bash
./scripts/setup-check.sh
```

Expected output:
```
✓ Docker is running
✓ n8n is accessible at http://localhost:5678
✓ Qdrant is accessible at http://localhost:6333
✓ PostgreSQL is accepting connections
✓ Environment variables configured
```

### Manual Verification

1. In n8n, create a new workflow
2. Add an **AI Agent** node
3. Verify you can select your configured LLM credential
4. Add a **Chat Trigger** node
5. Execute the workflow and send a test message

---

## Importing Lab Workflows

### Method 1: Manual Import

1. In n8n, click **Add Workflow** → **Import from File**
2. Select a JSON file from the `/workflows` directory
3. Review and save the workflow

### Method 2: Bulk Import Script

```bash
./scripts/import-workflows.sh
```

This imports all lab workflows with appropriate naming.

---

## Troubleshooting

### n8n Won't Start

```bash
# Check logs
docker compose logs n8n

# Common fix: Reset permissions
sudo chown -R 1000:1000 ./n8n-data
```

### "Credential not found" Errors

After importing workflows, you must reconnect credentials:
1. Open the workflow
2. Click on nodes showing credential errors
3. Select your configured credential from the dropdown
4. Save the workflow

### Qdrant Connection Failed

```bash
# Verify Qdrant is running
docker compose ps qdrant

# Check Qdrant logs
docker compose logs qdrant

# Restart if needed
docker compose restart qdrant
```

### Out of Memory

If you see OOM errors, increase Docker's memory limit:
- **Docker Desktop:** Settings → Resources → Memory → 8GB+
- **Linux:** No limit by default, check system RAM

### Port Conflicts

If ports are in use, modify `docker-compose.yml`:

```yaml
services:
  n8n:
    ports:
      - "5679:5678"  # Change external port
```

---

## Optional: Local LLM with Ollama

For fully offline operation, add Ollama:

```bash
# Add to docker-compose.yml or run separately
docker run -d -v ollama:/root/.ollama -p 11434:11434 --name ollama ollama/ollama

# Pull a model
docker exec ollama ollama pull llama3.1:8b
docker exec ollama ollama pull nomic-embed-text  # For embeddings
```

Configure in n8n:
- **Ollama Credential → Base URL:** `http://host.docker.internal:11434`

---

## Clean Up

```bash
# Stop all services
docker compose down

# Stop and remove all data (destructive!)
docker compose down -v
```

---

## Next Steps

Once setup is complete, proceed to [Module 1: Foundations](MODULE-01-fundamentals.md).
