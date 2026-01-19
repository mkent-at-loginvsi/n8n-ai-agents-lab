#!/bin/bash
# =============================================================================
# Workflow Import Helper for n8n AI Agents Lab
# =============================================================================
# This script helps import all lab workflows into n8n
# Note: You'll still need to configure credentials manually after import
# =============================================================================

set -e

N8N_URL="${N8N_URL:-http://localhost:5678}"
WORKFLOWS_DIR="./workflows"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=============================================="
echo "  n8n Workflow Import Helper"
echo "=============================================="
echo ""

# Check if n8n is running
echo -n "Checking n8n availability... "
if ! curl -s -o /dev/null -w "%{http_code}" "$N8N_URL" | grep -q "200\|302"; then
    echo -e "${RED}✗${NC}"
    echo "Error: n8n is not accessible at $N8N_URL"
    echo "Please start n8n first: docker compose up -d"
    exit 1
fi
echo -e "${GREEN}✓${NC}"
echo ""

# Check for workflow files
if [ ! -d "$WORKFLOWS_DIR" ]; then
    echo "Error: Workflows directory not found at $WORKFLOWS_DIR"
    exit 1
fi

WORKFLOW_COUNT=$(find "$WORKFLOWS_DIR" -name "*.json" | wc -l)
if [ "$WORKFLOW_COUNT" -eq 0 ]; then
    echo "No workflow files found in $WORKFLOWS_DIR"
    exit 1
fi

echo "Found $WORKFLOW_COUNT workflow(s) to import"
echo ""

# Instructions
echo "=============================================="
echo "  Manual Import Instructions"
echo "=============================================="
echo ""
echo "Since n8n API requires authentication, please import"
echo "workflows manually through the UI:"
echo ""
echo "1. Open n8n at: $N8N_URL"
echo "2. Click the '+' button to create a new workflow"
echo "3. Click the '...' menu → Import from File"
echo "4. Select each workflow file from:"
echo "   $WORKFLOWS_DIR/"
echo ""
echo "Workflows to import:"
echo ""

for workflow in "$WORKFLOWS_DIR"/*.json; do
    if [ -f "$workflow" ]; then
        name=$(basename "$workflow" .json)
        # Extract workflow name from JSON if possible
        json_name=$(grep -o '"name": *"[^"]*"' "$workflow" | head -1 | cut -d'"' -f4)
        if [ -n "$json_name" ]; then
            echo "  ☐ $name.json"
            echo "    → $json_name"
        else
            echo "  ☐ $name.json"
        fi
        echo ""
    fi
done

echo "=============================================="
echo ""
echo -e "${YELLOW}Important:${NC} After importing, you'll need to:"
echo "  1. Configure credentials for each workflow"
echo "  2. Update any file paths if different from defaults"
echo "  3. Test each workflow before the lab session"
echo ""
echo "=============================================="

# Optional: Open n8n in browser
read -p "Open n8n in your browser? (y/n) " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v open &> /dev/null; then
        open "$N8N_URL"
    elif command -v xdg-open &> /dev/null; then
        xdg-open "$N8N_URL"
    else
        echo "Please open $N8N_URL in your browser"
    fi
fi
