# 🔍 Antigravity Code Quality Skills

**Pre-push code simplification and multi-perspective code review for [Antigravity](https://github.com/google-deepmind/antigravity).**

Adapted from the official [Claude Code plugins](https://github.com/anthropics/claude-plugins-official) by Anthropic, re-engineered for the Antigravity AI coding assistant.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

[🇮🇹 Leggi in italiano](README_IT.md)

---

## What's Included

| Component | Path | Purpose |
|-----------|------|---------|
| **Code Simplifier** | `skills/code-simplifier/SKILL.md` | Refines code for clarity, consistency, and maintainability |
| **Code Review** | `skills/code-review/SKILL.md` | Multi-perspective review with confidence scoring |
| **Pre-Push Workflow** | `workflows/pre-push.md` | Orchestrates both tools before `git push` |

## How It Works

### Code Simplifier

Analyzes recently modified files and applies refinements that:

- **Reduce complexity** — flatten nesting, simplify conditionals
- **Eliminate redundancy** — dead code, unused variables, duplication
- **Improve naming** — rename unclear variables and functions
- **Remove noise** — obvious comments, commented-out code
- **Fix inconsistencies** — mixed formatting, inconsistent patterns

**Golden rule:** Never change what the code does — only how it's written.

### Code Review

Performs a thorough multi-perspective review of your changes:

| Perspective | What It Checks |
|-------------|---------------|
| **Project Rules** | Compliance with project conventions (CLAUDE.md, CONVENTIONS.md, etc.) |
| **Bug Detection** | Obvious bugs: null access, off-by-one, race conditions, resource leaks |
| **Historical Context** | `git blame` / `git log` analysis for contradictions with past changes |
| **Comment Compliance** | Ensures changes don't violate assumptions in code comments |

Each issue gets a **confidence score (0-100)**. Only issues scoring **≥ 80** are reported, aggressively filtering false positives.

### Pre-Push Workflow

The recommended way to use both tools together:

```
/pre-push
```

This runs **after your commits, before pushing**:

1. ✅ Checks for unpushed commits
2. 🧹 Runs **Code Simplifier** on modified files
3. 💬 Asks if you want to commit the simplifications
4. 🔍 Runs **Code Review** on the final diff
5. 📋 Presents the review report
6. ✅ Confirms it's safe to push (or flags issues)

---

## Installation

### macOS / Linux

**One-line install** (works even without `git` — falls back to `curl` or `wget`):

```bash
curl -fsSL https://raw.githubusercontent.com/ManoloZocco/antigravity-code-quality/main/install.sh | bash
```

Or if you prefer not to pipe to bash:

```bash
# Download and inspect the script first
curl -fsSL https://raw.githubusercontent.com/ManoloZocco/antigravity-code-quality/main/install.sh -o install.sh
cat install.sh       # review it
bash install.sh      # run it
```

### Windows (PowerShell)

**One-line install** (uses `Invoke-WebRequest` built into PowerShell — no `git` required):

```powershell
irm https://raw.githubusercontent.com/ManoloZocco/antigravity-code-quality/main/install.ps1 | iex
```

Or download and inspect first:

```powershell
# Download and review
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ManoloZocco/antigravity-code-quality/main/install.ps1" -OutFile install.ps1
Get-Content install.ps1    # review it
.\install.ps1              # run it
```

**With winget** (if you need git first):

```powershell
winget install --id Git.Git -e --source winget
git clone https://github.com/ManoloZocco/antigravity-code-quality.git $env:TEMP\acq
& "$env:TEMP\acq\install.ps1"
Remove-Item -Recurse -Force "$env:TEMP\acq"
```

### Manual Install (any OS)

If you prefer to copy files manually:

1. Download or clone this repository
2. Copy `skills/code-simplifier/SKILL.md` to `~/.gemini/antigravity/skills/code-simplifier/SKILL.md`
3. Copy `skills/code-review/SKILL.md` to `~/.gemini/antigravity/skills/code-review/SKILL.md`
4. Copy `workflows/pre-push.md` to `~/.gemini/antigravity/global_workflows/pre-push.md`

> **Note:** On Windows, `~` is `%USERPROFILE%` (usually `C:\Users\YourName`).

### What the installer handles

The install scripts automatically handle missing tools:

| Priority | macOS/Linux | Windows |
|----------|-------------|---------|
| 1st | `git clone` | `git clone` |
| 2nd | `curl` + `unzip`/`tar` | `Invoke-WebRequest` (built-in) |
| 3rd | `wget` + `tar` | — |
| 4th | Local copy (if run from repo) | Local copy (if run from repo) |

If none of these work, the script tells you exactly what to install and how.

### Verify Installation

```bash
# macOS/Linux
ls ~/.gemini/antigravity/skills/code-simplifier/SKILL.md
ls ~/.gemini/antigravity/skills/code-review/SKILL.md
ls ~/.gemini/antigravity/global_workflows/pre-push.md
```

```powershell
# Windows
Test-Path "$env:USERPROFILE\.gemini\antigravity\skills\code-simplifier\SKILL.md"
Test-Path "$env:USERPROFILE\.gemini\antigravity\skills\code-review\SKILL.md"
Test-Path "$env:USERPROFILE\.gemini\antigravity\global_workflows\pre-push.md"
```

---

## Usage

### Option 1: Pre-Push Workflow (recommended)

After making your commits and before pushing:

```
/pre-push
```

### Option 2: Individual Skills

You can invoke each skill independently:

- *"Run code-simplifier on the files I modified"*
- *"Do a code review of my unpushed commits"*
- *"Simplify the code in src/auth.rs"*
- *"Review my last 3 commits"*

### Configuration

#### Code Review Threshold

The default confidence threshold is **80**. You can adjust it:

- *"Run code review with a threshold of 60"* — more sensitive, catches more issues
- *"Run code review with a threshold of 90"* — stricter, only very high confidence issues

#### Review Focus

You can tell Antigravity to focus on specific aspects:

- *"Focus the code review on security"*
- *"Focus on performance issues"*
- *"Check for accessibility issues"*

---

## Architecture Decisions

### Why after commit, before push?

- The commit captures your work state
- If simplification generates changes, you can `git commit --fixup` before pushing
- Doesn't interrupt your coding flow

### Why simplifier first, then review?

1. **Simplifier** cleans up style and clarity issues
2. **Review** then analyzes *already-clean* code for real bugs
3. This reduces false positives — the review won't flag style issues that the simplifier would have fixed

### Differences from Claude Code Plugins

| Claude Code | Antigravity |
|-------------|-------------|
| Parallel sub-agents (Haiku/Sonnet) | Sequential single-agent analysis |
| GitHub PR integration via `gh` CLI | Local `git diff` analysis |
| Posts comments on PRs | Inline reports in conversation |
| `.claude-plugin` manifests | `SKILL.md` with YAML frontmatter |

## Requirements

- [Antigravity](https://github.com/google-deepmind/antigravity) installed and configured
- Git repository with a remote configured (`git push` target)
- No additional dependencies

## License

MIT — see [LICENSE](LICENSE).

## Credits

- Original plugins by [Anthropic](https://github.com/anthropics/claude-plugins-official)
- Adapted for Antigravity by [@ManoloZocco](https://github.com/ManoloZocco)
