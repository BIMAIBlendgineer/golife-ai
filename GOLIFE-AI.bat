@echo off
setlocal EnableExtensions EnableDelayedExpansion
title GoLife AI - Human Beta PR #28
chcp 65001 > nul
set PYTHONUTF8=1

rem GoLife AI local launcher - single long-lived PR #28.
rem Keep this file in the repository root next to golife_ai.py.
rem Portable by design: the repository root is this file's folder.

set "LAUNCHER_DIR=%~dp0"
if "%LAUNCHER_DIR:~-1%"=="\" set "LAUNCHER_DIR=%LAUNCHER_DIR:~0,-1%"

set "QA_WORKTREE=%LAUNCHER_DIR%"
set "EXPECTED_BRANCH=stabilize/human-beta-readiness"
set "CONTROL_TOWER_SCRIPT=%QA_WORKTREE%\golife_ai.py"
set "QA_APP_DIR=%QA_WORKTREE%\apps\mobile_flutter"
set "QA_APK=%QA_APP_DIR%\build\app\outputs\flutter-apk\app-debug.apk"
set "APK_PUSH_TARGET=/sdcard/Download/golife-pr28-human-beta.apk"
set "GOLIFE_REPO_ROOT=%QA_WORKTREE%"

set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
if not exist "%ADB%" set "ADB=adb"

set "ANDROID_SERIAL=%GOLIFE_ANDROID_SERIAL%"

if /I "%~1"=="pair-wifi" goto pair_wifi
if /I "%~1"=="connect-wifi" goto connect_wifi
if /I "%~1"=="devices" goto devices_all
if /I "%~1"=="tower" goto run_tower
if /I "%~1"=="health" goto health
if /I "%~1"=="build" goto build_pr28
if /I "%~1"=="install" goto install_pr28
if /I "%~1"=="push" goto push_pr28
if /I "%~1"=="reset-app" goto reset_app

:menu
cls
echo ============================================================
echo       GoLife AI - HUMAN BETA - SINGLE PR #28
echo ============================================================
echo.
echo Repo:  %QA_WORKTREE%
echo Rama:  %EXPECTED_BRANCH%
echo.
echo PRIMERA EJECUCION ANDROID POR WI-FI:
echo   [1] Parear esta PC con Android ^(solo primera vez^)
echo   [2] Conectar Android por Wireless Debugging
echo   [3] Ver ADB + Flutter devices
echo   [4] Abrir GoLife Control Tower
echo.
echo UTILIDADES:
echo   [5] Health check backend + gateway
echo   [6] Build APK debug de PR #28
echo   [7] Instalar APK por ADB
echo   [8] Copiar APK a Descargas del Android
echo   [9] Reset first-run GoLife ^(BORRA datos locales de la app^)
echo   [Q] Salir
echo.
echo Tras [2] y [3], abre [4] y dentro usa: T ^> H ^> D ^> M
echo.
set /p "MENU_CHOICE=Elige una opcion: "

if /I "%MENU_CHOICE%"=="1" goto pair_wifi
if /I "%MENU_CHOICE%"=="2" goto connect_wifi
if /I "%MENU_CHOICE%"=="3" goto devices_all
if /I "%MENU_CHOICE%"=="4" goto run_tower
if /I "%MENU_CHOICE%"=="5" goto health
if /I "%MENU_CHOICE%"=="6" goto build_pr28
if /I "%MENU_CHOICE%"=="7" goto install_pr28
if /I "%MENU_CHOICE%"=="8" goto push_pr28
if /I "%MENU_CHOICE%"=="9" goto reset_app
if /I "%MENU_CHOICE%"=="Q" goto end

echo.
echo [!!] Opcion no valida.
pause
goto menu

:check_worktree
if not exist "%QA_APP_DIR%\pubspec.yaml" (
    echo.
    echo [!!] GOLIFE-AI.bat debe vivir en la raiz del repo GoLife.
    echo      No encuentro: %QA_APP_DIR%\pubspec.yaml
    pause
    exit /b 1
)
if not exist "%CONTROL_TOWER_SCRIPT%" (
    echo.
    echo [!!] No encuentro golife_ai.py junto a este BAT.
    pause
    exit /b 1
)

set "CURRENT_BRANCH="
for /f "usebackq delims=" %%B in (`git -C "%QA_WORKTREE%" branch --show-current 2^>nul`) do set "CURRENT_BRANCH=%%B"
if /I not "!CURRENT_BRANCH!"=="%EXPECTED_BRANCH%" (
    echo.
    echo [!!] RAMA INCORRECTA.
    echo      Actual:   !CURRENT_BRANCH!
    echo      Esperada: %EXPECTED_BRANCH%
    echo      No arrancare otro checkout por accidente.
    pause
    exit /b 1
)
for /f "usebackq delims=" %%H in (`git -C "%QA_WORKTREE%" rev-parse --short^=12 HEAD 2^>nul`) do set "CURRENT_HEAD=%%H"
echo [OK] Contexto PR #28: %EXPECTED_BRANCH% @ !CURRENT_HEAD!
exit /b 0

