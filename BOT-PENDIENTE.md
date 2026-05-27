# 🤖 Bot WhatsApp - Estado y plan para retomar

## Estado actual al 2026-05-27

### ✅ Lo que SÍ funciona
- Docker Desktop: arreglado y corriendo bien
- n8n: corriendo en http://localhost:5678 (cuenta ya creada)
- Postgres: corriendo
- Redis: corriendo
- Evolution API v2.1.2: corriendo en http://localhost:8080
- Instancia `gottavital`: creada con webhook a host.docker.internal:9000
- Groq API key: nueva, en `.env`

### ❌ Lo que NO funciona
- WhatsApp NO se vincula vía Evolution. El estado de conexión hace ciclos
  `connecting → close` cada 1-2 segundos sin generar QR.

## 🔍 Diagnóstico

WhatsApp está **rechazando activamente** la conexión. Probables causas:
1. **Soft-ban del número** `+573217318013` por muchos intentos seguidos
2. **Baileys 2.3000.x desactualizado** vs protocolo actual de WhatsApp
3. **IP/fingerprint marcado** por WhatsApp

Confirmado: cambiar `CONFIG_SESSION_PHONE_CLIENT` no soluciona el problema.

## 🛠 Plan para retomar (en orden de probabilidad de éxito)

### Opción 1 — Esperar 24-48h y reintentar (más simple)
```powershell
# Después de 1-2 días sin intentar
cd C:\gottavital
docker compose up -d
& .\capture-qr.ps1
```
Si vuelven los ciclos connecting→close, el soft-ban sigue activo.

### Opción 2 — Probar con OTRO número de WhatsApp
Tener un chip/celular distinto. Modificar instalar.bat o usar la API:
```powershell
$h = @{ "apikey" = "gottavital-dev-key-2026"; "Content-Type" = "application/json" }
Invoke-RestMethod -Uri "http://localhost:8080/instance/delete/gottavital" -Method DELETE -Headers $h
$body = '{"instanceName":"gottavital","integration":"WHATSAPP-BAILEYS","qrcode":true,"webhook":{"url":"http://host.docker.internal:9000","enabled":true,"events":["QRCODE_UPDATED","CONNECTION_UPDATE"]}}'
Invoke-RestMethod -Uri "http://localhost:8080/instance/create" -Method POST -Headers $h -Body $body
& .\capture-qr.ps1
```

### Opción 3 — Actualizar Baileys (requiere build custom)
Construir imagen Evolution con Baileys 6.7+. Complejo, requiere Dockerfile custom.

### Opción 4 — Cambiar Evolution por Whatsapp-web.js
Stack alternativo: usar whatsapp-web.js directamente (Puppeteer-based, más estable).
Requiere reescribir el workflow de n8n.

## 📜 Script de captura del QR

Está en `capture-qr.ps1`. Cuando WhatsApp acepte:
- Configura el webhook automáticamente
- Reinicia la conexión
- Captura el evento QRCODE_UPDATED
- Guarda el QR como `qr.png`
- Lo abre en visor de imágenes para escanear

## 🧹 Limpieza si quieres parar todo

```powershell
cd C:\gottavital
docker compose down
# Para borrar TODO (incluyendo n8n - perderias tu cuenta):
# docker compose down -v
```

## 📋 Cuando WhatsApp se conecte

Pasos restantes para terminar el bot:
1. Configurar Google Sheets (crear hoja "GottaVital - Citas" con encabezados)
2. Copiar ID de Sheets al `.env`
3. Importar `workflow-groq.json` en n8n
4. Configurar credenciales Google (Calendar + Sheets) en n8n
5. Pegar Groq API key en el nodo HTTP del workflow
6. Activar workflow en n8n
7. Configurar webhook de Evolution apuntando a n8n
8. Probar enviando "hola" desde otro WhatsApp al número conectado

Todo esto está detallado en `EJECUTAR-HOY.md`.
