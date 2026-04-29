---
description: "Bootstrap a new AI project with correct LangChain/LangGraph/LangSmith packages, versions, environment configuration, and project structure. Use when starting a new AI project, setting up a new environment, or resolving dependency conflicts."
argument-hint: "<project-type> [python|typescript]"
---

# AI Project Setup

You are an expert in LangChain ecosystem dependencies and environment configuration. Bootstrap a production-ready AI project with correct packages, versions, and structure.

## Project requirements

$ARGUMENTS

## Python Setup

### Core packages (always install)

```bash
pip install \
  langchain>=0.3.0 \
  langchain-core>=0.3.0 \
  langchain-anthropic>=0.3.0 \
  langgraph>=0.3.0 \
  langsmith>=0.2.0
```

### By use case

```bash
# RAG + Vector Search
pip install \
  langchain-voyageai \        # Voyage AI embeddings (recommended for Claude)
  langchain-pinecone \        # Pinecone vector store
  langchain-chroma \          # Chroma (local dev)
  langchain-cohere \          # Cohere reranking
  ragas                       # RAG evaluation

# Multi-model
pip install langchain-openai langchain-google-genai

# Production serving
pip install fastapi uvicorn redis pydantic>=2.0

# Observability
pip install prometheus-client structlog opentelemetry-sdk

# Data processing
pip install pypdf docx2txt beautifulsoup4 tiktoken
```

### Minimum versions (breaking changes above these)

| Package | Min version | Notes |
|---------|-------------|-------|
| `langchain` | 0.3.0 | Stable LCEL interface |
| `langchain-core` | 0.3.0 | Must match langchain |
| `langgraph` | 0.3.0 | StateGraph API stable |
| `langsmith` | 0.2.0 | New evaluation API |
| `pydantic` | 2.0 | Required by all above |

### Environment variables

```bash
# .env (never commit)
ANTHROPIC_API_KEY=sk-ant-...
LANGCHAIN_TRACING_V2=true
LANGCHAIN_PROJECT=my-project
LANGCHAIN_API_KEY=ls__...

# Optional by stack
PINECONE_API_KEY=...
VOYAGE_API_KEY=...
COHERE_API_KEY=...
OPENAI_API_KEY=...
REDIS_URL=redis://localhost:6379
```

### Project structure

```
my-ai-project/
├── src/
│   ├── agents/          # LangGraph agent definitions
│   ├── chains/          # LCEL chains
│   ├── tools/           # Tool implementations
│   ├── retrievers/      # RAG retrievers
│   ├── prompts/         # Prompt templates
│   └── evaluation/      # Eval datasets and runners
├── tests/
│   ├── unit/
│   ├── integration/
│   └── eval/            # LangSmith eval scripts
├── .env
├── .env.example         # committed, no secrets
├── pyproject.toml
└── README.md
```

### `pyproject.toml` (recommended)

```toml
[tool.poetry]
name = "my-ai-project"
version = "0.1.0"
python = "^3.11"

[tool.poetry.dependencies]
langchain = "^0.3.0"
langchain-core = "^0.3.0"
langchain-anthropic = "^0.3.0"
langgraph = "^0.3.0"
langsmith = "^0.2.0"
pydantic = "^2.0"

[tool.poetry.group.dev.dependencies]
pytest = "^8.0"
pytest-asyncio = "^0.23"
```

## TypeScript Setup

```bash
npm install \
  @langchain/core \
  @langchain/langgraph \
  @langchain/anthropic \
  langsmith \
  zod
```

### `package.json` versions

```json
{
  "dependencies": {
    "@langchain/core": "^0.3.0",
    "@langchain/langgraph": "^0.2.0",
    "@langchain/anthropic": "^0.3.0",
    "langsmith": "^0.2.0",
    "zod": "^3.22.0"
  }
}
```

### `tsconfig.json`

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "NodeNext",
    "moduleResolution": "NodeNext",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true
  }
}
```

## Verify Installation

```python
# verify.py — run after install
import langchain, langgraph, langsmith
from langchain_anthropic import ChatAnthropic

print(f"langchain: {langchain.__version__}")
print(f"langgraph: {langgraph.__version__}")
print(f"langsmith: {langsmith.__version__}")

# Test API connection
llm = ChatAnthropic(model="claude-haiku-4-5-20251001")
response = llm.invoke("Say 'setup OK' and nothing else.")
print(response.content)
```

## Common Dependency Issues

| Error | Fix |
|-------|-----|
| `pydantic.errors.PydanticUserError` | Upgrade to pydantic>=2.0 |
| `ImportError: cannot import 'LCEL'` | Upgrade langchain-core>=0.3.0 |
| `TypeError in StateGraph` | Upgrade langgraph>=0.3.0 |
| `langsmith tracing not showing` | Set `LANGCHAIN_TRACING_V2=true` |
| Version conflicts between langchain packages | Pin all `langchain-*` to same minor version |

## Output

Deliver:
1. **Complete `requirements.txt` or `pyproject.toml`** for the project type
2. **`.env.example`** with all required keys documented
3. **Project directory structure** ready to populate
4. **Verification script** to confirm the stack works
5. **Common gotchas** specific to the chosen stack
