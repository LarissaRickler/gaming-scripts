# sims3_backup.ps1
# Erstellt ein Backup der wichtigsten Sims-3-Daten (ohne Cache & Logs)

param(
    [string]$SourceRoot = (Join-Path $env:USERPROFILE "Documents\Electronic Arts\The Sims 3"),
    [string]$BackupRoot = "C:\Users\laris\OneDrive\Dokumente\Gaming\The Sims 3 - Backup"
)

Write-Host "=== Sims 3 Backup ==="

if (!(Test-Path $SourceRoot)) {
    Write-Host "Sims-3-Ordner nicht gefunden!" -ForegroundColor Red
    exit 1
}

$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$stagingPath = Join-Path $BackupRoot ("tmp_" + $timestamp)
$zipPath = Join-Path $BackupRoot ($timestamp + ".zip")
New-Item -ItemType Directory -Path $stagingPath -Force | Out-Null

$folders = @(
    "Saves","Mods","InstalledWorlds","DCCache","DCBackup","Downloads",
    "Exports","SavedOutfits","Screenshots","Recorded Videos","Custom Music","Collections"
)

$files = @("Options.ini","LoadOption.ini","DeviceConfig.log","Version.tag")

foreach ($folder in $folders) {
    $src = Join-Path $SourceRoot $folder
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $stagingPath $folder) -Recurse -Force -ErrorAction SilentlyContinue
    }
}

foreach ($file in $files) {
    $src = Join-Path $SourceRoot $file
    if (Test-Path $src) {
        Copy-Item $src (Join-Path $stagingPath $file) -Force -ErrorAction SilentlyContinue
    }
}

"Backup erstellt am $(Get-Date)" | Out-File (Join-Path $stagingPath "backup_log.txt")

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
}

Compress-Archive -Path (Join-Path $stagingPath "*") -DestinationPath $zipPath -CompressionLevel Optimal -Force
Remove-Item $stagingPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Backup abgeschlossen: $zipPath" -ForegroundColor Green
