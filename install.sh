#!/usr/bin/env bash
set -e

echo -e "\033[36m+============================================================+\033[0m"
echo -e "\033[36m|       Antigravity Code Quality Skills - Installer          |\033[0m"
echo -e "\033[36m+============================================================+\033[0m"
echo ""

ANTIGRAVITY_DIR="$HOME/.gemini/antigravity"

if [ ! -d "$ANTIGRAVITY_DIR" ]; then
    echo -e "\033[31m[ERROR]\033[0m Antigravity non trovato in $ANTIGRAVITY_DIR"
    echo -e "\033[33m[INFO]\033[0m Installa prima Antigravity per continuare."
    exit 1
fi

echo -e "\033[32m[OK]\033[0m Antigravity found at $ANTIGRAVITY_DIR"
echo -e "\033[36m[INFO]\033[0m Fetching repository files...\033[0m"

TEMP_DIR=$(mktemp -d)
ZIP_FILE="$TEMP_DIR/main.zip"
ZIP_URL="https://github.com/ManoloZocco/antigravity-code-quality/archive/refs/heads/main.zip"

echo -e "\033[36m[INFO]\033[0m Downloading archive...\033[0m"
curl -sL "$ZIP_URL" -o "$ZIP_FILE"

echo -e "\033[36m[INFO]\033[0m Extracting files...\033[0m"
unzip -q "$ZIP_FILE" -d "$TEMP_DIR"

# Trova la cartella appena estratta
EXTRACTED_DIR=$(find "$TEMP_DIR" -mindepth 1 -maxdepth 1 -type d | head -n 1)

if [ -z "$EXTRACTED_DIR" ]; then
    echo -e "\033[31m[ERROR]\033[0m Nessuna cartella trovata nell'archivio ZIP."
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo -e "\033[36m[INFO]\033[0m Installing skills and workflows...\033[0m"

if [ -d "$EXTRACTED_DIR/skills" ]; then
    mkdir -p "$ANTIGRAVITY_DIR/skills"
    cp -r "$EXTRACTED_DIR/skills/"* "$ANTIGRAVITY_DIR/skills/"
    echo -e "\033[32m[OK]\033[0m Skills installate."
fi

if [ -d "$EXTRACTED_DIR/workflows" ]; then
    mkdir -p "$ANTIGRAVITY_DIR/workflows"
    cp -r "$EXTRACTED_DIR/workflows/"* "$ANTIGRAVITY_DIR/workflows/"
    echo -e "\033[32m[OK]\033[0m Workflows installati."
fi

# Pulizia dei file temporanei
rm -rf "$TEMP_DIR"
echo -e "\n\033[32m[OK]\033[0m Installazione completata con successo!"
