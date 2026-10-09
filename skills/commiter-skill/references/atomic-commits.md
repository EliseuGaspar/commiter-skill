# Atomic Commits: Splitting and Staging

## Contents
1. [What "atomic" means](#what-atomic-means)
2. [How to group changes](#how-to-group-changes)
3. [Ordering commits](#ordering-commits)
4. [Staging techniques](#staging-techniques)
5. [Splitting one file across commits (non-interactive)](#splitting-one-file-across-commits-non-interactive)
6. [Worked example](#worked-example)
7. [When NOT to split](#when-not-to-split)

---

## What "atomic" means

An atomic commit:
- Contains **one logical change** (one purpose you can state in a single short sentence without "and").
- Leaves the project in a **working state** (builds, tests pass).
- Can be **reverted or cherry-picked alone** without side effects.

**The "and" test**: if the honest subject needs "and" (`add login and fix navbar`), it's two commits.

---

## How to group changes

Read the full diff, then cluster hunks by *intent*:

| Signal | Action |
|--------|--------|
| Different `type`s (feat + fix + docs) | Separate commits |
| Different modules/features/bugs | Separate commits |
| Formatting/whitespace/import-sorting mixed with logic | Formatting first (`style`), logic after, so the logic diff stays readable |
| File rename/move + edits | Rename-only commit first (git detects renames better), then edits |
| Lockfile changed | Commit with its manifest (`package.json` + `package-lock.json`) as `build(deps)` |
| Generated files (OpenAPI clients, snapshots, migrations output) | With the source change that produced them |
| Tests for new/changed code | **Same commit** as the code |
| Test-only fix/addition for existing code | `test` commit alone |
| Docs describing a feature | Same commit as the feature if small; separate `docs` commit if substantial |
| Config/tooling change (eslint, tsconfig, CI) | Own `chore`/`ci`/`build` commit |
| Unrelated drive-by cleanup | Own commit (or leave out and tell the user) |

Heuristic for size: a reviewer should be able to understand a commit in a couple of minutes. If a commit touches 15 files across 4 areas, it's probably too big. But also don't over-split: a commit that doesn't make sense without the next one is **too small**.

---

## Ordering commits

Order so that **every commit builds on its own**:

1. Dependency bumps / build config needed by later work
2. Pure refactors that prepare the ground (no behavior change)
3. The feature or fix itself (with tests)
4. Follow-ups: docs, style cleanup, unrelated chores

Never commit code that references something introduced in a *later* commit.

---

## Staging techniques

Inspect first:

```bash
git status --short
git diff --stat
git diff <path>            # unstaged changes for a file
git diff --staged --stat   # what's currently staged
```

Stage whole files:

```bash
git add src/auth/token.ts src/auth/token.test.ts
```

Stage by directory (only after verifying its contents):

```bash
git add src/billing/
```

Unstage something you staged by mistake:

```bash
git restore --staged <path>        # keep working-tree changes
```

Commit only specific paths, ignoring everything else staged:

```bash
git commit -m "..." -- path/a path/b
```

Untracked files must be added explicitly (`git add path`); `git commit -a` does **not** include them, and `-a` also sweeps in all tracked changes. Avoid `-a` for multi-commit workflows.

Tip: for deleted/renamed files, `git add -A <path>` (scoped to a path) records the deletion; plain `git add <path>` on a deleted path also works in modern git.

---

## Splitting one file across commits (non-interactive)

`git add -p` is interactive and may not work in an agent shell. Use one of these instead.

### Option A: build a patch with just the hunks you want

```bash
# 1. Generate the full patch for the file with zero context so hunks split finely
git diff -U0 path/to/file > /tmp/full.patch

# 2. Edit /tmp/full.patch to keep only the hunks (and the file header) for commit #1
#    (delete the hunks that belong to later commits)

# 3. Apply that patch to the index only
git apply --cached --unidiff-zero /tmp/full.patch

# 4. Verify, then commit
git diff --staged
git commit -m "..."
```

The remaining hunks stay unstaged in the working tree for the next commit.

### Option B: feed answers to `git add -p`

If the shell supports stdin, you can script answers (`y` stage, `n` skip, `s` split, `q` quit):

```bash
printf 'y\nn\ny\n' | git add -p path/to/file
```

Check `git diff --staged` right after: scripted answers are easy to get out of sync with the hunk order.

### Option C: temporarily revert, commit, restore

For simple cases (two independent edits in a file):
1. Save the full version: `cp file /tmp/file.full`
2. Manually edit `file` to contain only commit #1's changes; `git add file`; commit.
3. Restore: `cp /tmp/file.full file`; now only commit #2's changes remain as a diff.

Always run `git diff --staged` to confirm the index contains exactly what you intend before committing.

---

## Worked example

Working tree contains:

```
M  package.json
M  package-lock.json
M  src/api/users.ts          (new pagination param + unrelated typo fix)
M  src/api/users.test.ts
M  README.md                 (documents the pagination param)
?? .env.local                (secret!)
```

Plan:

1. `build(deps): bump zod to 3.23.8`: `package.json`, `package-lock.json`
2. `fix(api): correct typo in users error message`: only the typo hunk from `users.ts` (split with Option A)
3. `feat(api): add cursor pagination to users endpoint`: remaining `users.ts` hunks + `users.test.ts`
4. `docs(api): document users pagination params`: `README.md`

Left out and flagged to the user: `.env.local` (likely secrets, suggest adding to `.gitignore`).

---

## When NOT to split

- The user explicitly asked for a single commit.
- The change is tiny and cohesive (a 3-line fix plus its test).
- Splitting would produce a commit that doesn't compile or doesn't make sense alone (e.g., a rename of a function and its only 2 call sites).
- A large mechanical change (codemod, bulk rename) is one logical operation: keep it one commit, and describe the command in the body.
