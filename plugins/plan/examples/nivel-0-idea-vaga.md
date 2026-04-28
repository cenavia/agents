# Nivel 0 — Solo una idea vaga

**Situación:** Tienes una frase o dos en la cabeza. No sabes bien qué construir,
para quién, ni cómo diferenciarte. Solo sabes que quieres hacer "algo" relacionado
con un problema que viste.

**Comando a usar:** `/plan:pipeline` o `/plan:ideate`

---

## Ejemplo A — Una sola frase

```
/plan:ideate quiero hacer una app para que los freelancers no pierdan facturas
```

**Qué hace el plugin:**
El skill actúa como Product Owner y empieza a hacerte las 4 preguntas clave
(público objetivo, problema específico, contexto de uso) para construir contigo
la visión antes de generar nada.

---

## Ejemplo B — Sin contexto inicial, pipeline guiado

```
/plan:pipeline
```

**Qué pasa:**
El orquestador arranca la Fase 1 y te pregunta directamente:

```
🚀 FASE 1: IDEACIÓN

Empecemos desde el inicio. Cuéntame tu idea:

1. ¿Qué es el sistema? (2-8 líneas)
2. ¿Quién lo usará?
3. ¿Qué problema resuelve?
4. ¿En qué contexto? (web, móvil, empresarial...)
```

Tú respondes algo tan vago como:

```
Quiero algo para que los equipos de trabajo no pierdan el hilo de las tareas.
No sé bien cómo, pero hay muchas herramientas y todas son complicadas.
```

El plugin extrae las claves de éxito, te propone un Artefacto #1 y te pregunta
si quieres investigar competidores antes de continuar.

---

## Ejemplo C — Solo el problema, sin solución

```
/plan:ideate

El problema es que en mi empresa nadie sabe en qué está trabajando el resto
del equipo. Usamos emails y WhatsApp y todo se pierde.
```

**Qué produce:**
- Claves de éxito identificadas (tabla críticas + deseables)
- Artefacto #1: descripción del sistema, valor añadido, funciones principales
- Pregunta de si quieres continuar al PRD con `/plan:prd`

---

## Lo que NO necesitas en Nivel 0

- ❌ Nombre del producto
- ❌ Stack tecnológico
- ❌ Competidores conocidos
- ❌ Funcionalidades definidas
- ❌ Modelo de negocio

El plugin construye todo eso contigo desde las preguntas.
