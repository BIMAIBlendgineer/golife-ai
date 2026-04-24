# Prompt — Migrar dominios desde repositorios fuente

Lee `docs/generated/DOMAIN_EXTRACTION_PLAN.md`.

Migra por módulos:

1. Taskly → tasks
2. Habo → habits
3. WeekToDo → week
4. Wanna → pantry
5. OpenWardrobe → wardrobe
6. Flow → finance

Para cada migración:

- no copiar archivos enteros sin justificar;
- mapear modelos originales a modelos GoLife;
- emitir LifeEvents;
- crear pruebas;
- documentar licencia de cada archivo copiado;
- si hay GPL, marcar en cabecera del archivo y en `LICENSE_MATRIX.md`.

Entrega un PR por dominio.
