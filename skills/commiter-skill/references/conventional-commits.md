# Conventional Commits Reference

Spec: https://www.conventionalcommits.org/en/v1.0.0/

## Contents
1. [Message anatomy](#message-anatomy)
2. [Type table and how to choose](#types)
3. [Scopes](#scopes)
4. [Breaking changes](#breaking-changes)
5. [Subject line craft](#subject-line-craft)
6. [Body and footers](#body-and-footers)
7. [Good vs bad examples](#good-vs-bad-examples)
8. [SemVer mapping](#semver-mapping)

---

## Message anatomy

```
<type>[optional scope][!]: <description>

[optional body]

[optional footer(s)]
```

- Header, body, and footers are separated by **one blank line**.
- Footers use `Token: value` or `Token #value` format (`Closes #12`, `Reviewed-by: Ana`).
- `BREAKING CHANGE` must be uppercase.

---

## Types

| Type | Use when | Example |
|------|----------|---------|
| `feat` | A new user-facing capability or API | `feat(cart): add coupon code support` |
| `fix` | A bug fix (behavior was wrong, now correct) | `fix(parser): handle empty input without throwing` |
| `docs` | Documentation only (README, comments, docstrings, guides) | `docs: document env vars in README` |
| `style` | Formatting only; no logic change (whitespace, semicolons, import order, linter autofix) | `style: apply prettier to src/` |
| `refactor` | Code restructure with **no** behavior change and not a fix or feature | `refactor(db): extract query builder` |
| `perf` | Change whose main purpose is performance | `perf(search): cache tokenized queries` |
| `test` | Adding or fixing tests only | `test(auth): cover token expiry edge cases` |
| `build` | Build system, packaging, dependencies | `build(deps): bump axios to 1.7.2` |
| `ci` | CI/CD config and scripts | `ci: run lint in parallel with tests` |
| `chore` | Maintenance that doesn't touch src/test and fits nowhere else (tooling, gitignore, configs) | `chore: add .editorconfig` |
| `revert` | Reverting a previous commit | `revert: feat(cart): add coupon code support` |

### Choosing between look-alikes

- **`fix` vs `refactor`**: did observable behavior change for the better because something was broken? → `fix`. Same behavior, cleaner code → `refactor`.
- **`feat` vs `refactor`**: if a user or API consumer can now do something they couldn't before → `feat`.
- **`chore` vs `build`**: dependencies, bundler, Dockerfile, package manifests → `build`. Everything else housekeeping → `chore`.
- **`docs` vs `chore`**: anything whose purpose is explaining → `docs`.
- **`test` + code**: if you add a test **with** a fix/feature, the commit type is the `fix`/`feat`, not `test`.
- **`style`** is about *code formatting*, **not** UI/CSS styling. A visual change to the interface is `feat` or `fix`.
- **`perf` vs `refactor`**: if the goal was speed/memory → `perf`.
- When in doubt between two, pick the one describing the **primary intent**; if the change has two equally important intents, it should probably be two commits.

---

## Scopes

- Optional noun in parentheses describing the area: `feat(auth): ...`.
- **Follow the repo's existing scopes** (check `git log --oneline -n 30`). Don't invent a new scope if one already exists for that area.
- Good scopes: module, package, app, layer, or domain (`api`, `web`, `auth`, `db`, `cli`, `deps`, `ui`, `billing`).
- Keep them short, lowercase, no spaces. Use `-` for multiple words (`user-profile`).
- Omit the scope when the change is truly global or the repo doesn't use scopes.
- Don't use file names, ticket numbers, or author names as scopes.
- Multiple scopes in one commit usually signals the commit should be split. Cross-cutting changes may omit the scope or use `*`/a broad one like `core`.

---

## Breaking changes

A change that requires consumers to modify their code, config, or data.

Two ways (use either or both):

```
feat(api)!: remove v1 /users endpoint
```

```
feat(api): switch pagination to cursor-based

Offset pagination caused duplicated rows under concurrent writes.

BREAKING CHANGE: `page` and `per_page` query params were removed.
Use `cursor` and `limit` instead. See docs/migrations/pagination.md.
```

Guidelines:
- State **what** broke and **how to migrate**.
- Typical triggers: removed/renamed public API, changed function signatures, changed default behavior, dropped runtime/version support, DB schema changes needing migration, renamed config keys or env vars.
- A breaking change can be of **any** type (`fix!`, `refactor!`, `build!` ...).

---

## Subject line craft

- **Imperative, present tense**: complete the sentence *"If applied, this commit will ___"*.
  - ✅ `add retry logic to webhook sender`
  - ❌ `added retry logic`, `adds retry logic`, `adding retry logic`
- **Lowercase** first letter after the colon (except proper nouns/acronyms: `fix: handle UTF-8 BOM`).
- **No period** at the end.
- **≤ 50 chars** target, **72 max** (count the `type(scope): ` prefix too).
- **Specific over vague**: name the thing and the effect.
- No emoji or gitmoji (not part of this convention).
- No ticket ID in the subject; put it in the footer.
- Don't describe the process ("fix review comments", "address feedback", "wip", "misc changes").

### Vague → specific

| ❌ Vague | ✅ Specific |
|---------|------------|
| `fix: bug` | `fix(checkout): prevent double charge on retry` |
| `feat: update login` | `feat(auth): add Google OAuth login` |
| `chore: changes` | `chore: ignore .idea and dist folders` |
| `refactor: cleanup` | `refactor(utils): replace lodash.get with optional chaining` |
| `fix: tests` | `test(cart): stabilize flaky total calculation test` |

---

## Body and footers

### When a body is needed
Add one when any of these is true:
- The *why* isn't obvious from the subject.
- There was a non-trivial design decision or trade-off.
- The previous behavior or a bug's root cause is worth recording.
- The change has side effects, migrations, or follow-ups.

A trivial change (typo, dependency bump, simple rename) can be subject-only.

### How to write it
- Wrap at **72 columns**.
- Answer: *What was the problem? Why this approach? What else was considered? Any side effects?*
- Don't paste the diff or list every file changed.
- Use `-` bullets for several parallel points.

### Common footers

| Footer | Meaning |
|--------|---------|
| `Closes #123` / `Fixes #123` / `Resolves #123` | Auto-closes the issue on merge |
| `Refs #123` | Related, but doesn't close |
| `BREAKING CHANGE: ...` | Major version bump trigger |
| `Co-authored-by: Name <email>` | Credit a **real human** pair/mob collaborator the user named. **Never** an AI/assistant/bot |
| `Reverts: <hash>` | In `revert` commits |

Never fabricate issue numbers, hashes, or co-authors. Never add AI attribution of any kind (no `Co-authored-by` for Claude/assistants, no "Generated with ..." lines).

---

## Good vs bad examples

### Simple fix
```
fix(auth): reject expired refresh tokens
```

### Fix with context
```
fix(auth): reject expired refresh tokens

The expiry check used <= instead of <, so tokens were accepted for
one extra second. In practice clock skew made this window up to
several seconds, letting revoked sessions linger.

Add a regression test with a mocked clock.

Closes #218
```

### Feature
```
feat(search): add fuzzy matching for product names

Exact-match search returned nothing for common typos, which was the
top source of "no results" sessions. Use trigram similarity with a
0.3 threshold; benchmarks show <5ms overhead on 100k products.
```

### Refactor
```
refactor(billing): split invoice service into calculator and renderer

No behavior change. The 900-line service mixed tax math and PDF
output, which made both hard to test in isolation.
```

### Dependency bump
```
build(deps): bump express from 4.18.2 to 4.19.2
```

### Breaking
```
feat(config)!: rename DB_URL env var to DATABASE_URL

BREAKING CHANGE: DB_URL is no longer read. Rename it to DATABASE_URL
in your .env and deployment configs.
```

### Revert
```
revert: feat(search): add fuzzy matching for product names

This reverts commit 3f2a9c1.

Fuzzy matching caused p99 latency to exceed the SLO on the catalog
service. Will reintroduce behind a feature flag.
```

### Bad examples (and why)

| ❌ Message | Problem |
|-----------|---------|
| `Fixed stuff` | No type, vague, past tense |
| `feat: Added new button.` | Past tense, capitalized, trailing period |
| `update` | No type, no information |
| `fix: fix bug in the thing where it crashes sometimes when users click` | Too long, vague, rambling |
| `feat: add login, fix navbar, update deps` | Three changes in one commit |
| `wip` | Not a meaningful history entry |
| `fix: address PR comments` | Describes process, not change |
| `🎨 improve structure` | Gitmoji, no type, vague |
| `feat: implementar login` | Not in English |

---

## SemVer mapping

| Commit | Release bump |
|--------|--------------|
| `fix` | PATCH |
| `feat` | MINOR |
| any type with `!` or `BREAKING CHANGE:` | MAJOR |
| `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore` | none (by default) |

This is why choosing `feat` vs `fix` vs `refactor` correctly matters: tooling (semantic-release, release-please, changelogs) reads these types.
