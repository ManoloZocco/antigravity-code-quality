# ============================================================================
# Antigravity Code Quality Skills — Installer (Windows PowerShell)
# ============================================================================
# This script installs the code-simplifier skill, code-review skill,
# and pre-push workflow into your Antigravity installation.
#
# It handles missing dependencies gracefully:
#   1. Tries git clone
#   2. Falls back to Invoke-WebRequest (built-in PowerShell)
#   3. Falls back to local copy (if run from the repo directory)
# ============================================================================

$ErrorActionPreference = "Stop"

# --- Configuration ---
$RepoUrl   = "https://github.com/ManoloZocco/antigravity-code-quality"
$ZipUrl    = "$RepoUrl/archive/refs/heads/main.zip"
$AntigravityDir = "$env:USERPROFILE\.gemini\antigravity"
$SkillsDir      = "$AntigravityDir\skills"
$WorkflowsDir   = "$AntigravityDir\global_workflows"
$TmpDir         = Join-Path ([System.IO.Path]::GetTempPath()) "acq-install-$(Get-Random)"

# --- Helpers ---
function Write-Info    { param($msg) Write-Host "[INFO] "  -ForegroundColor Blue  -NoNewline; Write-Host $msg }
function Write-Success { param($msg) Write-Host "[OK] "    -ForegroundColor Green -NoNewline; Write-Host $msg }
function Write-Warn    { param($msg) Write-Host "[WARN] "  -ForegroundColor Yellow -NoNewline; Write-Host $msg }
function Write-Err     { param($msg) Write-Host "[ERROR] " -ForegroundColor Red   -NoNewline; Write-Host $msg }

function Cleanup {
    if (Test-Path $TmpDir) {
        Remove-Item -Recurse -Force $TmpDir -ErrorAction SilentlyContinue
    }
}

# --- Check Antigravity ---
function Check-Antigravity {
    if (-not (Test-Path $AntigravityDir)) {
        Write-Err "Antigravity directory not found at: $AntigravityDir"
        Write-Host ""
        Write-Host "  Antigravity must be installed before running this script."
        Write-Host "  Expected directory: $AntigravityDir"
        Write-Host ""
        exit 1
    }
    Write-Success "Antigravity found at $AntigravityDir"
}

# --- Ensure target directories exist ---
function Ensure-Dirs {
    New-Item -ItemType Directory -Path "$SkillsDir\code-simplifier" -Force | Out-Null
    New-Item -ItemType Directory -Path "$SkillsDir\code-review"     -Force | Out-Null
    New-Item -ItemType Directory -Path $WorkflowsDir                -Force | Out-Null
    New-Item -ItemType Directory -Path $TmpDir                      -Force | Out-Null
}

# --- Download methods ---

function Download-WithGit {
    try {
        $null = Get-Command git -ErrorAction Stop
        Write-Info "Downloading with git..."
        git clone --depth 1 "$RepoUrl.git" "$TmpDir\repo" 2>$null
        return $true
    } catch {
        return $false
    }
}

function Download-WithWebRequest {
    try {
        Write-Info "Downloading with Invoke-WebRequest..."
        $zipPath = "$TmpDir\repo.zip"
        
        # PowerShell 5+ has Invoke-WebRequest built-in
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $ZipUrl -OutFile $zipPath -UseBasicParsing
        
        # Extract zip
        Expand-Archive -Path $zipPath -DestinationPath $TmpDir -Force
        Rename-Item "$TmpDir\antigravity-code-quality-main" "$TmpDir\repo"
        
        return $true
    } catch {
        Write-Warn "WebRequest failed: $_"
        return $false
    }
}

