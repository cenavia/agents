# ai-dev

Toolkit de Claude Code para construir aplicaciones de IA en producción. Cubre el ciclo completo: setup → agentes → RAG → evaluación → deployment.

---

## Instalación

```bash
claude --plugin-dir ./ai-dev
```

Para usarlo en cualquier proyecto:

```bash
claude --plugin-dir /ruta/absoluta/ai-dev
```

---

## Componentes

El toolkit tiene tres capas con responsabilidades distintas:

| Capa | Qué es | Cuándo usar |
|------|--------|-------------|
| **Commands** | Slash commands que generan implementaciones completas | Cuando quieres construir algo nuevo |
| **Skills** | Referencia técnica que Claude inyecta automáticamente | Cuando estás escribiendo código LangGraph/RAG |
| **Agents** | Subagentes especializados para trabajo sostenido | Cuando necesitas un experto en un dominio específico |

---

## Nivel 1 — Proyecto nuevo desde cero

El punto de partida para cualquier proyecto AI.

### `/ai-dev:project-setup`

```
/ai-dev:project-setup python rag-system con Pinecone y LangSmith
```

Genera:
- `pyproject.toml` con versiones compatibles de todos los paquetes
- `.env.example` con todas las variables de entorno documentadas
- Estructura de directorios lista para producción
- Script de verificación para confirmar que el stack funciona

**Variante TypeScript:**

```
/ai-dev:project-setup typescript agente LangGraph con persistencia
```

---

## Nivel 2 — Construir el sistema

### Agente conversacional con herramientas

```
/ai-dev:langchain-agent agente de soporte técnico con acceso a base de conocimiento y escalamiento a humanos
```

Genera un agente LangGraph completo con:
- StateGraph con nodos de razonamiento y ejecución de herramientas
- Memoria de conversación con checkpointer
- Tracing con LangSmith habilitado
- Servidor FastAPI con streaming
- Manejo de errores con retry policy

### Pipeline RAG para base de conocimiento

```
/ai-dev:rag-pipeline knowledge base de documentación técnica con Pinecone, búsqueda híbrida y citaciones
```

Genera:
- Pipeline de ingestión con chunking recursivo (800 tokens, 10% overlap)
- Embeddings con `voyage-3-large` (recomendado para Claude)
- Búsqueda híbrida vector + BM25 con alpha=0.5
- Reranking con Cohere Rerank-3 (20 candidatos → 5 finales)
- Prompt RAG con instrucciones de citación

**Variante por dominio:**

```
/ai-dev:rag-pipeline sistema de búsqueda de código Python con voyage-code-3 y Chroma local
```

### AI Assistant con NLU y flujos de conversación

```
/ai-dev:ai-assistant asistente de atención al cliente para e-commerce con manejo de pedidos y devoluciones
```

Genera:
- Pipeline NLP con detección de intenciones y extracción de entidades
- Motor de flujos de conversación con slot-filling
- Generador de respuestas híbrido (templates + LLM)
- Configuración Docker + Kubernetes con autoscaling

---

## Nivel 3 — Características avanzadas

### Agregar aprobación humana a un agente existente

Cuando un agente ejecuta acciones irreversibles (enviar emails, modificar base de datos, llamar APIs externas):

```
/ai-dev:hitl-workflow agente de email marketing que necesita aprobación antes de enviar campañas
```

Genera los tres patrones según el caso:

**Approval gate** — para acciones de alto riesgo:
```python
def review_node(state) -> Command[Literal["execute", "__end__"]]:
    decision = interrupt({
        "message": "Revisar antes de enviar",
        "campaign": state["campaign_draft"],
        "recipients": state["recipient_count"],
    })
    if decision.get("approved"):
        return Command(update={"approved": True}, goto="execute")
    return Command(goto=END)
```

**Slot filling** — para recolectar información faltante:
```python
def gather_info(state):
    while not state.get("deadline"):
        value = interrupt({"prompt": "¿Cuál es la fecha límite?"})
        if validate_date(value):
            state["deadline"] = value
    return state
```

**Validation loop** — para validar formato de entrada:
```python
def validate_input(state):
    prompt = "Ingresa un email válido:"
    while True:
        answer = interrupt(prompt)
        if re.match(EMAIL_PATTERN, answer):
            return {"email": answer}
        prompt = f"'{answer}' no es válido. Intenta de nuevo:"
```

