# /plan:ideate

Inicia la fase de **ideación estructurada** como Product Owner para un nuevo sistema o feature.

## Contexto recibido

$ARGUMENTS

---

## Instrucciones

Actúa como **Product Owner** experto. Si el usuario ya proporcionó contexto en `$ARGUMENTS`, úsalo como punto de partida. Si no, haz las siguientes preguntas en orden antes de continuar:

### Preguntas obligatorias (no continuar sin estas 4):

1. **Idea base:** "Describe el sistema o feature en 2-8 líneas. ¿Qué es? ¿Qué hace?"
2. **Público objetivo:** "¿Quién lo usará? (rol, empresa, sector, perfil)"
3. **Problema que resuelve:** "¿Qué problema o necesidad específica ataca?"
4. **Contexto de uso:** "¿Dónde se usará? (web app, móvil, desktop, API, empresarial, educativo)"

### Preguntas opcionales:

5. "¿Conoces competidores o soluciones similares en el mercado?"
6. "¿Hay diferenciadores que consideres prioritarios?"
7. "¿Existen restricciones (tiempo, presupuesto, normativa, tecnología)?"

### Investigación de mercado:

Antes de idear, preguntar: "¿Deseas que investigue competidores y tendencias del mercado en internet?"

- Si acepta → buscar competidores, features estándar, tendencias del sector (máx. 5 búsquedas). Citar fuentes con URL y fecha.
- Si rechaza → continuar solo con la información del usuario.

---

## Output esperado

### Salida A — Claves de Éxito

Tabla clasificada con todas las claves identificadas:

| # | Categoría | Clave de Éxito | Origen | Clasificación | Justificación |
|---|-----------|----------------|--------|---------------|---------------|
| 1 | UX / Experiencia | ... | Usuario / Web | Crítica / Deseable | ... |

**Total:** N críticas, M deseables. Duplicados eliminados: X.

### Salida B — Artefacto #1 (Markdown)

Documento formal con:
- **1. Descripción del Software** (qué es, para quién, contexto, problema)
- **2. Análisis de Mercado** *(solo si se autorizó investigación web)*
- **3. Valor Añadido y Ventajas Competitivas** (críticas + deseables)
- **4. Funciones Principales** (derivadas del análisis, no inventadas)
- **Referencias** *(solo si se usó investigación web)*

---

## Siguiente paso sugerido

Al finalizar, proponer:
> "El Artefacto #1 está listo. El siguiente paso es crear el PRD formal con `/plan:prd`. ¿Continuamos?"
