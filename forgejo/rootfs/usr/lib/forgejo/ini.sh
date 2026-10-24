#!/usr/bin/env bash
# shellcheck shell=bash
# ==============================================================================
# Minimal app.ini helpers (Forgejo ships no in-place ini editor)
# ==============================================================================

# ------------------------------------------------------------------------------
# Set KEY = VALUE in [SECTION] of FILE, replacing an existing key or adding it.
# Use DEFAULT as section for keys that live before the first section header.
#
# Arguments:
#   $1 File
#   $2 Section
#   $3 Key
#   $4 Value
# ------------------------------------------------------------------------------
forgejo::ini.set() {
    local file=${1}
    local tmp

    tmp=$(mktemp)
    INI_SECTION=${2} INI_KEY=${3} INI_VALUE=${4} awk '
        function header(line) {
            if (match(line, /^[ \t]*\[[^]]+\][ \t]*$/)) {
                gsub(/^[ \t]*\[|\][ \t]*$/, "", line)
                return line
            }
            return ""
        }
        function emit() { print ENVIRON["INI_KEY"] " = " ENVIRON["INI_VALUE"]; done = 1 }
        BEGIN {
            target = ENVIRON["INI_SECTION"]
            current = "DEFAULT"
            seen = (target == "DEFAULT")
        }
        {
            name = header($0)
            if (name != "") {
                if (current == target && !done) emit()
                current = name
                if (current == target) seen = 1
                print
                next
            }
            if (current == target && !done && index($0, "=") > 0) {
                key = substr($0, 1, index($0, "=") - 1)
                gsub(/^[ \t]+|[ \t]+$/, "", key)
                if (key == ENVIRON["INI_KEY"]) { emit(); next }
            }
            print
        }
        END {
            if (done) exit
            if (!seen) print "\n[" target "]"
            emit()
        }
    ' "${file}" > "${tmp}"
    cat "${tmp}" > "${file}"
    rm -f "${tmp}"
}

# ------------------------------------------------------------------------------
# Get the value of KEY in [SECTION] of FILE (empty when missing).
#
# Arguments:
#   $1 File
#   $2 Section
#   $3 Key
# ------------------------------------------------------------------------------
forgejo::ini.get() {
    INI_SECTION=${2} INI_KEY=${3} awk '
        BEGIN { current = "DEFAULT" }
        /^[ \t]*\[[^]]+\][ \t]*$/ {
            current = $0
            gsub(/^[ \t]*\[|\][ \t]*$/, "", current)
            next
        }
        current == ENVIRON["INI_SECTION"] && index($0, "=") > 0 {
            key = substr($0, 1, index($0, "=") - 1)
            gsub(/^[ \t]+|[ \t]+$/, "", key)
            if (key == ENVIRON["INI_KEY"]) {
                value = substr($0, index($0, "=") + 1)
                gsub(/^[ \t]+|[ \t]+$/, "", value)
                print value
                exit
            }
        }
    ' "${1}"
}

# ------------------------------------------------------------------------------
# Apply a Forgejo environment override name (FORGEJO__section__KEY) to FILE.
# Section names decode _0X2E_ to "." and _0X2D_ to "-", like Forgejo's own
# environment-to-ini.
#
# Arguments:
#   $1 File
#   $2 Name (FORGEJO__section__KEY)
#   $3 Value
# ------------------------------------------------------------------------------
forgejo::ini.apply_env() {
    local rest=${2#FORGEJO__}
    local section=${rest%%__*}
    local key=${rest#*__}

    section=${section//_0X2E_/.}
    section=${section//_0X2D_/-}
    key=${key//_0X2E_/.}
    key=${key//_0X2D_/-}

    forgejo::ini.set "${1}" "${section}" "${key}" "${3}"
}
