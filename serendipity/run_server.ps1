# Script PowerShell para lanzar servidor local en puerto 8000
# Úsalo así: PowerShell -ExecutionPolicy Bypass -File run_server.ps1

$port = 8000
$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "Iniciando servidor HTTP en puerto $port..."
Write-Host "Abre en tu navegador: http://localhost:$port"
Write-Host "Presiona Ctrl+C para detener el servidor."

Set-Location $currentDir
python -m http.server $port --bind localhost
