$ErrorActionPreference = "Stop"

Write-Host "+============================================================+" -ForegroundColor Cyan
Write-Host "|       Antigravity Code Quality Skills - Installer          |" -ForegroundColor Cyan
Write-Host "+============================================================+" -ForegroundColor Cyan
Write-Host ""

$antigravityDir = Join-Path $HOME ".gemini\antigravity"

if (-not (Test-Path $antigravityDir)) {
    Write-Host "[ERROR] Antigravity non trovato in $antigravityDir" -ForegroundColor Red
    Write-Host "Installa prima Antigravity per continuare." -ForegroundColor Yellow
    exit 1
}

Write-Host "[OK] Antigravity found at $antigravityDir" -ForegroundColor Green
Write-Host "[INFO] Fetching repository files..." -ForegroundColor Cyan

# SOLUZIONE: Creiamo una cartella temporanea univoca per evitare conflitti
$tempDir = Join-Path $env:TEMP "antigravity_installer_$([guid]::NewGuid().ToString().Substring(0,8))"
$null = New-Item -ItemType Directory -Path $tempDir -Force

$zipPath = Join-Path $tempDir "main.zip"
$extractPath = Join-Path $tempDir "extracted"
$zipUrl = "https://github.com/ManoloZocco/antigravity-code-quality/archive/refs/heads/main.zip"

try {
    Write-Host "[INFO] Downloading with Invoke-WebRequest..." -ForegroundColor Cyan
    # UseBasicParsing previene problemi con versioni di PowerShell meno recenti
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing

    Write-Host "[INFO] Extracting files..." -ForegroundColor Cyan
    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    # Trova dinamicamente la cartella estratta (Github aggiunge il suffisso del branch all'archivio)
    $repoDir = Get-ChildItem -Path $extractPath -Directory | Select-Object -First 1

    if (-not $repoDir) {
        throw "Impossibile trovare la cartella dei file estratti nell'archivio ZIP."
    }

    Write-Host "[INFO] Installing skills and workflows..." -ForegroundColor Cyan

    $sourceSkills = Join-Path $repoDir.FullName "skills"
    $targetSkills = Join-Path $antigravityDir "skills"

    if (Test-Path $sourceSkills) {
        if (-not (Test-Path $targetSkills)) { $null = New-Item -ItemType Directory -Path $targetSkills -Force }
        Copy-Item -Path "$sourceSkills\*" -Destination $targetSkills -Recurse -Force
        Write-Host "[OK] Skills installate." -ForegroundColor Green
    }

    $sourceWorkflows = Join-Path $repoDir.FullName "workflows"
    $targetWorkflows = Join-Path $antigravityDir "workflows"

    if (Test-Path $sourceWorkflows) {
        if (-not (Test-Path $targetWorkflows)) { $null = New-Item -ItemType Directory -Path $targetWorkflows -Force }
        Copy-Item -Path "$sourceWorkflows\*" -Destination $targetWorkflows -Recurse -Force
        Write-Host "[OK] Workflows installati." -ForegroundColor Green
    }

    Write-Host "`n[OK] Installazione completata con successo!" -ForegroundColor Green

} catch {
    Write-Host "`n[ERROR] Si è verificato un errore durante l'installazione:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} finally {
    # Pulizia sicura di tutti i file di log o temporanei
    if (Test-Path $tempDir) {
        Write-Host "[INFO] Pulizia dei file temporanei..." -ForegroundColor DarkGray
        Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
