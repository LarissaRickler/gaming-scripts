# sims4_modmanager_backup.ps1
# Backup der Sims 4 Mod Manager Data (Konfiguration, Datenbank, relevante Ordner)

param(
    [string]$SourceRoot = (Join-Path $env:USERPROFILE "Documents\Sims 4 Mod Manager Data"),
    [string]$BackupRoot = "C:\Users\laris\OneDrive\Dokumente\Gaming\Sims 4 Mod Manager - Backup"
)

Write-Host "=== Sims 4 Mod Manager Backup ==="

if (!(Test-Path $SourceRoot)) {
    Write-Host "Ordner 'Sims 4 Mod Manager Data' wurde nicht gefunden!" -ForegroundColor Red
    exit 1
}

# Backup-Ziel mit Zeitstempel
$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$stagingPath = Join-Path $BackupRoot ("tmp_" + $timestamp)
$zipPath = Join-Path $BackupRoot ($timestamp + ".zip")
New-Item -ItemType Directory -Path $stagingPath -Force | Out-Null

# Wichtige Ordner für die Organisation/Zuordnung
$folders = @(
    "saves and tray",
    "downloads",
    "other",
    "tools",
    "languages",
    "images",
    "snapshot",
    "thumbnails"
)

# Wichtige Dateien (Datenbank & Einstellungen)
$files = @(
    "db_cc.sqlite",
    "settings.json",
    "readme.txt"
)

foreach ($folder in $folders) {
    $src = Join-Path $SourceRoot $folder
    if (Test-Path $src) {
        $dst = Join-Path $stagingPath $folder
        Copy-Item $src $dst -Recurse -Force -ErrorAction SilentlyContinue
    }
}

foreach ($file in $files) {
    $src = Join-Path $SourceRoot $file
    if (Test-Path $src) {
        $dst = Join-Path $stagingPath $file
        Copy-Item $src $dst -Force -ErrorAction SilentlyContinue
    }
}

"Backup erstellt am $(Get-Date)" | Out-File (Join-Path $stagingPath "backup_log.txt")

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
}

Compress-Archive -Path (Join-Path $stagingPath "*") -DestinationPath $zipPath -CompressionLevel Optimal -Force
Remove-Item $stagingPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Backup abgeschlossen: $zipPath" -ForegroundColor Green
