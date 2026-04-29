---
description: "Add human-in-the-loop approval, validation, or review to an existing LangGraph agent. Use when you need human oversight before executing irreversible actions, collecting missing information, or implementing approval gates in AI workflows."
argument-hint: "<agent-or-workflow-description>"
---

# Human-in-the-Loop Workflow

You are an expert in LangGraph human-in-the-loop patterns. Add structured human oversight to AI workflows using `interrupt()` and `Command(resume=...)`.

## Workflow to modify

$ARGUMENTS

## Core Requirements

Three things are always required:
1. **Checkpointer** — compile with `checkpointer=InMemorySaver()` (dev) or `PostgresSaver` (prod)
2. **Thread ID** — pass `{"configurable": {"thread_id": "..."}}` to every invoke/stream call
3. **Serializable payload** — the value passed to `interrupt()` must be JSON-serializable

## Pattern 1 — Approval Gate (most common)

Use when an agent is about to take an irreversible action (send email, write to DB, call external API):

```python
from langgraph.types import interrupt, Command
from langgraph.graph import StateGraph, START, END
from typing import Literal, TypedDict

class State(TypedDict):
    action_plan: dict
    approved: bool
    result: str

def review_node(state: State) -> Command[Literal["execute", "__end__"]]:
    # Pause and surface the plan to the human
    decision = interrupt({
        "message": "Review this action before execution",
        "action": state["action_plan"],
        "risk_level": "high",
    })

    if decision.get("approved"):
        edited_plan = decision.get("edited_plan", state["action_plan"])
        return Command(update={"action_plan": edited_plan, "approved": True}, goto="execute")
    else:
        return Command(update={"approved": False}, goto=END)

def execute_node(state: State) -> dict:
    # Only runs after human approval
    result = perform_action(state["action_plan"])
    return {"result": result}

from langgraph.checkpoint.memory import InMemorySaver

graph = (
    StateGraph(State)
    .add_node("review", review_node)
    .add_node("execute", execute_node)
    .add_edge(START, "review")
    .add_edge("execute", END)
    .compile(checkpointer=InMemorySaver())
)

# Run until interrupt
config = {"configurable": {"thread_id": "thread-1"}}
paused = graph.invoke({"action_plan": plan}, config)
# paused["__interrupt__"] contains the review payload

# Resume with human decision
final = graph.invoke(Command(resume={"approved": True}), config)
```

## Pattern 2 — Slot Filling (collect missing info)

Use when the agent needs information from the user to continue:

```python
def gather_requirements(state: State) -> dict:
    missing = []
    if not state.get("deadline"):
        missing.append("deadline")
    if not state.get("budget"):
        missing.append("budget")

    while missing:
        field = missing.pop(0)
        value = interrupt({
            "prompt": f"Please provide: {field}",
            "field": field,
            "current_values": {k: state.get(k) for k in ["deadline", "budget"]},
        })
        # Validate
        if not validate(field, value):
            missing.insert(0, field)  # Re-ask if invalid
            continue
        state = {**state, field: value}

    return state
```

## Pattern 3 — Validation Loop

Use when input must meet criteria before the agent can proceed:

```python
def validation_node(state: State) -> dict:
    prompt = "Please provide a valid email address:"

    while True:
        answer = interrupt(prompt)
        if re.match(r'^[\w.-]+@[\w.-]+\.\w{2,}$', answer):
            return {"email": answer}
        prompt = f"'{answer}' is not valid. Please enter a valid email:"
```

## Pattern 4 — Middleware (HumanInTheLoopMiddleware)

Use for automatic human approval of dangerous tool calls without modifying graph logic:

```python
from langchain_agents import HumanInTheLoopMiddleware

class DangerousToolMiddleware(HumanInTheLoopMiddleware):
    DANGEROUS_TOOLS = {"delete_file", "send_email", "execute_sql", "call_api"}

    def should_interrupt(self, tool_name: str, tool_input: dict) -> bool:
        return tool_name in self.DANGEROUS_TOOLS

    def format_review_prompt(self, tool_name: str, tool_input: dict) -> str:
        return f"Agent wants to call '{tool_name}' with: {json.dumps(tool_input, indent=2)}\nApprove? (yes/no)"

agent = create_react_agent(llm, tools, middleware=[DangerousToolMiddleware()])
```

## Async / Streaming variant

```python
async for chunk in graph.astream(initial_state, config, stream_mode="updates"):
    if "__interrupt__" in chunk:
        interrupt_data = chunk["__interrupt__"][0]
        # Send interrupt_data to your UI/API
        user_response = await get_human_response(interrupt_data.value)
        # Resume
        async for final in graph.astream(Command(resume=user_response), config):
            yield final
```

## Checklist

- [ ] Checkpointer configured (InMemorySaver for dev, PostgresSaver for prod)
- [ ] Thread ID passed on every invoke/stream call
- [ ] `interrupt()` payload is JSON-serializable
- [ ] All code before `interrupt()` is idempotent (it re-runs on resume)
- [ ] Resume path handles both approval and rejection
- [ ] Timeout handling if human doesn't respond
- [ ] Audit log of all human decisions

## Output

Deliver:
1. **Modified graph** with interrupt nodes at appropriate points
2. **Resume handler** for each interrupt pattern used
3. **API endpoint** or UI hook to surface interrupt data
4. **Audit logging** of human decisions with timestamps
