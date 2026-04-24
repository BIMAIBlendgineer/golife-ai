# Criterios de aceptación del MVP

## Test 1 — Tarea vaga

Entrada:

> “hacer trabajo universidad”

Resultado esperado:

- IA detecta tarea vaga.
- Propone 3–5 pasos.
- Explica que falta entregable/fecha.
- No modifica sin aceptación.

## Test 2 — Hábito fallido

Entrada:

- Hábito “caminar 30 min” fallado 4 días.

Resultado esperado:

- IA no culpabiliza.
- Propone misión de recuperación: “caminar 7 minutos”.
- Dificultad baja.

## Test 3 — Microgasto

Entrada:

- 8 cafés registrados en 7 días.

Resultado esperado:

- MoneyMirror detecta patrón.
- Sugiere límite o misión alternativa.
- No da asesoría financiera regulada.

## Test 4 — Despensa + gasto

Entrada:

- arroz, tomate, pollo registrados;
- gasto alto en comida fuera.

Resultado esperado:

- FridgeZero + MoneyMirror generan misión conjunta.
- Explicación usa ambos dominios.

## Test 5 — Armario anti-compra

Entrada:

- intención de comprar chaqueta negra;
- armario tiene 3 chaquetas negras.

Resultado esperado:

- ClosetLess sugiere no comprar.
- Muestra evidencia.
- Permite override.

## Test 6 — Privacidad

Entrada:

- finanzas en `local_only`.

Resultado esperado:

- IA no recibe datos financieros.
- Sugerencia no menciona finanzas.

## Test 7 — Provider swap

Entrada:

- cambiar `LLM_PROVIDER`.

Resultado esperado:

- app no cambia.
- solo AI Gateway cambia provider.

## Test 8 — JSON inválido del modelo

Entrada:

- proveedor devuelve texto no validable.

Resultado esperado:

- gateway rechaza salida;
- reintenta una vez;
- si falla, devuelve error seguro.

## Test 9 — Acción externa

Entrada:

- IA propone añadir lista de compra.

Resultado esperado:

- estado `draft`.
- requiere confirmación.
- no se modifica lista automáticamente.

## Test 10 — Trace

Entrada:

- usuario abre explicación.

Resultado esperado:

- ve evidencia;
- ve incertidumbre;
- ve datos usados;
- ve proveedor/modelo si está habilitado.
