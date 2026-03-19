---
name: code-review
description: Multi-perspective code review with confidence scoring to find real bugs and issues in modified code. Filters false positives aggressively.
user-invocable: true
---

# Code Review Skill

**Version:** 1.0  
**Adapted from:** [Claude Code code-review plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-review)

> Thorough code review from multiple perspectives, with confidence scoring to surface only real, actionable issues.

---

## When to Use

- **Automatically** via the `/pre-push` workflow (runs after code-simplifier)
- **Manually** when you want a review before committing or pushing
- Before merging a feature branch
- After making significant changes to critical code

---

## How It Works

### Step 1: Gather the Diff

```bash
# Get the diff of commits not yet pushed
git diff @{push}..HEAD 2>/dev/null || git diff origin/$(git branch --show-current)..HEAD

# Get list of modified files
git diff --name-only @{push}..HEAD 2>/dev/null || git diff --name-only origin/$(git branch --show-current)..HEAD
```

If there are no unpushed changes, inform the user and stop.

### Step 2: Gather Context

1. **Project rules**: Read `CLAUDE.md`, `CONVENTIONS.md`, `CONTRIBUTING.md`, or similar if they exist in the repo root or in the directories containing modified files
2. **Change summary**: Create a brief summary of what the changes do overall

### Step 3: Multi-Perspective Review

Analyze the changes from **all** of these perspectives sequentially. For each, produce a list of issues found:

#### Perspective A: Project Rules Compliance
- Check if the changes comply with project conventions/rules files
- Only flag issues that the rules **explicitly** mention
- Skip rules that are not applicable to the type of changes made

#### Perspective B: Bug Detection
- Scan for **obvious bugs** in the changed code only
- Focus on large, impactful bugs — not nitpicks
- Look for: null/undefined access, off-by-one errors, race conditions, resource leaks, logic errors, missing error handling
- Ignore issues that a linter/typechecker/compiler would catch

#### Perspective C: Historical Context
- Run `git blame` and `git log` on modified sections
- Identify patterns: was similar code changed recently? Were there related bug fixes?
- Flag issues where the current change contradicts the intent of previous changes

#### Perspective D: Code Comment Compliance
- Read comments in the modified files (TODO, FIXME, NOTE, SAFETY, INVARIANT, etc.)
- Check that the changes don't violate assumptions documented in comments
- Flag if a TODO was supposed to be addressed but wasn't

### Step 4: Confidence Scoring

For **each issue** found, assign a confidence score 0-100:

| Score | Meaning |
|-------|---------|
| **0** | False positive. Doesn't stand up to scrutiny, or is a pre-existing issue. |
| **25** | Might be real, but could be a false positive. Can't verify it's real. If stylistic, not explicitly in project rules. |
| **50** | Verified real, but likely a nitpick or rare in practice. Not very important relative to the rest of the changes. |
| **75** | Very likely real and will be hit in practice. The existing approach is insufficient. Important or directly mentioned in project rules. |
| **100** | Definitely real, will happen frequently. Evidence directly confirms it. |

### Step 5: Filter and Report

**Filter out all issues with score < 80** (configurable threshold).

If no issues pass the threshold:

```
## Code Review Report

No issues found. Checked for bugs, project rules compliance, and historical context.

✅ Safe to push.
```

If issues are found, report them:

```
## Code Review Report

Found N issues:

### 1. [Brief description] (confidence: XX/100)
**Type:** bug | rules-violation | historical-context | comment-violation
**File:** `path/to/file.ext` (lines X-Y)
**Details:** Explanation of the issue with evidence.

### 2. ...

---
⚠️ Review these issues before pushing.
```

---

## What IS a False Positive (DO NOT flag these)

- **Pre-existing issues** not introduced by the current changes
- **Code that looks like a bug but isn't** — verify before flagging
- **Pedantic nitpicks** a senior engineer wouldn't call out
- **Issues linters/typecheckers/compilers catch** (imports, types, formatting, style)
- **General quality issues** (test coverage, documentation) unless in project rules
- **Issues silenced in code** (lint-ignore comments, `#[allow(...)]`, `// eslint-disable`)
- **Intentional functionality changes** related to the broader change
- **Issues on lines the user did NOT modify**

---

## What IS a Real Issue (DO flag these)

- Null pointer / undefined access in new code
- Logic errors that will produce wrong results
- Resource leaks (unclosed files, connections, channels)
- Race conditions in concurrent code
- Missing error handling that will crash
- Security issues (SQL injection, XSS, path traversal) in new code
- Violations of explicitly documented project rules
- Breaking changes to public APIs without migration

---

## Rules

1. **DO NOT build, typecheck, or run tests** — that's the CI's job
2. **Only review changed code** — don't audit the entire codebase
3. **Be conservative** — when in doubt, DON'T flag it
4. **Cite evidence** — every issue must reference specific code and lines
5. **Language-agnostic** — works for any language
6. **Threshold is configurable** — default 80, user can ask for stricter (90) or looser (60)

---

## Configuration

The user can adjust behavior by telling Antigravity:

- **Threshold**: "usa una soglia di confidenza di 60" → flag more issues
- **Focus**: "concentrati sulla sicurezza" → weight security perspective higher
- **Scope**: "rivedi anche i file non modificati in src/auth/" → expand scope
