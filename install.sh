#!/usr/bin/env bash
# Installs commiter-skill into Claude Code's skills directory.
#
#   curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash -s -- --project
#   curl -fsSL https://raw.githubusercontent.com/EliseuGaspar/commiter-skill/main/install.sh | bash -s -- --ref v1.0.0
set -euo pipefail

OWNER="EliseuGaspar"
REPO="commiter-skill"
SKILL="commiter-skill"
REF="main"
SCOPE="global"

usage() {
  cat <<USAGE
Usage: install.sh [--project] [--ref <branch-or-tag>] [-h|--help]

  (default)       install for all projects:  ~/.claude/skills/$SKILL
  --project       install for current project: ./.claude/skills/$SKILL
  --ref <ref>     branch or tag to install (default: main)
USAGE
}

while [ $# -gt 0 ]; do
  case "$1" in
    --project) SCOPE="project" ;;
    --ref)
      [ $# -ge 2 ] || { echo "error: --ref needs a value" >&2; exit 1; }
      REF="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "error: unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

if [ "$SCOPE" = "project" ]; then
  DEST="$PWD/.claude/skills/$SKILL"
else
  DEST="$HOME/.claude/skills/$SKILL"
fi

for cmd in curl tar find; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "error: '$cmd' is required" >&2; exit 1; }
done

URL="${COMMITER_SKILL_ARCHIVE_URL:-https://github.com/$OWNER/$REPO/archive/$REF.tar.gz}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Downloading $OWNER/$REPO@$REF ..."
curl -fsSL "$URL" | tar -xz -C "$TMP"

SRC="$(find "$TMP" -mindepth 3 -maxdepth 3 -type d -path "*/skills/$SKILL" | head -n 1)"
[ -n "$SRC" ] || { echo "error: skill folder not found in archive" >&2; exit 1; }

mkdir -p "$(dirname "$DEST")"
rm -rf "$DEST"
cp -R "$SRC" "$DEST"

echo "Installed $SKILL to: $DEST"
echo "Restart Claude Code to load it."
