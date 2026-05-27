@echo off
chcp 65001 > nul
cls
echo ============================================================
echo   GOTTAVITAL - Instalador local (Windows)
echo ============================================================
echo.

REM Verificar que existe .env
if not exist .env (
  echo [ERROR] No existe el archivo .env
  echo.
  echo 1. Copia .env.example a .env
  echo 2. Edita .env y pon tus claves reales
  echo 3. Vuelve a ejecutar este script
  echo.
  pause
  exit /b 1
)
echo [OK] Archivo .env encontrado.

REM Verificar Docker
docker --version > nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker no esta instalado.
  echo.
  echo Descarga Docker Desktop desde:
  echo   https://www.docker.com/products/docker-desktop/
  echo.
  echo Luego REINICIA tu PC y vuelve a ejecutar este script.
  pause
  exit /b 1
)
echo [OK] Docker detectado.

REM Verificar que Docker este corriendo
docker info > nul 2>&1
if errorlevel 1 (
  echo [ERROR] Docker esta instalado pero no esta corriendo.
  echo Abre Docker Desktop y espera a que diga "Engine running".
  pause
  exit /b 1
)
echo [OK] Docker esta corriendo.
echo.

echo Levantando contenedores (esto tarda 2-3 minutos la primera vez)...
echo.
docker compose up -d

if errorlevel 1 (
  echo.
  echo [ERROR] Algo fallo. Revisa los mensajes arriba.
  pause
  exit /b 1
)

echo.
echo ============================================================
echo   LISTO! Servicios levantados:
echo ============================================================
echo.
echo   n8n        =^>  http://localhost:5678
echo   Evolution  =^>  http://localhost:8080/manager
echo.
echo   Evolution API Key:  (revisa tu .env, variable EVOLUTION_API_KEY)
echo.
echo ============================================================
echo.
echo Espera 30 segundos para que todo termine de cargar y
echo luego abre n8n en tu navegador.
echo.
pause
start http://localhost:5678
