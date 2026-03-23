#!/bin/bash
# AuraConfig - Environment Configuration System

readonly ENV_FILE=".env"
readonly ENV_LOCATIONS=(
    "${XDG_CONFIG_HOME:-$HOME/.config}/auraconfig/.env"
    "$HOME/.auraconfig"
    "./.env"
)
_trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    printf '%s' "$var"
}
_unquote() {
    local var="$1"
    var="${var%\"}"
    var="${var#\"}"
    var="${var%\'}"
    var="${var#\'}"

    printf '%s' "$var"
}
_clean_value() {
    local key="$1"
    local value="$2"
    if [[ -z "$key" || "$key" =~ ^[[:space:]]*# ]]; then
        return 1
    fi
    key=$(_trim "$key")
    value=$(_trim "$value")
    value=$(_unquote "$value") 
    CLEAN_KEY="$key"
    CLEAN_VALUE="$value"
}
# Load .env file
load_env() {
    local env_file=""
    
    # Find .env file in order of priority
    for location in "${ENV_LOCATIONS[@]}"; do
        if [[ -f "$location" ]]; then
            env_file="$location"
            break
        fi
    done
    
    # If no .env found, return (use defaults)
    [[ -z "$env_file" ]] && return 0
    
    # Load .env file
    while IFS= read -r line; do
        key="${line%%=*}"
        value="${line#*=}"
        _clean_value "$key" "$value" || continue
        [[ "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]] || continue
        key="$CLEAN_KEY"
        value="$CLEAN_VALUE"
        # Export variable with AURA_ prefix
        export "AURA_${key^^}=$value"
    done < "$env_file"
    
    # Debug output
    if [[ "${AURA_DEBUG:-false}" == "true" ]]; then
        echo "[env] Loaded configuration from: $env_file" >&2
    fi
    return 0
}

# Get environment variable
get_env() {
    local key="$1"
    local default="${2:-}"
    local var_name="AURA_${key^^}"
    echo "${!var_name:-$default}"
}

# Set environment variable (runtime only, not persistent)
set_env() {
    local key="$1"
    local value="$2"
    local var_name="AURA_${key^^}"
    export "$var_name=$value"
}
