# Flujos de trabajo — Java Spring Boot Plugin

Referencia de los dos flujos principales de uso del plugin según el estado del proyecto.

---

## Flujo 1 — Proyecto nuevo desde cero

Para cuando aún no existe ningún proyecto y se parte de un requerimiento o conjunto de historias de usuario.

```
┌─────────────────────────────────────────────────────────────────────┐
│  PUNTO DE PARTIDA: requerimiento o HU, sin código existente         │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PASO 1 — Crear el proyecto base                                     │
│                                                                     │
│  Comando: /java-springboot:new-project <nombre>                     │
│                                                                     │
│  Qué genera:                                                        │
│  • Estructura de directorios (dominio, arquitectura, recursos)      │
│  • pom.xml / build.gradle con el stack elegido                      │
│  • application.yml con perfiles dev / prod                          │
│  • Dockerfile multi-stage + docker-compose.yml                      │
│  • Pipeline CI (.github/workflows/ci.yml)                           │
│  • Clase principal de la aplicación                                 │
│                                                                     │
│  Comportamiento: este comando NO hace discovery (no hay nada que    │
│  leer). Pregunta por stack, arquitectura y módulos al inicio.       │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PASO 2 — Primer feature                                            │
│                                                                     │
│  Comando: /java-springboot:new-feature <HU o descripción>           │
│           /java-springboot:bff-new-feature <HU> (para Kaust)        │
│                                                                     │
│  Discovery en proyecto nuevo:                                       │
│  • Glob encuentra la clase Application y la estructura base         │
│  • No hay features existentes → discovery de convenciones usa       │
│    el pom.xml / build.gradle como única fuente de verdad            │
│  • La tabla 2.1 de convenciones se basa en los defaults del stack   │
│    detectado (no en código existente)                                │
│  • El árbol de archivos (2.2) sigue la arquitectura elegida         │
│    en el paso anterior                                              │
│                                                                     │
│  Comportamiento: funciona igual que siempre — discovery, diagnós-   │
│  tico, Pausa 2, "generar". La diferencia es que la referencia de    │
│  convenciones viene del build file, no de código existente.         │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PASO 3 — Features sucesivos                                        │
│                                                                     │
│  Comando: /java-springboot:new-feature <siguiente HU>               │
│                                                                     │
│  Desde el segundo feature en adelante, el discovery encuentra       │
│  código real: el feature anterior sirve como referencia.            │
│  El comportamiento es idéntico al Flujo 2 desde este punto.         │
└─────────────────────────────────────────────────────────────────────┘
```

### Comandos de apoyo durante el Flujo 1

| Necesidad | Comando |
|-----------|---------|
| Agregar Docker al proyecto creado | `/java-springboot:add-docker` |
| Agregar documentación OpenAPI | `/java-springboot:add-openapi` |
| Agregar fault tolerance | `/java-springboot:add-resilience <servicio>` |
| Generar tests para lo creado | `/java-springboot:add-tests <clase>` |
| Revisar código generado | `/java-springboot:code-review <archivo>` |

### Secuencia típica completa

```
/java-springboot:new-project tienda-api
     ↓ (proyecto creado)
/java-springboot:new-feature HU-01: El usuario puede registrar productos con nombre, precio y stock
     ↓ (Pausa 1 si hay dudas, Pausa 2 siempre) → "generar"
/java-springboot:new-feature HU-02: El usuario puede listar productos con filtros por categoría
     ↓ → "generar"
/java-springboot:add-tests ProductService
/java-springboot:code-review src/main/java/.../ProductController.java
```

---

## Flujo 2 — Retomar desarrollo en curso

Para cuando el proyecto ya existe, tiene features desarrollados con una arquitectura definida, y se incorpora una nueva historia de usuario o requerimiento.

