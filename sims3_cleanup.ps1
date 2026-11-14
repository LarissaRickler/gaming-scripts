# sims3_cleanup.ps1
# Löscht Cache, Logs, Crash-Dumps – lässt Saves & Mods unangetastet

param(
    [string]$BasePath = (Join-Path $env:USERPROFILE "Documents\Electronic Arts\The Sims 3")
)

Write-Host "=== Sims 3 Cleanup ==="

if (!(Test-Path $BasePath)) {
    Write-Host "Sims-3-Ordner nicht gefunden!" -ForegroundColor Red
    exit 1
}

$cacheFiles = @(
    "CASPartCache.package","compositorCache.package","scriptCache.package",
    "simCompositorCache.package","socialCache.package"
)

$cacheFolders = @("SigsCache","Thumbnails","IGACache","FeaturedItems")

$logFiles = @("Sims3LauncherLogFile.log","tslus.bin")

Remove-Item "$BasePath\ScriptError_*.xml" -Force -ErrorAction SilentlyContinue
Remove-Item "$BasePath\*.mdmp"           -Force -ErrorAction SilentlyContinue
Remove-Item "$BasePath\xcpt *.txt"       -Force -ErrorAction SilentlyContinue

foreach ($file in $cacheFiles)   { Remove-Item (Join-Path $BasePath $file) -Force -ErrorAction SilentlyContinue }
foreach ($folder in $cacheFolders){ Remove-Item (Join-Path $BasePath $folder) -Recurse -Force -ErrorAction SilentlyContinue }
foreach ($file in $logFiles)     { Remove-Item (Join-Path $BasePath $file) -Force -ErrorAction SilentlyContinue }

$dcBackup = Join-Path $BasePath "DCBackup"
if (Test-Path $dcBackup) {
    Get-ChildItem $dcBackup -File | Where-Object { $_.Name -ne "ccmerged.package" } |
        ForEach-Object { Remove-Item $_.FullName -Force }
}

Write-Host "Cleanup abgeschlossen." -ForegroundColor Green