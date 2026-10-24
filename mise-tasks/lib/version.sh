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

# ASCII transliteration: decompose (NFD) and drop the accents, map letters that
# don't decompose (ß, æ, ø, ł, ...) and drop the Catalan middle dot (l·l).
# Uses the mise-pinned Python, so the Unicode data is the same everywhere.
transliterate() {
  python -c '
import sys, unicodedata
text = sys.stdin.buffer.read().decode("utf-8", "replace")
for letter, ascii in {
    "\u00b7": "", "\u00df": "ss", "\u1e9e": "SS",
    "\u00c6": "AE", "\u00e6": "ae", "\u0152": "OE", "\u0153": "oe",
    "\u00d8": "O", "\u00f8": "o", "\u0141": "L", "\u0142": "l",
    "\u00d0": "D", "\u0110": "D", "\u00f0": "d", "\u0111": "d",
    "\u00de": "TH", "\u00fe": "th", "\u0131": "i",
}.items():
    text = text.replace(letter, ascii)
text = "".join(c for c in unicodedata.normalize("NFD", text) if unicodedata.category(c) != "Mn")
sys.stdout.buffer.write(text.encode("utf-8"))
'
}

# Branch name made safe for image tags and git refs: transliterate to ASCII,
# lowercase, and turn every byte outside the allowlist a-z, 0-9, "." and "-"
# into "-". Collapse runs of "-" or ".", strip leading and trailing ones, avoid
# ".lock" endings, and keep at most 40 characters. A name with nothing left
# (e.g. Japanese) becomes "branch-<cksum of the name>".
pr_slug() {
  local ascii slug
  ascii=$(printf '%s' "${1}" | transliterate) || {
    echo "Could not transliterate branch name '${1}'" >&2
    return 1
  }
  slug=$(printf '%s' "${ascii}" \
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
