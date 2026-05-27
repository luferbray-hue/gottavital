# ============================================================
# Captura el QR de Evolution vía webhook
# Levanta un servidor HTTP en :9000 que escucha eventos de Evolution
# ============================================================

$port = 9000
$evoKey = "gottavital-dev-key-2026"
$instance = "gottavital"
$outBase64 = "C:\gottavital\qr-base64.txt"
$outPng = "C:\gottavital\qr.png"

Write-Host "=== Capturador de QR de Evolution ===" -ForegroundColor Cyan

# Configurar webhook en Evolution apuntando a nuestro listener
Write-Host "1. Configurando webhook en Evolution..." -ForegroundColor Yellow
$webhookBody = @{
    webhook = @{
        enabled = $true
        url = "http://host.docker.internal:$port"
        webhookByEvents = $false
        events = @("QRCODE_UPDATED", "CONNECTION_UPDATE")
    }
} | ConvertTo-Json -Depth 5

$h = @{ "apikey" = $evoKey; "Content-Type" = "application/json" }
try {
    Invoke-RestMethod -Uri "http://localhost:8080/webhook/set/$instance" -Method POST -Headers $h -Body $webhookBody -ErrorAction Stop | Out-Null
    Write-Host "  OK webhook configurado" -ForegroundColor Green
} catch {
    Write-Host "  Webhook err (probando endpoint alternativo): $($_.Exception.Message)" -ForegroundColor Red
    # En v2 a veces es /webhook/instance/{instance} o similar
    try {
        $alt = @{
            url = "http://host.docker.internal:$port"
            enabled = $true
            events = @("QRCODE_UPDATED", "CONNECTION_UPDATE")
        } | ConvertTo-Json
        Invoke-RestMethod -Uri "http://localhost:8080/webhook/$instance" -Method POST -Headers $h -Body $alt -ErrorAction Stop | Out-Null
        Write-Host "  OK alternativa funciono" -ForegroundColor Green
    } catch {
        Write-Host "  Tampoco alternativa: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Arrancar HTTP listener
Write-Host "2. Arrancando listener en puerto $port..." -ForegroundColor Yellow
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://+:$port/")
try {
    $listener.Start()
} catch {
    Write-Host "ERROR arrancando listener (necesitas admin?): $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Probando con localhost only..." -ForegroundColor Yellow
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://localhost:$port/")
    $listener.Prefixes.Add("http://127.0.0.1:$port/")
    $listener.Start()
}
Write-Host "  Listener activo. Esperando eventos..." -ForegroundColor Green

# Reiniciar la conexión para forzar nuevo QR
Write-Host "3. Reiniciando conexion en Evolution..." -ForegroundColor Yellow
try { Invoke-RestMethod -Uri "http://localhost:8080/instance/restart/$instance" -Method POST -Headers $h -ErrorAction SilentlyContinue | Out-Null } catch {}
Start-Sleep -Seconds 2
try { Invoke-RestMethod -Uri "http://localhost:8080/instance/connect/$instance" -Method GET -Headers $h -ErrorAction SilentlyContinue | Out-Null } catch {}
Write-Host "  Connect solicitado" -ForegroundColor Green

# Loop principal de captura
Write-Host ""
Write-Host "Esperando QR... (timeout 60s)" -ForegroundColor Cyan
$timeout = (Get-Date).AddSeconds(60)
$gotQr = $false

while ((Get-Date) -lt $timeout -and -not $gotQr) {
    # Tarea async para no bloquear más de 5s
    $context = $null
    $task = $listener.GetContextAsync()
    if ($task.Wait(5000)) {
        $context = $task.Result
    } else {
        continue
    }

    $request = $context.Request
    $body = ""
    if ($request.HasEntityBody) {
        $reader = New-Object System.IO.StreamReader($request.InputStream, $request.ContentEncoding)
        $body = $reader.ReadToEnd()
        $reader.Close()
    }

    # Responder OK rápido
    $response = $context.Response
    $response.StatusCode = 200
    $okBytes = [System.Text.Encoding]::UTF8.GetBytes("ok")
    $response.OutputStream.Write($okBytes, 0, $okBytes.Length)
    $response.Close()

    # Parsear evento
    if ($body) {
        Write-Host "  Evento recibido ($($body.Length) chars)" -ForegroundColor DarkGray
        try {
            $event = $body | ConvertFrom-Json
            $eventName = $event.event
            Write-Host "  Tipo: $eventName" -ForegroundColor Cyan

            if ($eventName -eq "qrcode.updated" -or $eventName -eq "QRCODE_UPDATED") {
                $qr = $event.data.qrcode
                if (-not $qr) { $qr = $event.qrcode }
                if (-not $qr -and $event.data.base64) { $qr = @{ base64 = $event.data.base64 } }

                if ($qr.base64) {
                    $qr.base64 | Out-File -Encoding ascii $outBase64
                    # Convertir base64 a PNG
                    $b64 = $qr.base64 -replace '^data:image/[^;]+;base64,', ''
                    [System.IO.File]::WriteAllBytes($outPng, [Convert]::FromBase64String($b64))
                    Write-Host ""
                    Write-Host "===========================================" -ForegroundColor Green
                    Write-Host " QR CAPTURADO!" -ForegroundColor Green
                    Write-Host "===========================================" -ForegroundColor Green
                    Write-Host " Archivo: $outPng" -ForegroundColor Green
                    if ($qr.pairingCode) {
                        Write-Host " Pairing code: $($qr.pairingCode)" -ForegroundColor Yellow
                    }
                    Write-Host ""
                    $gotQr = $true
                }
            } elseif ($eventName -eq "connection.update" -or $eventName -eq "CONNECTION_UPDATE") {
                Write-Host "  Conexion: $($event.data.state)" -ForegroundColor DarkCyan
            }
        } catch {
            Write-Host "  Error parsing: $($_.Exception.Message)" -ForegroundColor Red
            Write-Host "  Body: $($body.Substring(0, [Math]::Min(200, $body.Length)))" -ForegroundColor DarkGray
        }
    }
}

$listener.Stop()
$listener.Close()

if ($gotQr) {
    Write-Host "Abriendo QR en navegador..." -ForegroundColor Green
    Start-Process $outPng
    exit 0
} else {
    Write-Host "Timeout - no se recibio QR en 60s" -ForegroundColor Red
    exit 1
}
