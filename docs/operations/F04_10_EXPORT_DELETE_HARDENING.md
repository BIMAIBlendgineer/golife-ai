# F04 10 Export Delete Hardening

Fecha: 2026-05-04
Ejecutor: Codex
Rama objetivo: `main`

## Objetivo

Cerrar el gap restante del bloque Data/Persistencia/Export-Delete en mobile: reemplazar el export clipboard-only por un export JSON a archivo protegido dentro del almacenamiento privado de la app.

## Cambios

- Nuevo servicio `ProtectedLocalExportService` en mobile para persistir snapshots JSON bajo una carpeta privada de export dentro del almacenamiento local de la app.
- `GoLifeController` ahora expone `exportLocalDataFile()` además del JSON en memoria.
- `PrivacyScreen` ya no depende del portapapeles para el flujo principal de export; ahora confirma el nombre de archivo guardado.
- Cobertura añadida:
  - test unitario del servicio de export local
  - test del controller para export JSON + export a archivo
  - widget test de la pantalla de privacidad para el snackbar de export protegido

## Verificacion

- `flutter gen-l10n`
- `flutter analyze`
- `flutter test`

## Resultado esperado

- El export local deja una traza verificable en archivo.
- El delete-all local sigue funcionando.
- El riesgo documentado de clipboard-only export queda reducido.

## Riesgos residuales

- La ruta es privada de la app; la UX de recuperacion manual en dispositivo real todavia requiere validacion sobre runners finales.
- Este bloque no añade sync remoto ni export firmado del lado servidor.

## Rollback

- Revertir este cambio en mobile o restaurar los archivos tocados en `apps/mobile_flutter/**`.
