<!-- .github/copilot-instructions.md for small PowerShell scripts repo -->
# Copilot / AI Agent Instructions

Purpose: Help an AI coding agent quickly understand and edit this repo of small Windows PowerShell utility scripts (backups/cleanup for games).

**Big Picture:**
- **Repo type:** Collection of standalone PowerShell scripts in the `scripts` folder. Each script targets a specific game and operation (backup or cleanup).
- **Naming convention:** `<game>_<action>.ps1` (e.g., `sims4_modmanager_backup.ps1`, `witcher3_backup.ps1`). Use this pattern when adding new scripts.
- **Execution model:** Scripts are intended to be run directly on Windows PowerShell (v5.1) and often assume the current user environment (`$env:USERPROFILE`, `Documents`) and OneDrive paths.

**Key files to inspect:**
- `sims4_modmanager_backup.ps1` — example backup script; demonstrates parameter usage, `$SourceRoot` / `$BackupRoot`, timestamped backup directories, folder/file lists, and selective copying.
- `sims4_modmanager_cleanup.ps1`, `sims3_backup.ps1`, `sims3_cleanup.ps1`, `witcher1_backup.ps1`, `witcher3_backup.ps1` — other examples following same conventions.

**Environment & assumptions (explicit):**
- Target OS: Windows. Primary shell: PowerShell (tested on v5.1).
- Scripts assume user-local paths (e.g., Documents, OneDrive). Avoid hardcoding other users' absolute paths unless guarded by parameters.
- Execution policy: authors run scripts locally. For non-interactive use, call PowerShell with `-ExecutionPolicy Bypass -File`.

**Common patterns and conventions to preserve:**
- Scripts accept `param()` with sensible defaults (use `$env:USERPROFILE` and `Join-Path` where appropriate).
- Backup scripts create a timestamped folder in the backup root (non-destructive, additive backups).
- Use `Test-Path` to confirm sources before copying; prefer `Copy-Item -Recurse -Force -ErrorAction SilentlyContinue` for robustness.
- Minimal error handling: scripts typically `Write-Host` errors and `exit 1` for fatal conditions. Preserve existing exit behavior unless adding improved handling.

**Editing guidance / PR conventions for AI:**
- When adding features, keep changes minimal and focused to the single relevant script.
- If changing a default path, add it as a `param()` default and do not overwrite user's files silently.
- Keep console messages consistent (current scripts include German messages). Match existing language unless the change is explicitly to internationalize the repo.

**Examples (how to run / test):**
- Run a backup interactively (recommended during edits):
```
powershell.exe -ExecutionPolicy Bypass -File .\sims4_modmanager_backup.ps1
```
- Run with a custom backup root:
```
powershell.exe -ExecutionPolicy Bypass -File .\sims4_modmanager_backup.ps1 -BackupRoot "C:\Temp\Sims4Backup"
```

**What to look for when changing code:**
- Preserve timestamped backups and folder lists unless the change explicitly modifies which folders are backed up.
- Ensure `Test-Path` checks remain in place to avoid creating empty or incorrect backups.
- Prefer adding parameters over changing hardcoded strings for user-specific paths.

**Integration points & external dependencies:**
- OneDrive / `Documents` path usage — changes here affect where backups are stored. Be explicit about consequences.
- No external modules declared; keep dependencies to built-in PowerShell where possible.

If anything here is unclear or you want additional examples (e.g., standardized logging, adding unit-style tests with Pester), tell me which part to expand and I will iterate.
