#!/usr/bin/env bash
set -euo pipefail

if [ -z "${SKILL_NAME:-}" ]; then
  printf 'Usage: SKILL_NAME=<skill_name> %s\n' "${0##*/}" >&2
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git clone --filter=blob:none --sparse \
  https://github.com/hymaia/hymaclaudeskills.git "$tmp/repo"
cd "$tmp/repo"
git sparse-checkout set "$SKILL_NAME"
mkdir -p ~/.claude/skills
mv "$SKILL_NAME" ~/.claude/skills/
printf 'Claude skill installed: ~/.claude/skills/%s\n' "$SKILL_NAME"