function Copy-FromLocal {
    $scriptDir = Split-Path -Parent $MyInvocation.ScriptName
    $simplifier = Join-Path $scriptDir "skills\code-simplifier\SKILL.md"
    $review     = Join-Path $scriptDir "skills\code-review\SKILL.md"
    $workflow   = Join-Path $scriptDir "workflows\pre-push.md"
    
    if ((Test-Path $simplifier) -and (Test-Path $review) -and (Test-Path $workflow)) {
        Write-Info "Using local repository files..."
        New-Item -ItemType Directory -Path "$TmpDir\repo\skills\code-simplifier" -Force | Out-Null
        New-Item -ItemType Directory -Path "$TmpDir\repo\skills\code-review"     -Force | Out-Null
        New-Item -ItemType Directory -Path "$TmpDir\repo\workflows"              -Force | Out-Null
        Copy-Item $simplifier "$TmpDir\repo\skills\code-simplifier\SKILL.md"
        Copy-Item $review     "$TmpDir\repo\skills\code-review\SKILL.md"
        Copy-Item $workflow   "$TmpDir\repo\workflows\pre-push.md"
        return $true
    }
    return $false
}

# --- Download logic ---
function Download-Repo {
    Write-Info "Fetching repository files..."
    Write-Host ""

    if (Download-WithGit) {
        Write-Success "Downloaded with git"
    } elseif (Download-WithWebRequest) {
        Write-Success "Downloaded with Invoke-WebRequest"
    } elseif (Copy-FromLocal) {
        Write-Success "Using local files"
    } else {
        Write-Err "Could not download the repository."
        Write-Host ""
        Write-Host "  Please install git:"
        Write-Host "    winget install --id Git.Git -e --source winget"
        Write-Host ""
        Write-Host "  Or download manually from: $RepoUrl"
        Write-Host ""
        Cleanup
        exit 1
    }
    Write-Host ""
}

# --- Install files ---
function Install-Files {
    $src = "$TmpDir\repo"
    
    Write-Info "Installing skills and workflow..."

    # Code Simplifier
    $simplifierSrc = "$src\skills\code-simplifier\SKILL.md"
    if (Test-Path $simplifierSrc) {
        Copy-Item $simplifierSrc "$SkillsDir\code-simplifier\SKILL.md" -Force
        Write-Success "Installed: code-simplifier skill"
    } else {
        Write-Err "code-simplifier/SKILL.md not found in download"
        Cleanup; exit 1
    }

    # Code Review
    $reviewSrc = "$src\skills\code-review\SKILL.md"
    if (Test-Path $reviewSrc) {
        Copy-Item $reviewSrc "$SkillsDir\code-review\SKILL.md" -Force
        Write-Success "Installed: code-review skill"
    } else {
        Write-Err "code-review/SKILL.md not found in download"
        Cleanup; exit 1
    }

    # Pre-Push Workflow
    $workflowSrc = "$src\workflows\pre-push.md"
    if (Test-Path $workflowSrc) {
        Copy-Item $workflowSrc "$WorkflowsDir\pre-push.md" -Force
        Write-Success "Installed: pre-push workflow"
    } else {
        Write-Err "workflows/pre-push.md not found in download"
        Cleanup; exit 1
    }

    Write-Host ""
}

# --- Verify installation ---
function Verify-Install {
    Write-Info "Verifying installation..."
    $ok = $true

    if (Test-Path "$SkillsDir\code-simplifier\SKILL.md") { Write-Success "  + code-simplifier" } else { Write-Err "  x code-simplifier"; $ok = $false }
    if (Test-Path "$SkillsDir\code-review\SKILL.md")     { Write-Success "  + code-review"     } else { Write-Err "  x code-review"; $ok = $false }
    if (Test-Path "$WorkflowsDir\pre-push.md")            { Write-Success "  + pre-push"        } else { Write-Err "  x pre-push"; $ok = $false }

    Write-Host ""
    if ($ok) {
        Write-Success "Installation complete!"
        Write-Host ""
        Write-Host "  Usage: type /pre-push in Antigravity after your commits, before pushing."
        Write-Host ""
    } else {
        Write-Err "Some files failed to install. Please try manual installation."
        Cleanup; exit 1
    }
}

# --- Main ---
function Main {
    Write-Host ""
    Write-Host "+============================================================+"
    Write-Host "|       Antigravity Code Quality Skills - Installer          |"
    Write-Host "+============================================================+"
    Write-Host ""

    Check-Antigravity
    Ensure-Dirs
    Download-Repo
    Install-Files
    Verify-Install
    Cleanup
}

Main
