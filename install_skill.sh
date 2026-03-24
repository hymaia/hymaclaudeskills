#!/usr/bin/env bash
# Clones into a temp dir ($tmp/repo), never into ./hymaclaudeskills in the current directory.
# Errors like "destination path 'hymaclaudeskills' already exists" or "pptx-hymaia/pptx-hymaia"
# mean you ran a different, outdated install_skill.sh — replace it with this file.
set -euo pipefail

if [ -z "${SKILL_NAME:-}" ]; then
  printf 'Usage: SKILL_NAME=<skill_name> %s\n' "${0##*/}" >&2
  exit 1
fi

dest="${HOME}/.claude/skills/${SKILL_NAME}"
if [ -e "$dest" ]; then
  if [ -n "${INSTALL_SKILL_REPLACE:-}" ]; then
    rm -rf "$dest"
  elif [ -t 0 ]; then
    printf 'Skill already exists: %s\n' "$dest"
    read -r -p 'Replace it with a fresh copy from the repo? [y/N] ' ans
    case "$(printf '%s' "$ans" | tr '[:upper:]' '[:lower:]')" in
      y|yes) rm -rf "$dest" ;;
      *)
        printf 'Aborted. Existing installation unchanged.\n'
        exit 0
        ;;
    esac
  else
    printf 'Skill already exists: %s\n' "$dest" >&2
    printf 'Run in a terminal to choose, or set INSTALL_SKILL_REPLACE=1 to replace without prompting.\n' >&2
    exit 1
  fi
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

git clone --filter=blob:none --sparse \
  https://github.com/hymaia/hymaclaudeskills.git "$tmp/repo"
cd "$tmp/repo"
git sparse-checkout set "$SKILL_NAME"
mkdir -p "${HOME}/.claude/skills"
mv "$SKILL_NAME" "${HOME}/.claude/skills/"
printf 'Claude skill installed: ~/.claude/skills/%s\n' "$SKILL_NAME"
