# Add Observability

You are a Python observability expert. Add structured logging, distributed tracing, and metrics to an existing FastAPI or Django project. Generate only the observability layer — do not modify business logic.

## Context

The user has a working Python API and wants production-grade observability. Generate the minimum necessary files: logging config, OpenTelemetry setup, Prometheus metrics middleware, and correlation ID propagation. All components are opt-in — generate only what the user requests.

## Requirements

$ARGUMENTS

## Instructions

### 1. Detect What to Generate

From user input, determine which pillars to include:

- `logging` — structured JSON logging with structlog
- `tracing` — OpenTelemetry distributed tracing
- `metrics` — Prometheus metrics with FastAPI/Django middleware
- `all` — generate all three (default)

### 2. Structured Logging (structlog)

**Install:**

```bash
uv add structlog
```

**core/logging.py:**

```python
import logging
import sys
import structlog


def configure_logging(log_level: str = "INFO", json_logs: bool = True) -> None:
    shared_processors = [
        structlog.contextvars.merge_contextvars,
        structlog.stdlib.add_log_level,
        structlog.stdlib.add_logger_name,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
    ]

    if json_logs:
        renderer = structlog.processors.JSONRenderer()
    else:
        renderer = structlog.dev.ConsoleRenderer(colors=True)

    structlog.configure(
        processors=shared_processors + [
            structlog.stdlib.ProcessorFormatter.wrap_for_formatter,
        ],
        wrapper_class=structlog.stdlib.BoundLogger,
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )

    formatter = structlog.stdlib.ProcessorFormatter(
        foreign_pre_chain=shared_processors,
        processors=[
            structlog.stdlib.ProcessorFormatter.remove_processors_meta,
            renderer,
        ],
    )

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)

    root_logger = logging.getLogger()
    root_logger.handlers = [handler]
    root_logger.setLevel(log_level)
```

**FastAPI middleware — correlation ID + request logging (api/middleware/logging.py):**

```python
import time
import uuid

import structlog
from fastapi import Request, Response
from starlette.middleware.base import BaseHTTPMiddleware

logger = structlog.get_logger(__name__)


class RequestLoggingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        request_id = request.headers.get("X-Request-ID") or str(uuid.uuid4())

        structlog.contextvars.clear_contextvars()
        structlog.contextvars.bind_contextvars(
            request_id=request_id,
            method=request.method,
            path=request.url.path,
        )

        start = time.perf_counter()
        response = await call_next(request)
        duration_ms = (time.perf_counter() - start) * 1000

        logger.info(
            "request_completed",
            status_code=response.status_code,
            duration_ms=round(duration_ms, 2),
        )

        response.headers["X-Request-ID"] = request_id
        return response
```

**Add to main.py:**

```python
from app.core.logging import configure_logging
from app.api.middleware.logging import RequestLoggingMiddleware

configure_logging(
    log_level=settings.LOG_LEVEL,
    json_logs=not settings.DEBUG,
)
app.add_middleware(RequestLoggingMiddleware)
```

**Usage in services:**

```python
import structlog

logger = structlog.get_logger(__name__)

async def create_order(order_in: OrderCreate) -> Order:
    logger.info("creating_order", user_id=order_in.user_id, items=len(order_in.items))
    order = await repository.create(order_in)
    logger.info("order_created", order_id=order.id)
    return order
```

### 3. Distributed Tracing (OpenTelemetry)

**Install:**

```bash
uv add opentelemetry-sdk opentelemetry-instrumentation-fastapi \
       opentelemetry-instrumentation-sqlalchemy \
       opentelemetry-exporter-otlp-proto-grpc
```

**core/tracing.py:**

```python
from opentelemetry import trace
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor


def configure_tracing(service_name: str, otlp_endpoint: str) -> None:
    resource = Resource.create({"service.name": service_name})
    provider = TracerProvider(resource=resource)

    exporter = OTLPSpanExporter(endpoint=otlp_endpoint)
    provider.add_span_processor(BatchSpanProcessor(exporter))

    trace.set_tracer_provider(provider)


def instrument_app(app, engine=None) -> None:
    FastAPIInstrumentor.instrument_app(app)
    if engine:
        SQLAlchemyInstrumentor().instrument(engine=engine.sync_engine)
```