:check_python
where python >nul 2>&1
if errorlevel 1 (
    echo.
    echo [!!] Python no esta disponible en PATH.
    pause
    exit /b 1
)
exit /b 0

:check_adb
if /I "%ADB%"=="adb" (
    where adb >nul 2>&1
    if errorlevel 1 (
        echo.
        echo [!!] No encuentro adb en Android SDK Platform-Tools ni en PATH.
        pause
        exit /b 1
    )
) else (
    if not exist "%ADB%" (
        echo.
        echo [!!] No encuentro adb en: %ADB%
        pause
        exit /b 1
    )
)
exit /b 0

:pair_wifi
call :check_worktree
if errorlevel 1 goto menu
call :check_adb
if errorlevel 1 goto menu

echo.
echo ============================================================
echo   ANDROID WIRELESS DEBUGGING - PAREAR ESTA PC
echo ============================================================
echo.
echo En Android:
echo   Opciones de desarrollador ^> Depuracion inalambrica
echo   ^> Vincular dispositivo con codigo de vinculacion
echo.
echo Usa la IP:PUERTO mostrada DENTRO de la pantalla de vinculacion.
echo El puerto de vinculacion puede ser distinto al puerto de conexion.
echo.
set "PAIR_ENDPOINT="
set /p "PAIR_ENDPOINT=IP:PUERTO de vinculacion: "
if not defined PAIR_ENDPOINT goto menu

echo.
echo [ADB] adb pair !PAIR_ENDPOINT!
echo [ADB] Escribe el codigo de 6 digitos cuando ADB lo solicite.
echo.
"%ADB%" pair "!PAIR_ENDPOINT!"
if errorlevel 1 (
    echo.
    echo [!!] Pareado fallido. Verifica Wi-Fi, IP:puerto y codigo.
) else (
    echo.
    echo [OK] Esta PC quedo pareada. Ahora elige [2] para conectar.
)
pause
goto menu

:connect_wifi
call :check_worktree
if errorlevel 1 goto menu
call :check_adb
if errorlevel 1 goto menu

echo.
echo ============================================================
echo   ANDROID WIRELESS DEBUGGING - CONECTAR
echo ============================================================
echo.
echo En la pantalla PRINCIPAL de Depuracion inalambrica copia:
echo   Direccion IP y puerto
echo.
echo En tu sesion actual indicaste: 192.168.1.7:38791
echo El puerto puede cambiar; no esta hardcodeado.
echo.
set "WIFI_ENDPOINT=%GOLIFE_ANDROID_WIFI_ENDPOINT%"
if not defined WIFI_ENDPOINT set /p "WIFI_ENDPOINT=IP:PUERTO de conexion: "
if not defined WIFI_ENDPOINT goto menu

"%ADB%" connect "!WIFI_ENDPOINT!"
if errorlevel 1 (
    echo.
    echo [!!] adb connect fallo. Si nunca pareaste esta PC, usa [1].
    pause
    goto menu
)
set "ANDROID_SERIAL=!WIFI_ENDPOINT!"
set "GOLIFE_ANDROID_SERIAL=!WIFI_ENDPOINT!"
echo.
echo [OK] Android conectado por Wi-Fi: !ANDROID_SERIAL!
"%ADB%" devices -l
echo.
echo Siguiente: [3] verificar Flutter y despues [4] Control Tower.
pause
goto menu

:devices_all
call :check_worktree
if errorlevel 1 goto menu
call :check_adb
if errorlevel 1 goto menu
call :check_python
if errorlevel 1 goto menu

echo.
echo ---------- ADB DEVICES ----------
"%ADB%" devices -l
echo.
echo ---------- FLUTTER DEVICES ------
python -X utf8 "%CONTROL_TOWER_SCRIPT%" devices
echo.
pause
goto menu

:run_tower
call :check_worktree
if errorlevel 1 goto menu
call :check_python
if errorlevel 1 goto menu

echo.
echo [SYS] Abriendo GoLife Control Tower - PR #28
echo [SYS] Dentro usa en este orden: T ^> H ^> D ^> M
echo.
python -X utf8 "%CONTROL_TOWER_SCRIPT%"
if errorlevel 1 (
    echo.
    echo [!!] GoLife Control Tower termino con error.
    pause
)
goto end

:health
call :check_worktree
if errorlevel 1 goto menu
call :check_python
if errorlevel 1 goto menu
python -X utf8 "%CONTROL_TOWER_SCRIPT%" health
pause
goto menu

:resolve_serial
if defined ANDROID_SERIAL (
    "%ADB%" -s "!ANDROID_SERIAL!" get-state >nul 2>&1
    if not errorlevel 1 (
        echo [OK] Android seleccionado: !ANDROID_SERIAL!
        exit /b 0
    )
    set "ANDROID_SERIAL="
)

set "ADB_DEVICE_FILE=%TEMP%\golife-adb-devices-%RANDOM%-%RANDOM%.txt"
"%ADB%" devices > "!ADB_DEVICE_FILE!" 2>nul

