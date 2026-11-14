# sims4_modmanager_cleanup.ps1
# Cleanup für Sims 4 Mod Manager Data (Cache & temporäre Daten)

param(
    [string]$BasePath = (Join-Path $env:USERPROFILE "Documents\Sims 4 Mod Manager Data")
)

Write-Host "=== Sims 4 Mod Manager Cleanup ==="

if (!(Test-Path $BasePath)) {
    Write-Host "Ordner 'Sims 4 Mod Manager Data' wurde nicht gefunden!" -ForegroundColor Red
    exit 1
}

# Diese Ordner sind Cache / temporär und können gefahrlos gelöscht werden
$cacheFolders = @(
    "temp",
    "cas-simulator",
    "thumbnails",
    "snapshot"
)

foreach ($folder in $cacheFolders) {
    $full = Join-Path $BasePath $folder
    if (Test-Path $full) {
        Write-Host "Lösche Ordner: $full"
        Remove-Item $full -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Cleanup abgeschlossen." -ForegroundColor Green
