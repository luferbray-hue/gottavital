@echo off
chcp 65001 > nul
cls
echo Deteniendo servicios...
docker compose down
echo.
echo Listo. Los datos se conservan.
echo Para volver a levantar todo, ejecuta instalar.bat
pause