### Agregar persistencia a un agente existente

Los skills se activan automáticamente cuando escribes código LangGraph. Por ejemplo, al escribir código con `StateGraph`, el skill `langgraph-persistence` se inyecta en contexto y Claude sugerirá el patrón correcto:

```python
# Claude detecta que necesitas checkpointer y sugiere automáticamente:
from langgraph.checkpoint.postgres import PostgresSaver

checkpointer = PostgresSaver.from_conn_string(os.environ["DATABASE_URL"])
graph = builder.compile(checkpointer=checkpointer)

# Cada conversación aislada por thread_id
config = {"configurable": {"thread_id": user_session_id}}
result = await graph.ainvoke(message, config)
```

---

## Nivel 4 — Evaluación y calidad

### Configurar pipeline de evaluación completo

```
/ai-dev:eval-setup sistema RAG de documentación técnica
```

Genera:
- Dataset de evaluación con distribución correcta (50% típicos, 25% edge cases, 15% adversariales, 10% out-of-scope)
- Métricas RAGAS: faithfulness, answer_relevancy, context_precision, context_recall
- LLM-as-judge para calidad general
- Detector de regresiones para CI/CD

```python
# Gate de calidad en CI — falla el deploy si hay regresión > 5%
detector = RegressionDetector(baseline=load_baseline())
result = await detector.check(new_system)
assert result["passed"], f"Regresiones: {result['regressions']}"
```

**Umbrales de calidad recomendados:**

| Métrica | Target | Alerta |
|---------|--------|--------|
| Faithfulness | > 0.85 | < 0.80 |
| Answer Relevancy | > 0.80 | < 0.75 |
| Context Precision | > 0.75 | < 0.70 |
| Context Recall | > 0.80 | < 0.75 |

### Optimizar un prompt existente

```
/ai-dev:prompt-optimize "Analiza este feedback de cliente y determina el sentimiento"
```

Siempre entrega el prompt completo optimizado — nunca solo una descripción:

```
/ai-dev:prompt-optimize prompt de clasificación de tickets de soporte para modelo Claude Haiku 4.5
```

---

## Agentes especializados

Usar agentes cuando necesitas trabajo iterativo en un dominio, no solo generar código una vez.

### Cómo invocarlos

Desde el chat, menciona el dominio y Claude selecciona el agente correcto. O desde `/agents` en Claude Code.

### Cuándo usar cada uno

**`langgraph-architect`** — diseño de grafos y flujos:
```
necesito diseñar un sistema multi-agente donde un supervisor enruta a 4 agentes especializados
con estado compartido y persistencia por usuario
```

**`rag-engineer`** — pipeline de recuperación:
```
nuestro RAG tiene faithfulness de 0.71, bajó desde 0.89 después de cambiar el chunking.
diagnostica qué salió mal
```

**`vector-database-engineer`** — infraestructura de búsqueda:
```
necesito migrar de Chroma local a Qdrant en producción para 8M de documentos
con latencia P95 < 100ms
```

**`prompt-engineer`** — optimización de prompts:
```
este prompt de extracción de datos tiene 60% de tasa de éxito en formato JSON.
optimízalo para Claude Sonnet 4.6
```

**`ai-evaluator`** — medición y calidad:
```
quiero configurar evaluación continua para nuestro agente antes del release.
necesito saber qué métricas usar y cómo integrar con CI/CD
```

**`ai-engineer`** — integración completa o decisiones de arquitectura:
```
diseña la arquitectura completa para un sistema de análisis de documentos legales
con multimodal, RAG, agentes y compliance logging
```

### Tabla de decisión

| Tarea | Agente recomendado |
|-------|--------------------|
| Diseñar StateGraph con subgrafos | `langgraph-architect` |
| Agregar checkpointer y time travel | `langgraph-architect` |
| Mejorar retrieval de RAG | `rag-engineer` |
| Implementar HyDE o RAG Fusion | `rag-engineer` |
| Seleccionar vector DB para escala | `vector-database-engineer` |
| Tuning HNSW para latencia | `vector-database-engineer` |
| Optimizar prompt para modelo específico | `prompt-engineer` |
| Reducir alucinaciones en RAG | `rag-engineer` + `prompt-engineer` |
| Medir calidad del sistema | `ai-evaluator` |
| Integrar eval en CI/CD | `ai-evaluator` |
| Arquitectura desde cero | `ai-engineer` |

