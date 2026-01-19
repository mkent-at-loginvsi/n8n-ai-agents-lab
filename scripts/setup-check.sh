#!/bin/bash
# =============================================================================
# Setup Check Script for n8n AI Agents Lab
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "=============================================="
echo "  n8n AI Agents Lab - Setup Verification"
echo "=============================================="
echo ""

ERRORS=0

# Check Docker
echo -n "Checking Docker... "
if command -v docker &> /dev/null && docker info &> /dev/null; then
    DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | tr -d ',')
    echo -e "${GREEN}✓${NC} (v$DOCKER_VERSION)"
else
    echo -e "${RED}✗ Docker is not running${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check Docker Compose
echo -n "Checking Docker Compose... "
if command -v docker &> /dev/null && docker compose version &> /dev/null; then
    COMPOSE_VERSION=$(docker compose version --short)
    echo -e "${GREEN}✓${NC} (v$COMPOSE_VERSION)"
else
    echo -e "${RED}✗ Docker Compose not available${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check .env file
echo -n "Checking .env file... "
if [ -f ".env" ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${YELLOW}⚠ .env file not found (copy from .env.example)${NC}"
fi

# Check required environment variables
echo -n "Checking N8N_ENCRYPTION_KEY... "
if [ -f ".env" ] && grep -q "N8N_ENCRYPTION_KEY=.\+" .env 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Not configured${NC}"
    ERRORS=$((ERRORS + 1))
fi

echo -n "Checking API keys... "
if [ -f ".env" ]; then
    if grep -q "OPENAI_API_KEY=sk-" .env 2>/dev/null || grep -q "ANTHROPIC_API_KEY=sk-ant-" .env 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${YELLOW}⚠ No LLM API key configured${NC}"
    fi
else
    echo -e "${YELLOW}⚠ Cannot check (no .env file)${NC}"
fi

echo ""
echo "Checking running services..."
echo ""

# Check n8n
echo -n "n8n (http://localhost:5678)... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:5678 | grep -q "200\|302"; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not accessible${NC}"
fi

# Check Qdrant
echo -n "Qdrant (http://localhost:6333)... "
if curl -s -o /dev/null -w "%{http_code}" http://localhost:6333 | grep -q "200"; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not accessible${NC}"
fi

# Check PostgreSQL
echo -n "PostgreSQL (localhost:5432)... "
if command -v docker &> /dev/null && docker compose ps postgres 2>/dev/null | grep -q "running"; then
    echo -e "${GREEN}✓ Running${NC}"
elif nc -z localhost 5432 2>/dev/null; then
    echo -e "${GREEN}✓ Running${NC}"
else
    echo -e "${YELLOW}⚠ Not accessible${NC}"
fi

echo ""
echo "=============================================="

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All critical checks passed!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Start services: docker compose up -d"
    echo "  2. Open n8n: http://localhost:5678"
    echo "  3. Configure credentials in n8n"
    echo "  4. Import workflows from /workflows"
else
    echo -e "${RED}$ERRORS critical issue(s) found.${NC}"
    echo "Please resolve the issues above before proceeding."
    exit 1
fi

echo "=============================================="
