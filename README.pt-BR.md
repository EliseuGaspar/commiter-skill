# commiter-skill

[English](README.md)

Uma [Agent Skill](https://docs.claude.com) que ensina agentes de IA a fazer **bons commits no git**: inspecionar as mudanças, dividir em commits atômicos, fazer o stage com precisão e escrever mensagens no padrão **Conventional Commits**, em inglês.

## O que ela faz

1. **Inspeciona** `git status`, diffs e o histórico recente para aprender os scopes do repo.
2. **Checa segurança** antes do stage: segredos, arquivos indesejados, marcadores de conflito, branches protegidas.
3. **Planeja commits atômicos**: uma mudança lógica por commit, em ordem que sempre compila.
4. **Faz stage preciso** por arquivo, ou por hunk quando um arquivo mistura assuntos.
5. **Escreve a mensagem** seguindo o [Conventional Commits 1.0.0](https://www.conventionalcommits.org/pt-br/v1.0.0/): assunto no imperativo, até 50 caracteres (máximo 72), corpo explicando o *porquê*, breaking changes sinalizados.
6. **Commita e verifica** o resultado.

### Regras embutidas

- Mensagens **sempre em inglês**.
- **Sem atribuição de IA**: nunca adiciona `Co-authored-by` de IA/assistente nem linhas "Generated with ...". O commit é seu.
- Nunca usa `--no-verify`, nunca faz force push, nunca faz push sem você pedir e nunca altera o `git config`.

## Instalação

### Opção 1: `npx skills`

```bash
npx skills add EliseuGaspar/commiter-skill
```

Use `-g` para instalar globalmente ou `-a claude-code` para escolher o agente. (`skills` é uma CLI da comunidade; confira o README dela para as flags atuais.)

### Opção 2: instalador via `curl`

```bash
# para todos os seus projetos (~/.claude/skills)
curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash

# só para o projeto atual (./.claude/skills)
curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash -s -- --project

# fixar uma versão
curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash -s -- --ref v1.0.0
```

### Opção 3: manual

```bash
git clone https://github.com/EliseuGaspar/commiter-skill.git
cp -R commiter-skill/skills/commiter-skill ~/.claude/skills/
```

Reinicie o agente após instalar.

## Uso

Peça em linguagem natural: "commita as mudanças", "faz o commit", "divide isso em commits atômicos", "qual deveria ser a mensagem de commit?".

## Licença

[MIT](LICENSE) © 2026 Eliseu Augusto Gaspar Gonçalves
