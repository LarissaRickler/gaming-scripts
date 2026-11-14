param(
    [string]$GameRoot = "C:\Program Files (x86)\GOG Galaxy\Games\The Witcher Enhanced Edition"
)

Write-Host "=== Witcher 1 Mod Manager Cleanup ==="

$overrideRoot = Join-Path $GameRoot "Data\Override"
$gameDataRoot = Join-Path $GameRoot "Data"

function Merge-MoveFolder {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [switch]$ConfirmOverwrite
    )

    if (!(Test-Path $SourcePath)) {
        return
    }

    if (!(Test-Path $DestinationPath)) {
        $destinationParent = Split-Path $DestinationPath -Parent
        if ($destinationParent -and !(Test-Path $destinationParent)) {
            New-Item -ItemType Directory -Path $destinationParent -Force | Out-Null
        }

        Move-Item -LiteralPath $SourcePath -Destination $DestinationPath -Force -ErrorAction Continue
        return
    }

    # If destination exists and confirmation is requested, ask user
    if ($ConfirmOverwrite) {
        $response = Read-Host "Destination '$DestinationPath' already exists. Overwrite? (Y/N)"
        if ($response -ne 'Y' -and $response -ne 'y') {
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            return
        }
    }

    Get-ChildItem -LiteralPath $SourcePath -Force -ErrorAction Continue | ForEach-Object {
        $targetPath = Join-Path $DestinationPath $_.Name

        if ($_.PSIsContainer -and (Test-Path $targetPath)) {
            Merge-MoveFolder -SourcePath $_.FullName -DestinationPath $targetPath
            continue
        }

        Move-Item -LiteralPath $_.FullName -Destination $DestinationPath -Force -ErrorAction Continue
    }

    if (!(Get-ChildItem -LiteralPath $SourcePath -Force -ErrorAction SilentlyContinue | Select-Object -First 1)) {
        Remove-Item -LiteralPath $SourcePath -Force -ErrorAction SilentlyContinue
    }
}

$dataSources = @()

$topLevelDataWrapper = Join-Path $overrideRoot "Data"
if (Test-Path $topLevelDataWrapper) {
    $dataSources += $topLevelDataWrapper
}

$nestedDataWrappers = Get-ChildItem -LiteralPath $overrideRoot -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'Data' -and $_.FullName -ne $topLevelDataWrapper } |
    Select-Object -ExpandProperty FullName

$dataSources += $nestedDataWrappers

$dataSources |
    Sort-Object -Property Length -Descending -Unique |
    ForEach-Object {
        Merge-MoveFolder -SourcePath $_ -DestinationPath $gameDataRoot
    }

$wrapperSources = Get-ChildItem -LiteralPath $overrideRoot -Directory -Recurse -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -eq 'Override' -and $_.FullName -ne $overrideRoot } |
    Select-Object -ExpandProperty FullName

$wrapperSources |
    Sort-Object -Property Length -Descending -Unique |
    ForEach-Object {
        Merge-MoveFolder -SourcePath $_ -DestinationPath $overrideRoot
    }

$moves = @(
    @{ Source = (Join-Path $overrideRoot "modules"); Destination = (Join-Path $GameRoot "Data\modules"); Confirm = $true },
    @{ Source = (Join-Path $overrideRoot "Scripts"); Destination = (Join-Path $GameRoot "Data\Scripts"); Confirm = $true },
    @{ Source = (Join-Path $overrideRoot "System"); Destination = (Join-Path $GameRoot "System"); Confirm = $true }
)

foreach ($move in $moves) {
    Merge-MoveFolder -SourcePath $move.Source -DestinationPath $move.Destination -ConfirmOverwrite:$move.Confirm
}

Write-Host "Cleanup abgeschlossen." -ForegroundColor Green