```
┌─────────────────────────────────────────────────────────────────────┐
│  PUNTO DE PARTIDA: proyecto en curso con código existente           │
│  La arquitectura, las convenciones y el stack ya están definidos.   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PASO 1 — Entender el estado actual (opcional pero recomendado)     │
│                                                                     │
│  Si llevas tiempo fuera del proyecto o eres nuevo en él:            │
│                                                                     │
│  Pedir al agente que haga un reconocimiento:                        │
│  "describe la arquitectura de este proyecto y los dominios          │
│   que ya están implementados"                                       │
│                                                                     │
│  El agente java-springboot-architect leerá el proyecto y te         │
│  dará un mapa de: dominios existentes, patrones usados,             │
│  deuda técnica visible, y dónde encaja el nuevo feature.            │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PASO 2 — Generar el nuevo feature                                  │
│                                                                     │
│  Comando: /java-springboot:new-feature <HU o descripción>           │
│           /java-springboot:bff-new-feature <HU> (para Kaust)        │
│                                                                     │
│  Fase 1 — Discovery:                                                │
│  • Glob lista todos los archivos Java existentes                    │
│  • Lee un archivo representativo por capa del dominio de referencia │
│  • Lee la infraestructura de tests                                  │
│  • Verifica si el feature ya existe parcialmente (Fallback B)       │
│                                                                     │
│  Fase 2a — Análisis:                                                │
│  • Deriva nombre, operaciones, tipo de respuesta del requerimiento  │
│  • Si hay preguntas que bloquean el árbol → Pausa 1                 │
│                                                                     │
│  Fase 2b — Diagnóstico:                                             │
│  • Tabla de convenciones detectadas vs referencia del skill         │
│  • Árbol de archivos con rutas reales y marcas [NUEVO] / [EXISTE]  │
│  • Conflictos con opciones de resolución                            │
│  • Dependencias faltantes                                           │
│                                                                     │
│  Pausa 2 — obligatoria:                                             │
│  • Revisar el plan                                                  │
│  • Responder "generar" (o correcciones → plan ajustado → Pausa 2)  │
│                                                                     │
│  Fase 3 — Generación:                                               │
│  • Código adaptado a las convenciones reales del proyecto           │
│  • Mismos patrones, mismas excepciones, misma estructura de tests   │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│  PASO 3 — Validación post-generación                                │
│                                                                     │
│  Después de generar, antes de hacer commit:                         │
│                                                                     │
│  /java-springboot:code-review <archivos generados>                  │
│  /java-springboot:add-tests <clase> (si los tests son insuficientes)│
│  /java-springboot:security-audit (si el feature tiene auth/datos    │
│                                    sensibles)                       │
│                                                                     │
│  Compilar y ejecutar tests:                                         │
│  ./mvnw test   o   ./gradlew test                                   │
└─────────────────────────────────────────────────────────────────────┘
```

### Cuándo usar cada variante del comando

| Proyecto | Comando |
|----------|---------|
| Cualquier proyecto Spring Boot | `/java-springboot:new-feature <HU>` |
| BFF Agent Chat Kaust Yotta | `/java-springboot:bff-new-feature <HU>` |

La variante `bff-new-feature` conoce de antemano el stack (WebFlux + MongoDB reactivo) y las convenciones del proyecto Kaust, por lo que el discovery es más enfocado y la tabla de convenciones compara contra el skill `bff-agent-chat-kaust-yotta` en lugar de defaults genéricos de Spring Boot.

### Casos especiales en proyectos en curso

**El feature que pides ya existe parcialmente:**
El comando detecta los archivos existentes (Fallback B) y presenta opciones: extender los existentes, completar los faltantes, o cancelar. No sobreescribe sin preguntar.

**El proyecto tiene una desviación de las convenciones del skill:**
La tabla 2.1 del diagnóstico muestra la desviación con el archivo de referencia donde se detectó. La generación usa las convenciones del proyecto, no las del skill. El skill es referencia, no autoridad.

**Se incorpora al proyecto un desarrollador nuevo:**
Usar el agente `java-springboot-architect` para el reconocimiento inicial (Paso 1 del flujo), luego usar el comando normalmente. El agente leerá el código existente y dará contexto antes de que se corra el primer `bff-new-feature`.

---

## Comparación rápida de los dos flujos

| Aspecto | Flujo 1 (desde cero) | Flujo 2 (en curso) |
|---------|---------------------|-------------------|
| Primer comando | `new-project` | directamente `new-feature` |
| Discovery Fase 1 | encuentra solo estructura base | encuentra features completos |
| Fuente de convenciones | build file + arquitectura elegida | código existente leído |
| Tabla 2.1 | comparada contra defaults del stack | comparada contra código real |
| Fallback A (sin Java) | siempre se activa en el primer feature | no debería activarse |
| Fallback B (ya existe) | improbable | posible si el feature está a medias |
| Riesgo principal | árbol basado en defaults (aceptable) | convención detectada incorrectamente |

---

## Protocolo de pausas — resumen visual

Ambos comandos siguen exactamente el mismo protocolo de pausas:

```
Fase 1: Discovery
    │
    ▼
Fase 2a: Análisis + preguntas bloqueantes
    │
    ├── ¿Hay preguntas bloqueantes? ──sí──► PAUSA 1
    │                                           │ usuario responde
    │◄──────────────────────────────────────────┘
    │
    ▼
Fase 2b: Diagnóstico completo (árbol real + conflictos + dependencias)
    │
    ▼
PAUSA 2 ── siempre ──► usuario escribe "generar"
                               │
                               ▼ (o da correcciones → se ajusta el plan → vuelve a Pausa 2)
                        Fase 3: Generación
```

La palabra de autorización es `"generar"` en ambos comandos.
También se acepta cualquier variante afirmativa clara: `"sí generar"`, `"procede"`, `"adelante"`, `"go ahead"`.
