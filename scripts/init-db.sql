-- =============================================================================
-- Database Initialization Script for n8n AI Agents Lab
-- =============================================================================
-- This script creates additional tables needed for the lab exercises
-- The main n8n tables are created automatically by n8n
-- =============================================================================

-- Chat memory table for Postgres-backed conversation memory
CREATE TABLE IF NOT EXISTS chat_memories (
    id SERIAL PRIMARY KEY,
    session_id VARCHAR(255) NOT NULL,
    message_type VARCHAR(50) NOT NULL,  -- 'human' or 'ai'
    content TEXT NOT NULL,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for fast session lookups
CREATE INDEX IF NOT EXISTS idx_chat_memories_session_id 
    ON chat_memories(session_id);

-- Index for time-based queries
CREATE INDEX IF NOT EXISTS idx_chat_memories_created_at 
    ON chat_memories(created_at DESC);

-- Composite index for session + time queries
CREATE INDEX IF NOT EXISTS idx_chat_memories_session_time 
    ON chat_memories(session_id, created_at DESC);

-- =============================================================================
-- Analytics and logging tables (optional, for Module 4)
-- =============================================================================

-- Agent execution logs
CREATE TABLE IF NOT EXISTS agent_executions (
    id SERIAL PRIMARY KEY,
    workflow_id VARCHAR(255),
    execution_id VARCHAR(255),
    agent_type VARCHAR(100),
    user_query TEXT,
    response TEXT,
    tools_used JSONB DEFAULT '[]',
    iteration_count INTEGER DEFAULT 0,
    execution_time_ms INTEGER,
    token_count INTEGER,
    success BOOLEAN DEFAULT TRUE,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for workflow analytics
CREATE INDEX IF NOT EXISTS idx_agent_executions_workflow 
    ON agent_executions(workflow_id, created_at DESC);

-- Index for error tracking
CREATE INDEX IF NOT EXISTS idx_agent_executions_errors 
    ON agent_executions(success, created_at DESC) 
    WHERE success = FALSE;

-- =============================================================================
-- Functions
-- =============================================================================

-- Function to clean old chat memories (call periodically)
CREATE OR REPLACE FUNCTION cleanup_old_memories(retention_days INTEGER DEFAULT 7)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM chat_memories 
    WHERE created_at < NOW() - (retention_days || ' days')::INTERVAL;
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get conversation history for a session
CREATE OR REPLACE FUNCTION get_conversation_history(
    p_session_id VARCHAR(255),
    p_limit INTEGER DEFAULT 20
)
RETURNS TABLE (
    message_type VARCHAR(50),
    content TEXT,
    created_at TIMESTAMP WITH TIME ZONE
) AS $$
BEGIN
    RETURN QUERY
    SELECT cm.message_type, cm.content, cm.created_at
    FROM chat_memories cm
    WHERE cm.session_id = p_session_id
    ORDER BY cm.created_at DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- Sample data for testing (optional)
-- =============================================================================

-- Uncomment to insert test data:
/*
INSERT INTO chat_memories (session_id, message_type, content) VALUES
    ('test_session_001', 'human', 'Hello, my name is Alex'),
    ('test_session_001', 'ai', 'Hello Alex! Nice to meet you. How can I help you today?'),
    ('test_session_001', 'human', 'I am learning about AI agents'),
    ('test_session_001', 'ai', 'That is great! AI agents are fascinating. They combine LLMs with tools and memory to perform complex tasks autonomously.');
*/

-- =============================================================================
-- Grants (adjust as needed for your security requirements)
-- =============================================================================

-- Grant permissions to n8n user (if different from postgres owner)
-- GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO n8n;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO n8n;
