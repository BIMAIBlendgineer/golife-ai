# GoLife Flutter

Estado auditado: 2026-05-03

## Incluye hoy

- shell Flutter con router y navegacion adaptativa
- Home Today con 3 misiones, evidencia, incertidumbre y feedback
- LifeGraph local
- capture libre con parseo multi-item y confirmacion
- privacy dashboard con permisos por dominio
- export JSON local a archivo protegido y delete all local
- boards locales para task, habits, money, pantry, closet, week, journal, calendar y recipes
- persistencia SQLite con cifrado sensible y fallback resiliente
- cliente HTTP real para `services/ai_gateway` con fallback local
- runner Android reproducible con `applicationId` `ai.golife.mobile`

## Falta o sigue limitado

- runners `ios/` y `web/` siguen fuera de este paquete
- sync remoto opcional no esta cableado en mobile
- el selector de idioma ya cubre `en`, `es`, `pt-BR`, `pt-PT`, `fr`, `it`, `de`, `ja`, `zh-Hans` y `zh-Hant`; la superficie de ajustes/perfil ya esta traducida en todo ese set y algunas vistas de dominio secundarias aun reutilizan copy en ingles
- Play App Signing y upload key reales siguen externos al repo

## Validacion local

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
cd android && gradlew.bat bundleRelease
```

## Nota sobre ejecucion

En este entorno el SDK Flutter si esta instalado y el proyecto valida con `analyze` y `test`.

`flutter build appbundle --release` puede reportar un falso fallo de symbol stripping en este workspace Windows aunque Gradle genere el `.aab`. Para verificar el bundle de forma autoritativa aqui, usar `cd android && gradlew.bat bundleRelease`.
