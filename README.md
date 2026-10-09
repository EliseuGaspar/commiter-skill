# commiter-skill

[Português (BR)](README.pt-BR.md)

An [Agent Skill](https://docs.claude.com) that teaches AI coding agents to make **good git commits**: inspect the changes, split them into atomic commits, stage precisely, and write **Conventional Commits** messages in English.

## What it does

1. **Inspects** `git status`, diffs, and recent history to learn the repo's scopes.
2. **Checks safety** before staging: secrets, junk files, conflict markers, protected branches.
3. **Plans atomic commits**: one logical change per commit, ordered so every commit builds.
4. **Stages precisely** by path, or by hunk when a file mixes concerns.
5. **Writes the message** following [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/): imperative subject, ≤ 50 chars (72 max), body explaining *why*, breaking changes marked.
6. **Commits and verifies** the result.

### Built-in rules

- Messages are **always in English**.
- **No AI attribution**: never adds `Co-authored-by` for an AI/assistant, nor "Generated with ..." lines. The commit belongs to you.
- Never uses `--no-verify`, never force-pushes, never pushes unless asked, never edits `git config`.

### Example output

```
fix(auth): reject expired refresh tokens

The expiry check used <= instead of <, so tokens were accepted for one
extra second. Clock skew widened that window in practice.

Add a regression test with a mocked clock.

Closes #218
```

## Install

### Option 1: `npx skills`

```bash
npx skills add EliseuGaspar/commiter-skill
```

Add `-g` to install globally, or `-a claude-code` to target a specific agent. (`skills` is a community CLI; check its README for current flags.)

### Option 2: `curl` installer

```bash
# for all your projects (~/.claude/skills)
curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash

# only for the current project (./.claude/skills)
curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash -s -- --project

# pin a version
curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash -s -- --ref v1.0.0
```

### Option 3: manual

```bash
git clone https://github.com/EliseuGaspar/commiter-skill.git
cp -R commiter-skill/skills/commiter-skill ~/.claude/skills/
```

Restart your agent after installing.

## Usage

Just ask in natural language:

- "commit my changes"
- "faz o commit"
- "split this into atomic commits"
- "what should the commit message be?"

## Repository layout

```
skills/commiter-skill/
  SKILL.md               main instructions
  references/
    conventional-commits.md
    atomic-commits.md
install.sh               curl installer
```

## Contributing

Issues and PRs are welcome. Please use Conventional Commits for your own commits. 😉

## License

[MIT](LICENSE) © 2026 Eliseu Augusto Gaspar Gonçalves
