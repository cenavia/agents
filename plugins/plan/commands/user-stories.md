# /plan:user-stories

Genera **User Stories** detalladas y estructuradas a partir de un PRD y las User Personas definidas.

## Contexto recibido

$ARGUMENTS

---

## Instrucciones

Actúa como **Business Analyst** senior. Si el usuario proporcionó el PRD en `$ARGUMENTS`, úsalo directamente. Si no, solicitar:

```
Para generar las User Stories necesito el PRD.
Puedes pegarlo directamente o indicar dónde está.
Si no tienes PRD, usa primero /plan:prd para crearlo.
```

---

## Proceso de generación

### Paso 1: Calcular el número de historias

Antes de generar, estimar:
- Número de personas identificadas en el PRD
- Número de requisitos funcionales
- Flujos principales + flujos alternativos + casos borde

Anunciar: "Voy a generar aproximadamente N User Stories para cubrir el scope del PRD."

### Paso 2: Generar cada User Story

Para **cada historia**, usar este formato completo:

```markdown
## US-{ID}: {Título descriptivo en lenguaje de usuario}

**Como** {persona específica del PRD}
**Quiero** {acción concreta y específica}
**Para** {beneficio medible o valor de negocio}

### Criterios de Aceptación

**Flujo principal (Happy Path):**
- [ ] {criterio verificable 1}
- [ ] {criterio verificable 2}
- [ ] {criterio verificable 3}

**Flujos alternativos:**
- [ ] {caso alternativo 1}
- [ ] {caso alternativo 2}

**Manejo de errores:**
- [ ] {comportamiento de error 1}
- [ ] {mensaje de error o feedback visual}

**Requisitos no funcionales:**
- [ ] {performance, seguridad, accesibilidad si aplica}

### Notas Técnicas
{Consideraciones de implementación: validaciones, estados del sistema,
integraciones externas, límites de datos, permisos/roles}

### Dependencias
- Bloqueado por: {US-XXX o "Ninguna"}
- Habilita: {US-YYY o "Ninguna"}

---
```

### Paso 3: Tabla de resumen

Al finalizar todas las historias:

```markdown
## Resumen de User Stories

| ID | Título | Persona | Prioridad estimada | Dependencias |
|----|--------|---------|-------------------|--------------|
| US-001 | {título} | {persona} | Alta/Media/Baja | Ninguna |
| US-002 | {título} | {persona} | Alta/Media/Baja | US-001 |

**Total generadas:** N User Stories
**Cobertura:** {lista de personas cubiertas}
**Casos borde documentados:** N
```

---

## Reglas de calidad

- Cada historia cubre **un único flujo de usuario** (no mezclar funcionalidades)
- Los criterios deben ser **verificables** (sí/no), nunca subjetivos ("funciona bien")
- Toda persona del PRD debe tener **al menos una historia**
- Los casos de **error y borde** son obligatorios, no opcionales
- El lenguaje del enunciado principal es **de negocio**, no técnico
- Las notas técnicas van solo en la sección correspondiente

---

## Siguiente paso sugerido

Al finalizar, proponer:
> "Las User Stories están listas. El siguiente paso es priorizar el backlog con `/plan:backlog` o pasar directamente a crear las épicas con `/plan:epic`. ¿Cuál prefieres?"