**Add to main.py:**

```python
from app.core.tracing import configure_tracing, instrument_app

@asynccontextmanager
async def lifespan(app: FastAPI):
    configure_tracing(
        service_name=settings.SERVICE_NAME,
        otlp_endpoint=settings.OTEL_EXPORTER_OTLP_ENDPOINT,
    )
    instrument_app(app, engine=engine)
    yield
```

**Add to .env.example:**

```env
OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4317
SERVICE_NAME=my-api
```

### 4. Prometheus Metrics

**Install:**

```bash
uv add prometheus-client
```

**api/middleware/metrics.py:**

```python
import time

from fastapi import Request, Response
from prometheus_client import Counter, Histogram, generate_latest, CONTENT_TYPE_LATEST
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.responses import Response as StarletteResponse

REQUEST_COUNT = Counter(
    "http_requests_total",
    "Total HTTP requests",
    ["method", "path", "status"],
)

REQUEST_LATENCY = Histogram(
    "http_request_duration_seconds",
    "HTTP request duration",
    ["method", "path"],
    buckets=[0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1.0, 2.5, 5.0],
)

REQUESTS_IN_PROGRESS = Counter(
    "http_requests_in_progress",
    "HTTP requests currently in progress",
    ["method", "path"],
)


class PrometheusMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        # Skip metrics endpoint itself
        if request.url.path == "/metrics":
            return await call_next(request)

        path = request.url.path
        method = request.method

        start = time.perf_counter()
        response = await call_next(request)
        duration = time.perf_counter() - start

        REQUEST_COUNT.labels(method, path, response.status_code).inc()
        REQUEST_LATENCY.labels(method, path).observe(duration)

        return response


def metrics_endpoint() -> StarletteResponse:
    return StarletteResponse(
        content=generate_latest(),
        media_type=CONTENT_TYPE_LATEST,
    )
```

**Add to main.py:**

```python
from app.api.middleware.metrics import PrometheusMiddleware, metrics_endpoint

app.add_middleware(PrometheusMiddleware)
app.add_route("/metrics", metrics_endpoint)
```

### 5. docker-compose additions (observability stack)

Append to existing docker-compose.yml:

```yaml
  # Jaeger — distributed tracing UI
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"   # Jaeger UI
      - "4317:4317"     # OTLP gRPC
    environment:
      COLLECTOR_OTLP_ENABLED: "true"

  # Prometheus
  prometheus:
    image: prom/prometheus:latest
    ports:
      - "9090:9090"
    volumes:
      - ./config/prometheus.yml:/etc/prometheus/prometheus.yml

  # Grafana
  grafana:
    image: grafana/grafana:latest
    ports:
      - "3000:3000"
    environment:
      GF_SECURITY_ADMIN_PASSWORD: admin
```

**config/prometheus.yml:**

```yaml
scrape_configs:
  - job_name: api
    static_configs:
      - targets: ["api:8000"]
    metrics_path: /metrics
    scrape_interval: 15s
```

## Output Format

Generate only the pillars requested (logging / tracing / metrics / all):

1. **`core/logging.py`** — structlog configuration
2. **`api/middleware/logging.py`** — request logging + correlation ID middleware
3. **`core/tracing.py`** — OpenTelemetry setup
4. **`api/middleware/metrics.py`** — Prometheus middleware + `/metrics` endpoint
5. **main.py additions** — one-liners to wire each component
6. **docker-compose additions** — Jaeger, Prometheus, Grafana
7. **`uv add` commands** — only for the chosen pillars
8. **`.env.example` additions** — `LOG_LEVEL`, `OTEL_EXPORTER_OTLP_ENDPOINT`, `SERVICE_NAME`

Keep each component independent — a user who only wants logging should not get OTel imports.
