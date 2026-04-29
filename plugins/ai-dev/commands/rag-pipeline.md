---
description: "Build a complete production RAG pipeline: document ingestion, embedding selection, vector store, hybrid search, reranking, and RAG prompt. Use when building knowledge bases, document Q&A, or any retrieval-augmented system."
argument-hint: "<use-case> [vector-db] [embedding-model]"
---

# RAG Pipeline Builder

You are an expert in building production RAG systems. Design and implement a complete pipeline covering ingestion, retrieval, and generation.

## Requirements

$ARGUMENTS

## Step 1 — Choose Your Stack

Select based on scale and use case:

| Component | < 1M docs | 1M–10M docs | Enterprise |
|-----------|-----------|-------------|------------|
| Vector DB | Chroma | Qdrant | Pinecone |
| Embeddings | `voyage-3-large` | `voyage-3-large` | `voyage-3-large` |
| Search | Dense only | Hybrid | Hybrid + rerank |

**Always use `voyage-3-large` for Claude apps** (Anthropic-recommended).
Domain variants: `voyage-code-3` (code), `voyage-finance-2` (finance), `voyage-law-2` (legal).

## Step 2 — Document Ingestion

```python
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_voyageai import VoyageAIEmbeddings

# Chunking (500-1000 tokens, 10-20% overlap)
splitter = RecursiveCharacterTextSplitter(
    chunk_size=800,
    chunk_overlap=100,
    separators=["\n\n", "\n", ". ", " ", ""]
)

embeddings = VoyageAIEmbeddings(model="voyage-3-large")

async def ingest(file_paths: list[str], vectorstore) -> int:
    docs = []
    for path in file_paths:
        loader = get_loader(path)  # PDF, DOCX, HTML, MD
        docs.extend(loader.load())

    chunks = splitter.split_documents(docs)
    for i, chunk in enumerate(chunks):
        chunk.metadata["chunk_id"] = i
        chunk.metadata["ingested_at"] = datetime.now().isoformat()

    # Batch embed and store
    for batch in batched(chunks, 100):
        await vectorstore.aadd_documents(batch)
    return len(chunks)
```

## Step 3 — Hybrid Search + Reranking

```python
from langchain_pinecone import PineconeVectorStore
from langchain_cohere import CohereRerank
from langchain.retrievers import ContextualCompressionRetriever

vectorstore = PineconeVectorStore(index=index, embedding=embeddings)

# Base retriever: hybrid (dense + sparse BM25), retrieve top 20
base_retriever = vectorstore.as_retriever(
    search_type="hybrid",
    search_kwargs={"k": 20, "alpha": 0.5}  # alpha: 0=BM25, 1=dense
)

# Reranker: compress to top 5 most relevant
reranker = CohereRerank(model="rerank-3", top_n=5)
retriever = ContextualCompressionRetriever(
    base_compressor=reranker,
    base_retriever=base_retriever
)
```

## Step 4 — RAG Chain

```python
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

RAG_PROMPT = ChatPromptTemplate.from_template("""
You are a helpful assistant. Answer based solely on the provided context.

## Context
{context}

## Question
{question}

## Instructions
- Base your answer only on the context above
- Cite sources as [Doc N] when referencing specific passages
- If the context doesn't contain enough information, say so clearly
- Be concise and accurate

Answer:
""")

llm = ChatAnthropic(model="claude-sonnet-4-6")

def format_docs(docs):
    return "\n\n".join(
        f"[Doc {i+1}] {doc.page_content}"
        for i, doc in enumerate(docs)
    )

rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | RAG_PROMPT
    | llm
)
```

## Step 5 — Advanced Patterns (when needed)

**HyDE** (better retrieval for abstract queries):
```python
hyde_prompt = "Generate a hypothetical document answering: {question}"
hypothetical = llm.invoke(hyde_prompt.format(question=query))
results = vectorstore.similarity_search(hypothetical.content)
```

**Query expansion** (multi-perspective retrieval):
```python
expansion_prompt = "Generate 3 search queries to answer: {question}\nQueries:"
queries = llm.invoke(expansion_prompt.format(question=query))
all_results = [retriever.invoke(q) for q in parse_queries(queries)]
# Apply Reciprocal Rank Fusion across results
```

## Step 6 — Evaluation

```python
from ragas import evaluate
from ragas.metrics import faithfulness, answer_relevancy, context_precision, context_recall

result = evaluate(
    dataset,
    metrics=[faithfulness, answer_relevancy, context_precision, context_recall],
    llm=llm,
)
# Targets: faithfulness > 0.85, answer_relevancy > 0.80, context_precision > 0.75
```

## Implementation Checklist

- [ ] Embedding model matches use case (voyage-3-large default)
- [ ] Chunk size 500-1000 tokens with 10-20% overlap
- [ ] Hybrid search configured (alpha=0.5 as starting point)
- [ ] Reranker reduces candidates from 20 → 5
- [ ] RAG prompt instructs citation and gap acknowledgment
- [ ] Batch ingestion with metadata (chunk_id, source, date)
- [ ] RAGAS evaluation on 50+ representative queries
- [ ] Redis cache for repeated queries (TTL=1h)
- [ ] LangSmith tracing enabled

## Output

Deliver:
1. **Ingestion pipeline** with chunking and batch embedding
2. **Retriever** with hybrid search + reranking configured
3. **RAG chain** with citation-aware prompt
4. **Evaluation setup** with RAGAS metrics
5. **Vector store config** for the chosen database
