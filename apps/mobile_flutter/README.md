# GoLife Flutter

Estado auditado: 2026-05-03

## Incluye hoy

- shell Flutter con router y navegacion adaptativa
- Home Today con 3 misiones, evidencia, incertidumbre y feedback
- LifeGraph local
- capture libre con parseo multi-item y confirmacion
- privacy dashboard con permisos por dominio
- export JSON local y delete all local
- boards locales para task, habits, money, pantry, closet, week, journal, calendar y recipes
- persistencia SQLite con cifrado sensible y fallback resiliente
- cliente HTTP real para `services/ai_gateway` con fallback local

## Falta o sigue limitado

- runners de plataforma (`android/`, `ios/`, `web/`, etc.) no estan en este paquete
- sync remoto opcional no esta cableado en mobile
- algunas traducciones siguen incompletas fuera de `en`, `es` y `pt-BR`

## Validacion local

```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

## Nota sobre ejecucion

En este entorno el SDK Flutter si esta instalado y el proyecto ya valida con `analyze` y `test`.

Para `flutter run` siguen faltando runners de plataforma, asi que antes hay que generarlos o integrarlos desde la app final.
