---
description: Esegue code-simplifier e code-review sui commit non pushati, prima del push. Uso - /pre-push
---

# Pre-Push Quality Check

Workflow da eseguire **dopo il commit e prima del push** per garantire la qualità del codice.

## Passaggi

### 1. Verifica stato git
// turbo
```bash
git status && git log --oneline @{push}..HEAD 2>/dev/null || git log --oneline origin/$(git branch --show-current)..HEAD
```
Se non ci sono commit non pushati, informare l'utente e terminare.

### 2. Identifica file modificati
// turbo
```bash
git diff --name-only @{push}..HEAD 2>/dev/null || git diff --name-only origin/$(git branch --show-current)..HEAD
```
Se non ci sono file modificati, informare l'utente e terminare.

### 3. Esegui Code Simplifier
Leggere la skill `code-simplifier` da `~/.gemini/antigravity/skills/code-simplifier/SKILL.md` e seguirne le istruzioni. In breve:
- Per ogni file modificato, analizzare e semplificare il codice
- Preservare la funzionalità al 100%
- Produrre un report delle modifiche

### 4. Se il simplifier ha fatto modifiche
Se sono state fatte modifiche nel passaggio 3:
- Mostrare il diff delle modifiche all'utente
- Chiedere conferma: "Vuoi committare queste semplificazioni?"
- Se sì, fare un commit con messaggio: `refactor: code simplification (pre-push)`
- Se no, annullare le modifiche con `git checkout -- .`

### 5. Esegui Code Review
Leggere la skill `code-review` da `~/.gemini/antigravity/skills/code-review/SKILL.md` e seguirne le istruzioni. In breve:
- Analizzare il diff dei commit non pushati
- Review multi-prospettiva (regole progetto, bug, contesto storico, commenti)
- Scoring di confidenza per ogni issue
- Filtrare sotto soglia 80
- Produrre report strutturato

### 6. Risultato finale
- Se **nessun issue critico**: confermare che il push è sicuro → "✅ Nessun problema trovato. Puoi pushare."
- Se **ci sono issue**: presentare il report e chiedere all'utente come procedere:
  - "Vuoi che corregga questi problemi?"
  - "Vuoi pushare comunque?"
  - "Vuoi rivedere i dettagli?"
