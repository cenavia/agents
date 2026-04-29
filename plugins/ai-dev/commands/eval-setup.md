---
description: "Set up a complete LLM evaluation pipeline with LangSmith tracing, RAGAS metrics, LLM-as-judge, and regression detection for CI/CD. Use when measuring AI system quality, setting up evaluation for RAG or agents, or establishing quality gates before deployment."
argument-hint: "<system-type> [rag|agent|prompt]"
---

# LLM Evaluation Setup

You are an expert in LLM application evaluation. Build a complete evaluation pipeline covering tracing, automated metrics, and regression detection.

## System to evaluate

$ARGUMENTS

## Step 1 — LangSmith Tracing

Add tracing first — you need traces before you can evaluate:

```python
import os
os.environ["LANGCHAIN_TRACING_V2"] = "true"
os.environ["LANGCHAIN_PROJECT"] = "my-project-eval"
# LANGCHAIN_API_KEY must be set

# All LangChain/LangGraph calls are now traced automatically.
# For non-LangChain code, use @traceable:
from langsmith import traceable

@traceable(name="my-function")
async def my_function(input: str) -> str:
    return result
```

## Step 2 — Build Evaluation Dataset

```python
from langsmith import Client

client = Client()

# Create dataset with input/expected pairs
dataset = client.create_dataset(
    "eval-dataset-v1",
    description="Evaluation set for production system"
)

examples = [
    {"inputs": {"question": q}, "outputs": {"answer": a}}
    for q, a in zip(questions, expected_answers)
]
client.create_examples(examples=examples, dataset_id=dataset.id)
```

## Step 3a — RAG Evaluation (RAGAS)

```python
from ragas import evaluate
from ragas.metrics import (
    faithfulness,       # Is the answer grounded in context?
    answer_relevancy,   # Does the answer address the question?
    context_precision,  # Are retrieved docs relevant?
    context_recall,     # Are all relevant docs retrieved?
)
from datasets import Dataset
from langchain_anthropic import ChatAnthropic

llm = ChatAnthropic(model="claude-sonnet-4-6")

eval_data = Dataset.from_dict({
    "question": questions,
    "answer": generated_answers,
    "contexts": retrieved_contexts,   # list of lists
    "ground_truth": expected_answers,
})

result = evaluate(
    eval_data,
    metrics=[faithfulness, answer_relevancy, context_precision, context_recall],
    llm=llm,
)

# Quality thresholds
thresholds = {
    "faithfulness": 0.85,
    "answer_relevancy": 0.80,
    "context_precision": 0.75,
    "context_recall": 0.80,
}
```

## Step 3b — Agent Evaluation (LangSmith)

```python
from langsmith.evaluation import evaluate, LangChainStringEvaluator

def tool_selection_evaluator(run, example):
    tools_used = {s.name for s in run.child_runs if s.run_type == "tool"}
    expected = set(example.outputs.get("expected_tools", []))
    score = len(tools_used & expected) / max(len(expected), 1)
    return {"key": "tool_selection", "score": score}

results = evaluate(
    agent.invoke,
    data="eval-dataset-v1",
    evaluators=[
        tool_selection_evaluator,
        LangChainStringEvaluator("qa"),
        LangChainStringEvaluator("cot_qa"),
    ],
    experiment_prefix="agent-v1",
    metadata={"model": "claude-sonnet-4-6", "version": "1.0"},
)
```

## Step 4 — LLM-as-Judge

```python
JUDGE_PROMPT = """Evaluate this AI response.

Task: {task}
Response: {response}
Expected: {expected}

Rate 1-10 with justification:
1. TASK COMPLETION — fully addressed?
2. ACCURACY — factually correct?
3. REASONING — logical and structured?
4. FORMAT — matches requirements?
5. SAFETY — free of bias or harm?

Output JSON:
{{"scores": {{"task_completion": X, "accuracy": X, "reasoning": X, "format": X, "safety": X}},
  "overall": X, "justification": "...", "recommendation": "accept|revise|reject"}}"""

async def llm_judge(task, response, expected=""):
    result = await llm.ainvoke(
        JUDGE_PROMPT.format(task=task, response=response, expected=expected)
    )
    return json.loads(result.content)
```

## Step 5 — Regression Detection for CI/CD

```python
class RegressionDetector:
    def __init__(self, baseline: dict, threshold: float = 0.05):
        self.baseline = baseline
        self.threshold = threshold  # 5% regression triggers failure

    async def check(self, current_system) -> dict:
        scores = await self._run_eval(current_system)
        regressions = [
            {"metric": k, "baseline": self.baseline[k], "current": v, "delta": v - self.baseline[k]}
            for k, v in scores.items()
            if v < self.baseline.get(k, 0) - self.threshold
        ]
        return {"passed": len(regressions) == 0, "regressions": regressions, "scores": scores}

# In CI/CD pipeline:
detector = RegressionDetector(baseline=load_baseline_scores())
result = await detector.check(new_system)
assert result["passed"], f"Regressions detected: {result['regressions']}"
```

## Test Distribution

Build your evaluation dataset with this distribution:

| Category | % | Purpose |
|----------|---|---------|
| Typical cases | 50% | Core functionality |
| Edge cases | 25% | Boundary conditions |
| Adversarial | 15% | Robustness testing |
| Out-of-scope | 10% | Graceful rejection |

## Implementation Checklist

- [ ] LangSmith tracing enabled on all components
- [ ] Evaluation dataset with 50+ examples (min 20 to be statistically meaningful)
- [ ] RAGAS metrics if RAG system
- [ ] LLM-as-judge for open-ended quality
- [ ] Baseline scores stored for regression detection
- [ ] CI/CD gate: fail if any metric regresses > 5%
- [ ] Weekly evaluation run scheduled
- [ ] Dashboard with metric trends over time

## Output

Deliver:
1. **Tracing setup** with LangSmith configuration
2. **Evaluation dataset** structure and sample examples
3. **Metric pipeline** (RAGAS or LLM-as-judge based on system type)
4. **Regression detector** for CI/CD integration
5. **Baseline scores** from initial evaluation run
