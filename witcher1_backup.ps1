# witcher1_backup.ps1
# Backup der Witcher-1-Spielstände

param(
    [string]$SourceFolder = "C:\Users\laris\Documents\The Witcher\saves",
    [string]$BackupRoot   = "C:\Users\laris\OneDrive\Dokumente\Gaming\The Witcher - Backup"
)

Write-Host "=== Witcher 1 Backup ==="

if (!(Test-Path $SourceFolder)) {
    Write-Host "Witcher-1-Saveordner nicht gefunden!" -ForegroundColor Red
    exit 1
}

$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$stagingPath = Join-Path $BackupRoot ("tmp_" + $timestamp)
$target     = Join-Path $stagingPath "saves"
$zipPath = Join-Path $BackupRoot ($timestamp + ".zip")

New-Item -ItemType Directory -Path $target -Force | Out-Null
Copy-Item $SourceFolder $target -Recurse -Force -ErrorAction SilentlyContinue

"Backup erstellt am $(Get-Date)" | Out-File (Join-Path $stagingPath "backup_log.txt")

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
}

Compress-Archive -Path (Join-Path $stagingPath "*") -DestinationPath $zipPath -CompressionLevel Optimal -Force
Remove-Item $stagingPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Backup abgeschlossen: $zipPath" -ForegroundColor Green
