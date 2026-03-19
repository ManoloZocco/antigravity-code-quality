# 🔍 Antigravity Code Quality Skills

**Semplificazione del codice e code review multi-prospettiva pre-push per [Antigravity](https://github.com/google-deepmind/antigravity).**

Adattati dai [plugin ufficiali di Claude Code](https://github.com/anthropics/claude-plugins-official) di Anthropic, re-ingegnerizzati per l'assistente di coding AI Antigravity.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

[🇬🇧 Read in English](README.md)

---

## Cosa include

| Componente | Percorso | Funzione |
|------------|----------|----------|
| **Code Simplifier** | `skills/code-simplifier/SKILL.md` | Semplifica il codice per chiarezza, consistenza e manutenibilità |
| **Code Review** | `skills/code-review/SKILL.md` | Review multi-prospettiva con scoring di confidenza |
| **Workflow Pre-Push** | `workflows/pre-push.md` | Orchestra entrambi gli strumenti prima di `git push` |

## Come funziona

### Code Simplifier

Analizza i file modificati di recente e applica miglioramenti che:

- **Riducono la complessità** — appiattisce nesting, semplifica condizionali
- **Eliminano la ridondanza** — codice morto, variabili inutilizzate, duplicazioni
- **Migliorano il naming** — rinomina variabili e funzioni poco chiare
- **Rimuovono il rumore** — commenti ovvi, codice commentato
- **Correggono inconsistenze** — formattazione mista, pattern incoerenti

**Regola d'oro:** Non cambia mai cosa fa il codice — solo come è scritto.

### Code Review

Esegue una review approfondita multi-prospettiva delle tue modifiche:

| Prospettiva | Cosa controlla |
|-------------|---------------|
| **Regole di progetto** | Conformità a convenzioni del progetto (CLAUDE.md, CONVENTIONS.md, ecc.) |
| **Rilevamento bug** | Bug ovvi: accesso a null, off-by-one, race condition, resource leak |
| **Contesto storico** | Analisi `git blame` / `git log` per contraddizioni con modifiche passate |
| **Conformità ai commenti** | Verifica che le modifiche non violino assunzioni nei commenti del codice |

Ogni issue riceve un **punteggio di confidenza (0-100)**. Solo le issue con punteggio **≥ 80** vengono riportate, filtrando aggressivamente i falsi positivi.

### Workflow Pre-Push

Il modo consigliato per usare entrambi gli strumenti insieme:

```
/pre-push
```

Si esegue **dopo i commit, prima del push**:

1. ✅ Controlla che ci siano commit non pushati
2. 🧹 Esegue il **Code Simplifier** sui file modificati
3. 💬 Chiede se vuoi committare le semplificazioni
4. 🔍 Esegue la **Code Review** sul diff finale
5. 📋 Presenta il report di review
6. ✅ Conferma che è sicuro pushare (o segnala problemi)

---

## Installazione

### macOS / Linux

**Installazione con un comando** (funziona anche senza `git` — fallback su `curl` o `wget`):

```bash
curl -fsSL https://raw.githubusercontent.com/ManoloZocco/antigravity-code-quality/main/install.sh | bash
```

Oppure, se preferisci ispezionare lo script prima:

```bash
# Scarica e controlla lo script
curl -fsSL https://raw.githubusercontent.com/ManoloZocco/antigravity-code-quality/main/install.sh -o install.sh
cat install.sh       # leggilo
bash install.sh      # eseguilo
```

**Con Homebrew** (se hai `git` via brew):

```bash
git clone https://github.com/ManoloZocco/antigravity-code-quality.git /tmp/acq
bash /tmp/acq/install.sh
rm -rf /tmp/acq
```

### Windows (PowerShell)

**Installazione con un comando** (usa `Invoke-WebRequest` integrato in PowerShell — non serve `git`):

```powershell
irm https://raw.githubusercontent.com/ManoloZocco/antigravity-code-quality/main/install.ps1 | iex
```

Oppure scarica e controlla prima:

```powershell
# Scarica e controlla
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ManoloZocco/antigravity-code-quality/main/install.ps1" -OutFile install.ps1
Get-Content install.ps1    # leggilo
.\install.ps1              # eseguilo
```

**Con winget** (se devi installare git prima):

```powershell
winget install --id Git.Git -e --source winget
git clone https://github.com/ManoloZocco/antigravity-code-quality.git $env:TEMP\acq
& "$env:TEMP\acq\install.ps1"
Remove-Item -Recurse -Force "$env:TEMP\acq"
```

### Installazione manuale (qualsiasi OS)

Se preferisci copiare i file a mano:

1. Scarica o clona questa repository
2. Copia `skills/code-simplifier/SKILL.md` in `~/.gemini/antigravity/skills/code-simplifier/SKILL.md`
3. Copia `skills/code-review/SKILL.md` in `~/.gemini/antigravity/skills/code-review/SKILL.md`
4. Copia `workflows/pre-push.md` in `~/.gemini/antigravity/global_workflows/pre-push.md`

> **Nota:** Su Windows, `~` corrisponde a `%USERPROFILE%` (di solito `C:\Users\TuoNome`).

### Cosa gestisce l'installer

Gli script di installazione gestiscono automaticamente tool mancanti:

| Priorità | macOS/Linux | Windows |
|----------|-------------|---------|
| 1° | `git clone` | `git clone` |
| 2° | `curl` + `unzip`/`tar` | `Invoke-WebRequest` (integrato) |
| 3° | `wget` + `tar` | — |
| 4° | Copia locale (se eseguito dalla repo) | Copia locale (se eseguito dalla repo) |

Se nessuno di questi funziona, lo script ti dice esattamente cosa installare e come.

### Verifica installazione

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

## Utilizzo

### Opzione 1: Workflow Pre-Push (consigliato)

Dopo aver fatto i commit e prima di pushare:

```
/pre-push
```

### Opzione 2: Skill individuali

Puoi invocare ogni skill separatamente:

- *"Esegui il code-simplifier sui file che ho modificato"*
- *"Fai una code review dei miei commit non pushati"*
- *"Semplifica il codice in src/auth.rs"*
- *"Rivedi i miei ultimi 3 commit"*

### Configurazione

#### Soglia Code Review

La soglia di confidenza predefinita è **80**. Puoi modificarla:

- *"Esegui la code review con soglia 60"* — più sensibile, trova più problemi
- *"Esegui la code review con soglia 90"* — più restrittiva, solo issue ad alta confidenza

#### Focus della review

Puoi dire ad Antigravity di concentrarsi su aspetti specifici:

- *"Concentra la code review sulla sicurezza"*
- *"Concentrati sui problemi di performance"*
- *"Controlla eventuali problemi di accessibilità"*

---

## Decisioni architetturali

### Perché dopo il commit, prima del push?

- Il commit cattura lo stato del lavoro
- Se la semplificazione genera modifiche, puoi fare `git commit --fixup` prima del push
- Non interrompe il flusso di lavoro durante la scrittura

### Perché prima il simplifier, poi la review?

1. Il **simplifier** ripulisce problemi di stile e chiarezza
2. La **review** analizza codice *già pulito* per bug reali
3. Questo riduce i falsi positivi — la review non segnalerà problemi di stile che il simplifier avrebbe già corretto

### Differenze rispetto ai plugin Claude Code

| Claude Code | Antigravity |
|-------------|-------------|
| Sub-agents paralleli (Haiku/Sonnet) | Analisi sequenziale singolo agente |
| Integrazione GitHub PR via `gh` CLI | Analisi locale via `git diff` |
| Pubblica commenti su PR | Report inline nella conversazione |
| Manifest `.claude-plugin` | `SKILL.md` con frontmatter YAML |

## Requisiti

- [Antigravity](https://github.com/google-deepmind/antigravity) installato e configurato
- Repository Git con remote configurato (target per `git push`)
- Nessuna dipendenza aggiuntiva

## Licenza

MIT — vedi [LICENSE](LICENSE).

## Crediti

- Plugin originali di [Anthropic](https://github.com/anthropics/claude-plugins-official)
- Adattati per Antigravity da [@ManoloZocco](https://github.com/ManoloZocco)
