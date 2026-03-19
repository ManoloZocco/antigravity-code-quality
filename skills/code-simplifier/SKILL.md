---
name: code-simplifier
description: Simplifies and refines code for clarity, consistency, and maintainability while preserving all functionality. Focuses on recently modified code (staged or committed).
user-invocable: true
---

# Code Simplifier Skill

**Version:** 1.0  
**Adapted from:** [Claude Code code-simplifier plugin](https://github.com/anthropics/claude-plugins-official/tree/main/plugins/code-simplifier)

> Simplify and refine code for clarity, consistency, and maintainability — without changing what it does.

---

## When to Use

- **Automatically** via the `/pre-push` workflow (runs before code-review)
- **Manually** when you want to clean up code you just wrote or modified
- After a large refactoring session
- Before submitting code for review

---

## How It Works

### Step 1: Identify Modified Files

Run the appropriate git command to find changed files:

```bash
# Files modified in commits not yet pushed
git diff --name-only @{push}..HEAD 2>/dev/null || git diff --name-only origin/$(git branch --show-current)..HEAD

# Fallback: files modified in the last commit
git diff --name-only HEAD~1..HEAD
```

Only process source code files (skip binaries, images, lockfiles, generated files).

### Step 2: Analyze Each File

For each modified file, read the full content and identify opportunities to:

1. **Reduce unnecessary complexity and nesting** — flatten deeply nested if/else, simplify conditional logic
2. **Eliminate redundant code** — dead code, unused variables, duplicated logic
3. **Improve naming** — unclear variable/function names → descriptive ones
4. **Consolidate related logic** — scattered code that belongs together
5. **Remove noise** — comments that describe what the code obviously does, commented-out code
6. **Fix style inconsistencies** — mixed formatting, inconsistent patterns within the same file

### Step 3: Apply Refinements

Make the actual code edits. For each change:

- **NEVER change functionality** — the code must do exactly the same thing before and after
- **Prefer clarity over brevity** — explicit code beats clever one-liners
- **Avoid nested ternaries** — use if/else or switch instead
- **Don't over-consolidate** — keep logical separations that aid understanding
- **Respect project conventions** — if the project has a style guide or linter config, follow it

### Step 4: Report Changes

After all edits, provide a brief summary:

```
## Code Simplifier Report

### Files processed: N

#### `path/to/file.ext`
- Simplified nested conditional in `functionName` (lines X-Y)
- Renamed `x` → `descriptiveVariableName`
- Removed 3 redundant comments

#### `path/to/other.ext`
- No changes needed ✓
```

---

## Rules

1. **Preserve functionality at all costs** — if you're not 100% sure a change is safe, don't make it
2. **Only touch recently modified code** — unless the user explicitly asks for a broader scope
3. **Don't introduce new dependencies or patterns** — work within the existing codebase style
4. **Don't refactor architecture** — this is cosmetic simplification, not restructuring
5. **Keep changes minimal and reviewable** — the user should be able to quickly verify each change
6. **Language-agnostic** — these rules apply to any programming language (Rust, TypeScript, Python, Svelte, etc.)

---

## Project-Specific Standards

If the project has any of these files, read them first and follow their conventions:

- `CLAUDE.md` or `CONVENTIONS.md` or `CONTRIBUTING.md`
- `.editorconfig`
- Linter configs (`.eslintrc`, `rustfmt.toml`, `.prettierrc`, `pyproject.toml`, etc.)

If the project has an Antigravity skill for code style, defer to it.

---

## Example Simplifications

### Flatten unnecessary nesting
```diff
-if (condition) {
-  if (otherCondition) {
-    doSomething();
-  }
-}
+if (condition && otherCondition) {
+  doSomething();
+}
```

### Remove redundant code
```diff
-let result = getValue();
-return result;
+return getValue();
```

### Improve naming
```diff
-const d = new Date();
-const t = d.getTime();
+const now = new Date();
+const timestamp = now.getTime();
```

### Remove noise comments
```diff
-// increment counter
-counter++;
+counter++;
```

### Simplify conditional returns
```diff
-if (isValid) {
-  return true;
-} else {
-  return false;
-}
+return isValid;
```