---

## Skills automáticos

Los skills se activan solos según lo que estés escribiendo. No necesitas invocarlos manualmente.

| Código que escribes | Skill que se activa |
|---------------------|---------------------|
| `StateGraph(`, `add_node(`, `add_edge(` | `langgraph-core` (`langgraph-fundamentals`) |
| `InMemorySaver`, `PostgresSaver`, `thread_id` | `langgraph-persistence` |
| `interrupt(`, `Command(resume=` | `langgraph-hitl` |
| `VectorStore`, `as_retriever(`, `similarity_search` | `rag` |
| `VoyageAIEmbeddings`, `text-embedding-`, `chunk_size` | `embeddings` |
| `BM25`, `hybrid`, `alpha=` | `hybrid-search` |
| `hnsw`, `ef_construction`, `quantization` | `vector-tuning` |
| `chain_of_thought`, `few_shot`, `system_prompt` | `prompt-patterns` |
| `langsmith`, `@traceable`, `LANGCHAIN_TRACING` | `langsmith-trace` |
| `evaluate(`, `ragas`, `LangChainStringEvaluator` | `llm-eval` |
| `pip install langchain`, `pyproject.toml` | `ai-setup` (`langchain-dependencies`) |
| FastMCP / servidor MCP (`@mcp.tool`) | `mcp-builder` (oficial Anthropic) |
| stack LangChain / Deep Agents / LangGraph | `langchain-build-agent` (oficial LangChain) |
| tracing / monitoring de agentes | `langchain-agent-tracing`, `langchain-agent-monitoring` |
| evals / datasets LangSmith | `langchain-eval-engineering`, `langsmith-dataset`, `langsmith-evaluator` |

---

## Flujos de trabajo completos

### Flujo: De cero a RAG en producción

```
1. /ai-dev:project-setup python rag-system
   → packages, .env, estructura

2. /ai-dev:rag-pipeline base de conocimiento legal con Pinecone
   → ingestión, retrieval, RAG chain

3. /ai-dev:eval-setup sistema RAG legal
   → RAGAS, LangSmith, baseline

4. /ai-dev:langchain-agent agente que usa el RAG como herramienta
   → agente + RAG integrado

5. /ai-dev:hitl-workflow el agente debe pedir aprobación antes de citar jurisprudencia
   → approval gate para el agente
```

### Flujo: Mejorar un sistema existente

```
1. /ai-dev:eval-setup  →  medir estado actual (baseline)
2. Agente ai-evaluator →  diagnosticar qué métricas están bajas
3. Agente rag-engineer →  mejorar retrieval si context_recall < 0.75
4. /ai-dev:prompt-optimize  →  mejorar faithfulness si las respuestas alucinan
5. /ai-dev:eval-setup  →  medir de nuevo y comparar contra baseline
```

### Flujo: Agregar oversight a agente existente

```
1. Agente langgraph-architect → diseñar dónde colocar los interrupts
2. /ai-dev:hitl-workflow      → generar código de approval gates
3. Skill langgraph-hitl       → se activa automáticamente al escribir interrupt()
4. /ai-dev:eval-setup         → verificar que el flujo de aprobación no afecta métricas
```

---

## Referencia rápida

```bash
# Comandos disponibles
/ai-dev:project-setup    # Bootstrap proyecto nuevo
/ai-dev:langchain-agent  # Crear agente LangGraph completo
/ai-dev:rag-pipeline     # Build RAG end-to-end
/ai-dev:prompt-optimize  # Optimizar un prompt
/ai-dev:eval-setup       # Configurar evaluación + CI/CD
/ai-dev:hitl-workflow    # Agregar human-in-the-loop
/ai-dev:ai-assistant     # Build AI assistant con NLU

# Agentes disponibles (menciona el dominio en el chat)
ai-engineer              # Arquitectura completa, decisiones de stack
langgraph-architect      # Grafos, estado, persistencia, HITL
rag-engineer             # Pipeline RAG, chunking, reranking
vector-database-engineer # Vector DBs, HNSW, embeddings
prompt-engineer          # Optimización de prompts
ai-evaluator             # Evaluación, métricas, CI/CD quality gates
```
