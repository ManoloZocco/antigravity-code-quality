#!/usr/bin/env bash
# ============================================================================
# Antigravity Code Quality Skills — Installer (macOS / Linux)
# ============================================================================
# This script installs the code-simplifier skill, code-review skill,
# and pre-push workflow into your Antigravity installation.
#
# It handles missing dependencies gracefully:
#   1. Tries git clone
#   2. Falls back to curl (download zip)
#   3. Falls back to wget (download zip)
#   4. Falls back to manual copy (if run from the repo directory)
# ============================================================================

set -euo pipefail

# --- Configuration ---
REPO_URL="https://github.com/ManoloZocco/antigravity-code-quality"
ZIP_URL="${REPO_URL}/archive/refs/heads/main.zip"
TAR_URL="${REPO_URL}/archive/refs/heads/main.tar.gz"
ANTIGRAVITY_DIR="${HOME}/.gemini/antigravity"
SKILLS_DIR="${ANTIGRAVITY_DIR}/skills"
WORKFLOWS_DIR="${ANTIGRAVITY_DIR}/global_workflows"
TMP_DIR=$(mktemp -d)

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Helpers ---
info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[OK]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

cleanup() {
    rm -rf "$TMP_DIR" 2>/dev/null || true
}
trap cleanup EXIT

# --- Check Antigravity ---
check_antigravity() {
    if [ ! -d "$ANTIGRAVITY_DIR" ]; then
        error "Antigravity directory not found at: $ANTIGRAVITY_DIR"
        echo ""
        echo "  Antigravity must be installed before running this script."
        echo "  Expected directory: $ANTIGRAVITY_DIR"
        echo ""
        exit 1
    fi
    success "Antigravity found at $ANTIGRAVITY_DIR"
}

# --- Ensure target directories exist ---
ensure_dirs() {
    mkdir -p "$SKILLS_DIR/code-simplifier" 2>/dev/null || true
    mkdir -p "$SKILLS_DIR/code-review"     2>/dev/null || true
    mkdir -p "$WORKFLOWS_DIR"              2>/dev/null || true
}

# --- Download methods (in order of preference) ---

download_with_git() {
    if ! command -v git &>/dev/null; then
        return 1
    fi
    info "Downloading with git..."
    git clone --depth 1 "$REPO_URL.git" "$TMP_DIR/repo" 2>/dev/null
    return $?
}

download_with_curl() {
    if ! command -v curl &>/dev/null; then
        return 1
    fi
    info "Downloading with curl..."
    curl -sL "$ZIP_URL" -o "$TMP_DIR/repo.zip"
    if command -v unzip &>/dev/null; then
        unzip -q "$TMP_DIR/repo.zip" -d "$TMP_DIR"
        mv "$TMP_DIR"/antigravity-code-quality-main "$TMP_DIR/repo"
        return 0
    fi
    # If no unzip, try tar with the tar.gz URL
    curl -sL "$TAR_URL" -o "$TMP_DIR/repo.tar.gz"
    tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"
    mv "$TMP_DIR"/antigravity-code-quality-main "$TMP_DIR/repo"
    return $?
}

download_with_wget() {
    if ! command -v wget &>/dev/null; then
        return 1
    fi
    info "Downloading with wget..."
    wget -q "$TAR_URL" -O "$TMP_DIR/repo.tar.gz"
    tar -xzf "$TMP_DIR/repo.tar.gz" -C "$TMP_DIR"
    mv "$TMP_DIR"/antigravity-code-quality-main "$TMP_DIR/repo"
    return $?
}

copy_from_local() {
    # If the script is run from inside the repo directory
    local script_dir
    script_dir="$(cd "$(dirname "$0")" && pwd)"
    if [ -f "$script_dir/skills/code-simplifier/SKILL.md" ] && \
       [ -f "$script_dir/skills/code-review/SKILL.md" ] && \
       [ -f "$script_dir/workflows/pre-push.md" ]; then
        info "Using local repository files..."
        mkdir -p "$TMP_DIR/repo"
        cp -r "$script_dir/skills" "$TMP_DIR/repo/"
        cp -r "$script_dir/workflows" "$TMP_DIR/repo/"
        return 0
    fi
    return 1
}

# --- Download logic ---
download_repo() {
    info "Fetching repository files..."
    echo ""

    if download_with_git; then
        success "Downloaded with git"
    elif download_with_curl; then
        success "Downloaded with curl"
    elif download_with_wget; then
        success "Downloaded with wget"
    elif copy_from_local; then
        success "Using local files"
    else
        error "Could not download the repository."
        echo ""
        echo "  None of the following tools were found: git, curl, wget"
        echo "  And the script is not being run from the repo directory."
        echo ""
        echo "  Please install one of:"
        echo "    macOS:  brew install git       (or: xcode-select --install)"
        echo "    Ubuntu: sudo apt install git"
        echo "    Fedora: sudo dnf install git"
        echo ""
        echo "  Or download manually from: $REPO_URL"
        echo ""
        exit 1
    fi
    echo ""
}

# --- Install files ---
install_files() {
    local src="$TMP_DIR/repo"

    info "Installing skills and workflow..."

    # Code Simplifier
    if [ -f "$src/skills/code-simplifier/SKILL.md" ]; then
        cp "$src/skills/code-simplifier/SKILL.md" "$SKILLS_DIR/code-simplifier/SKILL.md"
        success "Installed: code-simplifier skill"
    else
        error "code-simplifier/SKILL.md not found in download"
        exit 1
    fi

    # Code Review
    if [ -f "$src/skills/code-review/SKILL.md" ]; then
        cp "$src/skills/code-review/SKILL.md" "$SKILLS_DIR/code-review/SKILL.md"
        success "Installed: code-review skill"
    else
        error "code-review/SKILL.md not found in download"
        exit 1
    fi

    # Pre-Push Workflow
    if [ -f "$src/workflows/pre-push.md" ]; then
        cp "$src/workflows/pre-push.md" "$WORKFLOWS_DIR/pre-push.md"
        success "Installed: pre-push workflow"
    else
        error "workflows/pre-push.md not found in download"
        exit 1
    fi

    echo ""
}

# --- Verify installation ---
verify() {
    info "Verifying installation..."
    local ok=true

    [ -f "$SKILLS_DIR/code-simplifier/SKILL.md" ] && success "  ✓ code-simplifier" || { error "  ✗ code-simplifier"; ok=false; }
    [ -f "$SKILLS_DIR/code-review/SKILL.md" ]     && success "  ✓ code-review"     || { error "  ✗ code-review"; ok=false; }
    [ -f "$WORKFLOWS_DIR/pre-push.md" ]            && success "  ✓ pre-push"        || { error "  ✗ pre-push"; ok=false; }

    echo ""
    if $ok; then
        success "Installation complete! 🎉"
        echo ""
        echo "  Usage: type /pre-push in Antigravity after your commits, before pushing."
        echo ""
    else
        error "Some files failed to install. Please try manual installation."
        exit 1
    fi
}

# --- Main ---
main() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║       Antigravity Code Quality Skills — Installer          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    check_antigravity
    ensure_dirs
    download_repo
    install_files
    verify
}

main "$@"
