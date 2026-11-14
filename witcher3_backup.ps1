# witcher3_backup.ps1
# Backup wichtiger Witcher-3-Dokumentendateien

param(
    [string]$SourceRoot = (Join-Path $env:USERPROFILE "Documents\The Witcher 3"),
    [string]$BackupRoot = "C:\Users\laris\OneDrive\Dokumente\Gaming\The Witcher 3 - Backup"
)

Write-Host "=== Witcher 3 Backup ==="

if (!(Test-Path $SourceRoot)) {
    Write-Host "Witcher-3-Ordner nicht gefunden!" -ForegroundColor Red
    exit 1
}

$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$stagingPath = Join-Path $BackupRoot ("tmp_" + $timestamp)
$zipPath = Join-Path $BackupRoot ($timestamp + ".zip")
New-Item -ItemType Directory -Path $stagingPath -Force | Out-Null

$items = @(
    "steam_autocloud.vdf","gamesaves","dx12user.settings","dx12user.settings.bak",
    "input.settings","mods.settings","profile.settings","profile.settings.bak"
)

foreach ($item in $items) {
    $src = Join-Path $SourceRoot $item
    $dst = Join-Path $stagingPath $item
    if (Test-Path $src) {
        Copy-Item $src $dst -Recurse -Force -ErrorAction SilentlyContinue
    }
}

"Backup erstellt am $(Get-Date)" | Out-File (Join-Path $stagingPath "backup_log.txt")

if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
}

Compress-Archive -Path (Join-Path $stagingPath "*") -DestinationPath $zipPath -CompressionLevel Optimal -Force
Remove-Item $stagingPath -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "Backup abgeschlossen: $zipPath" -ForegroundColor Green