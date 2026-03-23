#!/bin/bash
# =============================================================================
# Lexis - Minimalist i18n runtime for Bash
# Format: key::value
# https://github.com/edgarmasague/lexis
# =============================================================================

# Global associative array for translations
declare -gA LEXIS_TRANSLATIONS

# Load .lex file into associative array
lexis_load() {
    local lex_file="$1"
    if [[ ! -f "$lex_file" ]]; then
        return 1
    fi
    while IFS= read -r line; do
    
        # Skip empty lines and comments
        [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
        
        # Check if line contains ::
        [[ ! "$line" =~ :: ]] && continue

        # Split on first :: only
        local key="${line%%::*}"
        local value="${line#*::}"
        
        # Trim whitespace
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)
        
        # Store in associative array
        LEXIS_TRANSLATIONS["$key"]="$value"
    done < "$lex_file"
    return 0
}

# Get translation with optional printf-style formatting
lexis_get() {
    local key="${1:-}"
    shift
    
    # Check if key exists
    [[ -z "${LEXIS_TRANSLATIONS[$key]:-}" ]] && echo "$key" && return 1
    
    local text="${LEXIS_TRANSLATIONS[$key]}"
    
    # Apply printf formatting if arguments provided
    if [[ $# -gt 0 ]]; then
        printf "$text" "$@" 2>/dev/null || echo "$text"
    else
        echo "$text"
    fi
}

# Check if translation exists
lexis_has() {
    [[ -n "${LEXIS_TRANSLATIONS[$1]:-}" ]]
}

# Count loaded translations
lexis_count() {
    echo "${#LEXIS_TRANSLATIONS[@]}"
}

# Clear all translations
lexis_clear() {
    LEXIS_TRANSLATIONS=()
}
