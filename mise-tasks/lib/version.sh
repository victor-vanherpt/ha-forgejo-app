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

# Branch name made safe for image tags and refs: lowercase [a-z0-9.-], max 40
pr_slug() {
  tr '[:upper:]' '[:lower:]' <<< "${1}" \
    | sed -E 's/[^a-z0-9.]+/-/g; s/^-+//' \
    | cut -c 1-40 \
    | sed -E 's/-+$//'
}
