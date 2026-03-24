#!/usr/bin/env bash
# Clones into a temp dir ($tmp/repo), never into ./hymaclaudeskills in the current directory.
# Errors like "destination path 'hymaclaudeskills' already exists" or "pptx-hymaia/pptx-hymaia"
# mean you ran a different, outdated install_skill.sh — replace it with this file.
#
# Resolves the skill path in the repo: tries skills/<SKILL_NAME> first, then <SKILL_NAME> at root.
# Override: export SKILL_ROOT_IN_REPO= (empty = repo root only) or SKILL_ROOT_IN_REPO=my/dir
set -euo pipefail

if [ -z "${SKILL_NAME:-}" ]; then
  printf 'Usage: SKILL_NAME=<skill_name> %s\n' "${0##*/}" >&2
  exit 1
fi

_is_tree_at_head() {
  local p="$1"
  [ "$(git cat-file -t "HEAD:${p}" 2>/dev/null || true)" = tree ]
}

# Sets global skill_rel; must run inside a git clone with HEAD available.
resolve_skill_rel() {
  if [ -n "${SKILL_ROOT_IN_REPO+x}" ]; then
    if [ -z "${SKILL_ROOT_IN_REPO}" ]; then
      skill_rel="${SKILL_NAME}"
    else
      skill_rel="${SKILL_ROOT_IN_REPO%/}/${SKILL_NAME}"
    fi
    if ! _is_tree_at_head "$skill_rel"; then
      printf 'error: not a directory in repo: %s\n' "$skill_rel" >&2
      exit 1
    fi
    return
  fi
  if _is_tree_at_head "skills/${SKILL_NAME}"; then
    skill_rel="skills/${SKILL_NAME}"
    return
  fi
  if _is_tree_at_head "${SKILL_NAME}"; then
    skill_rel="${SKILL_NAME}"
    return
  fi
  printf 'error: skill not found at skills/%s or %s (set SKILL_ROOT_IN_REPO to override)\n' \
    "$SKILL_NAME" "$SKILL_NAME" >&2
  exit 1
}

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
resolve_skill_rel
git sparse-checkout set "$skill_rel"
mkdir -p "${HOME}/.claude/skills"
mv "$skill_rel" "${HOME}/.claude/skills/"
printf 'Claude skill installed: ~/.claude/skills/%s\n' "$SKILL_NAME"
