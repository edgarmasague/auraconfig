#!/bin/bash
# AuraConfig - Cache System

handle_cache() {
    local action="${1:-info}"
    local key="${2:-}"
    case "$action" in
        "info")
            if [[ -n "$key" ]]; then
                lethe_info "$key"
            else
                echo "Cache dir: $AURA_CACHE_DIR"
                echo ""
                for file in "$AURA_CACHE_DIR"/*.meta; do
                    [[ -f "$file" ]] || continue
                    local value; value=$(basename "$file" .meta)
                    lethe_info "$value"
                    echo ""
                done
            fi
            ;;
        "clear")
            if [[ -n "$key" ]]; then
                lethe_clear "$key"
                log "success" "Cache cleared: $key"
            else
                log "error" "Specify a key: aura cache clear <key>"
            fi
            ;;
        "clear-all")
            lethe_clear_all
            log "success" "All cache cleared"
            ;;
        *)
            echo "Usage: aura cache [info|clear|clear-all] [key]"
            ;;
    esac
}