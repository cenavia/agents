# /plan:backlog

**Prioriza el backlog** de User Stories usando criterios de negocio: impacto, urgencia, complejidad y riesgos.

## Contexto recibido

$ARGUMENTS

---

## Instrucciones

Actúa como **Product Owner** senior. Si el usuario proporcionó las User Stories en `$ARGUMENTS`, úsalas. Si no, solicitar:

```
Para priorizar el backlog necesito la lista de User Stories.
Puedes pegarlas aquí o indicar que ya están en el contexto de esta conversación.
```

---

## Proceso de priorización

### Paso 1: Presentar criterios

Explicar brevemente la metodología antes de la tabla:

**Criterios de evaluación (escala 1-5):**
- **Impacto en usuario/negocio (1-5):** ¿Cuánto valor aporta? ¿Afecta métricas clave?
- **Urgencia (1-5):** ¿Hay presión de mercado, deadline, o feedback urgente de usuarios?
- **Complejidad técnica (1-5):** ¿Qué tan difícil es implementarlo? (1=trivial, 5=muy complejo)
- **Riesgo/Dependencias:** ¿Bloquea a otras historias? ¿Depende de terceros?

**Fórmula de Score:** `(Impacto × 2 + Urgencia) − Complejidad`

### Paso 2: Tabla de priorización

```markdown
## Backlog Priorizado

| ID | User Story | Impacto (1-5) | Urgencia (1-5) | Complejidad (1-5) | Riesgo | Score | Prioridad |
|----|------------|---------------|----------------|-------------------|--------|-------|-----------|
| US-001 | {título corto} | 5 | 4 | 2 | Bajo | 17 | **P1** |
| US-002 | {título corto} | 4 | 3 | 3 | Medio | 12 | **P2** |
| US-003 | {título corto} | 2 | 1 | 4 | Bajo | 1 | **P3** |
```

**Leyenda de prioridades:**
- **P1** (Score ≥ 14): Sprint actual — no negociable
- **P2** (Score 7-13): Próximos 2 sprints — planificado
- **P3** (Score < 7): Backlog — sin fecha comprometida

### Paso 3: Agrupación por prioridad

```markdown
## Sprint Recomendado

### Sprint 1 — P1 (Núcleo del producto)
- US-001: {título} — Score: 17
- US-003: {título} — Score: 15

### Sprint 2-3 — P2 (Extensión de valor)
- US-005: {título} — Score: 11
- US-002: {título} — Score: 9

### Backlog — P3 (Futuro)
- US-007: {título} — Score: 4
- US-004: {título} — Score: 2
```

### Paso 4: Señalar bloqueos y dependencias críticas

```markdown
## Dependencias Críticas

⚠️ **US-002 bloquea a US-005 y US-008** → Priorizar US-002 aunque su score sea P2
⚠️ **US-001 requiere config externa** → Agregar [TASK] de setup antes del sprint
```

---

## Resultado final

Entregar:
1. Tabla completa de priorización con scores
2. Backlog ordenado por prioridad
3. Sprints sugeridos (agrupación por P1/P2/P3)
4. Advertencias de dependencias o bloqueos detectados

---

## Siguiente paso sugerido

Al finalizar, proponer:
> "El backlog está priorizado. El siguiente paso es crear las Épicas técnicas con `/plan:epic` para agrupar las historias P1 en unidades de trabajo. ¿Continuamos?"
