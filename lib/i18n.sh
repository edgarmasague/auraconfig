#!/bin/bash
# AuraConfig - Internationalization System

readonly DEFAULT_LANG="en"
readonly AUTO_DETECT="auto"
readonly SUPPORTED_LANGS=("es" "en" "pt")

# Detect system language
detect_language() {
    local sys_lang="${LANG:-en_US.UTF-8}"
    local lang_code="${sys_lang:0:2}"
    if [[ " ${SUPPORTED_LANGS[*]} " =~ " ${lang_code} " ]]; then
        echo "$lang_code"
    else
        echo "$DEFAULT_LANG"
    fi
}

# Get language with priority
get_language() {
    # 1. Explicit environment variable
    if [[ -n "${AURA_LANG:-}" && "$AURA_LANG" != "$AUTO_DETECT" ]]; then
        echo "$AURA_LANG"
        return
    fi
    # 2. From .env
    local env_lang=$(get_env "lang" "$AUTO_DETECT" 2>/dev/null || echo "$AUTO_DETECT")
    if [[ "$env_lang" != "$AUTO_DETECT" ]]; then
        echo "$env_lang"
        return
    fi
    # 3. Auto-detect
    detect_language
}

# Initialize translations
i18n_init() {
    # Initialize language
    AURA_LANG="$(get_language)"
    # Load the appropriate .lex files
    local primary_lex="$AURA_SHARE_DIR/lang/${AURA_LANG}.lex"
    local fallback_lex="$AURA_SHARE_DIR/lang/${DEFAULT_LANG}.lex"
    local lex_file=""
    if ! lexis_load "$primary_lex"; then
        # Fallback to DEFAULT_LANG
        log "warn" "Language '$AURA_LANG' not found. Falling back to $DEFAULT_LANG."
        if ! lexis_load "$fallback_lex"; then
            echo "Error: No translation files found" >&2
            exit 1
        fi
        lex_file=$fallback_lex
        AURA_LANG="$DEFAULT_LANG"
    else
        lex_file=$primary_lex
    fi
    # Debug mode
    if [[ "${AURA_DEBUG:-false}" == "true" ]]; then
        echo "[i18n] Language: $AURA_LANG" >&2
        echo "[i18n] Loaded translations: $(lexis_count)" >&2
        echo "[i18n] File: $lex_file" >&2
    fi
    export AURA_LANG
}

# Wrapper function for lexis
translate() {
    lexis_get "$@"
}

# Check if translation exists
has_translation() {
    lexis_has "$1"
}

# Get translation with explicit fallback
get_translation() {
    local key="$1"
    local fallback="${2:-$key}"
    if has_translation "$key"; then
        translate "$key"
    else
        echo "$fallback"
    fi
}
