#!/usr/bin/env bash
# shellcheck shell=bash
# Shared helpers for the version tasks. The app version is
# <forgejo version>-<commit count of main>, e.g. 17.0.0-42.

readonly DOCKERFILE=forgejo/Dockerfile
readonly CONFIG=forgejo/config.yaml
readonly CHANGELOG=forgejo/CHANGELOG.md

# Forgejo version pinned in the Dockerfile
forgejo_version() {
  sed -n 's/^ARG FORGEJO_VERSION=//p' "${DOCKERFILE}"
}

# App version in config.yaml
app_version() {
  yq '.version' "${CONFIG}"
}

# Number of commits reachable from a ref
commit_count() {
  git rev-list --count "${1}"
}

# Notes under "## <version>" in the changelog (empty when missing)
changelog_section() {
  awk -v heading="## ${1}" '
    $0 == heading { found = 1; next }
    found && /^## / { exit }
    found { print }
  ' "${CHANGELOG}" | sed '/^[[:space:]]*$/d'
}

# Branch name made safe for image tags and git refs. Allowlist: only a-z, 0-9,
# "." and "-" are kept; uppercase ASCII is lowercased and every other byte
# (including non-ASCII) becomes "-". Runs of "-" or "." are collapsed, leading
# and trailing "." / "-" are stripped, ".lock" endings are avoided, and the
# result is at most 40 characters. A name with nothing left (e.g. all
# non-ASCII) becomes "branch-<cksum of the name>".
pr_slug() {
  local slug
  slug=$(printf '%s' "${1}" \
    | LC_ALL=C tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' 'abcdefghijklmnopqrstuvwxyz' \
    | LC_ALL=C tr -c 'abcdefghijklmnopqrstuvwxyz0123456789.-' '-' \
    | LC_ALL=C sed -E 's/-+/-/g; s/\.+/./g; s/^[.-]+//' \
    | LC_ALL=C cut -c 1-40 \
    | LC_ALL=C sed -E 's/[.-]+$//; s/\.lock$/-lock/')
  if [[ -z "${slug}" ]]; then
    slug="branch-$(printf '%s' "${1}" | cksum | cut -d ' ' -f 1)"
  fi
  printf '%s\n' "${slug}"
}
