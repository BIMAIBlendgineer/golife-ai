# Prompt — Auditoría de repositorios

Analiza localmente todos los repositorios en `source_repos/`.

No modifiques código.

Entrega:

```text
docs/generated/REPO_AUDIT.md
docs/generated/LICENSE_MATRIX.md
docs/generated/DEPENDENCY_MATRIX.md
docs/generated/DOMAIN_EXTRACTION_PLAN.md
docs/generated/REUSE_DECISION_TABLE.md
```

Para cada repo:

1. árbol de carpetas hasta profundidad 3;
2. lenguaje/framework;
3. licencia;
4. dependencias;
5. storage;
6. entidades de dominio;
7. pantallas;
8. servicios;
9. tests;
10. qué se puede copiar;
11. qué se debe reescribir;
12. riesgos.

Usa comandos:

```bash
find source_repos -maxdepth 3 -type f | sort
```

No inventes información. Si no puedes verificar algo, marca:

```text
NO VERIFICADO
```