for /f "usebackq tokens=1,2" %%A in ("!ADB_DEVICE_FILE!") do (
    if /I "%%B"=="device" (
        if not defined ANDROID_SERIAL set "ANDROID_SERIAL=%%A"
    )
)

del /q "!ADB_DEVICE_FILE!" >nul 2>&1

if not defined ANDROID_SERIAL (
    echo.
    echo [!!] No hay Android ADB en estado device.
    "%ADB%" devices -l
    echo.
    echo Si Flutter ya muestra el telefono como wireless, vuelve a ejecutar [3].
    echo Si no aparece, revisa Wireless Debugging o reconecta desde Android Studio.
    pause
    exit /b 1
)

echo [OK] Android seleccionado: !ANDROID_SERIAL!
exit /b 0

:build_pr28
call :check_worktree
if errorlevel 1 goto menu
echo.
echo [MOBL] Building APK debug PR #28...
pushd "%QA_APP_DIR%"
call flutter build apk --debug
set "BUILD_EXIT=%ERRORLEVEL%"
popd
if not "%BUILD_EXIT%"=="0" (
    echo [!!] Build APK fallo.
    pause
    goto menu
)
if not exist "%QA_APK%" (
    echo [!!] Build termino pero APK no encontrado: %QA_APK%
    pause
    goto menu
)
echo.
echo [OK] APK: %QA_APK%
pause
goto menu

:build_quiet
call :check_worktree
if errorlevel 1 exit /b 1
pushd "%QA_APP_DIR%"
call flutter build apk --debug >nul
set "BUILD_EXIT=%ERRORLEVEL%"
popd
exit /b %BUILD_EXIT%

:install_pr28
call :check_worktree
if errorlevel 1 goto menu
call :check_adb
if errorlevel 1 goto menu
call :resolve_serial
if errorlevel 1 goto menu
if not exist "%QA_APK%" (
    echo [MOBL] APK no existe. Compilando primero...
    call :build_quiet
    if errorlevel 1 goto menu
)
echo.
echo [MOBL] Instalando en !ANDROID_SERIAL!...
"%ADB%" -s "!ANDROID_SERIAL!" install --no-streaming -r "%QA_APK%"
if errorlevel 1 (
    echo.
    echo [!!] Instalacion ADB fallo.
    echo      Si Android muestra INSTALL_FAILED_USER_RESTRICTED, el APK esta bien:
    echo      el telefono bloqueo la instalacion automatica.
    echo.
    set "COPY_AFTER_FAIL="
    set /p "COPY_AFTER_FAIL=Copiar ahora el APK a Descargas del Android? [S/N]: "
    if /I "!COPY_AFTER_FAIL!"=="S" (
        "%ADB%" -s "!ANDROID_SERIAL!" push "%QA_APK%" "%APK_PUSH_TARGET%"
        if errorlevel 1 (
            echo [!!] Tampoco se pudo copiar el APK.
        ) else (
            echo [OK] APK copiado a %APK_PUSH_TARGET%
            echo      Abre el Administrador de archivos del telefono y toca el APK.
        )
    )
) else (
    echo.
    echo [OK] APK instalado.
)
pause
goto menu

:push_pr28
call :check_worktree
if errorlevel 1 goto menu
call :check_adb
if errorlevel 1 goto menu
call :resolve_serial
if errorlevel 1 goto menu
if not exist "%QA_APK%" (
    echo [MOBL] APK no existe. Compilando primero...
    call :build_quiet
    if errorlevel 1 goto menu
)
echo.
echo [MOBL] Copiando APK a !ANDROID_SERIAL!...
"%ADB%" -s "!ANDROID_SERIAL!" push "%QA_APK%" "%APK_PUSH_TARGET%"
if errorlevel 1 (
    echo [!!] Copia ADB fallo.
) else (
    echo.
    echo [OK] Copiado a %APK_PUSH_TARGET%
)
pause
goto menu

:reset_app
call :check_worktree
if errorlevel 1 goto menu
call :check_adb
if errorlevel 1 goto menu
call :resolve_serial
if errorlevel 1 goto menu

echo.
echo ============================================================
echo   RESET FIRST-RUN GOLIFE - BORRA DATOS LOCALES DEL TELEFONO
echo ============================================================
echo.
echo Dispositivo: !ANDROID_SERIAL!
echo Package:     ai.golife.mobile
echo.
echo Esto borra SOLO los datos locales de GoLife en ese Android.
echo No toca Git, backend, gateway, PR #28 ni otros datos del telefono.
echo.
set "RESET_CONFIRM="
set /p "RESET_CONFIRM=Escribe RESET para continuar: "
if /I not "!RESET_CONFIRM!"=="RESET" (
    echo [SYS] Reset cancelado.
    pause
    goto menu
)

"%ADB%" -s "!ANDROID_SERIAL!" shell pm clear ai.golife.mobile
if errorlevel 1 (
    echo.
    echo [WARN] No se pudo limpiar el package. Puede que GoLife aun no este instalado.
) else (
    echo.
    echo [OK] Datos locales de GoLife eliminados. Proxima apertura = first-run limpio.
)
pause
goto menu

:end
endlocal
