#!/bin/bash
# AuraConfig - Module System

# Get module metadata from module.json
get_module_meta() {
    local key="$1"
    local default="${2:-}"
    
    if [[ -z "${AURA_MODULE_JSON:-}" || ! -f "$AURA_MODULE_JSON" ]]; then
        echo "$default"
        return
    fi
    
    local value=$(jq -r ".${key} // empty" "$AURA_MODULE_JSON" 2>/dev/null)
    echo "${value:-$default}"

}

# Get module setting from config section
get_module_setting() {
    local key="$1"
    local default="${2:-}"
    get_module_meta "config.${key}" "$default"
}

# Load and execute module
load_module() {
    local mod_name="$1"
    local user_mod_dir="$AURA_SHARE_DIR/modules/${mod_name}"
    local system_mod_dir="/usr/local/share/auraconfig/modules/${mod_name}"
    local mod_dir=""
    
    # Validate module name
    if [[ ! "$mod_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        log "error" "$(translate "error_invalid_module")"
        exit 1
    fi

    # Find module
    if [[ -d "$user_mod_dir" ]]; then
        mod_dir="$user_mod_dir"
    elif [[ -d "$system_mod_dir" ]]; then
        mod_dir="$system_mod_dir"
    else
        log "error" "$(translate "error_module_not_found" "$mod_name")"
        exit 1
    fi

    # Check required files
    local mod_json="$mod_dir/module.json"
    local mod_script="$mod_dir/${mod_name}.sh"
    
    if [[ ! -f "$mod_json" ]]; then
        log "error" "$(translate "error_module_json_missing"): $mod_name"
        exit 1
    fi
    
    if [[ ! -f "$mod_script" ]]; then
        log "error" "$(translate "error_module_script_missing"): $mod_name"
        exit 1
    fi
    
    # Export module paths
    export AURA_MODULE_DIR="$mod_dir"
    export AURA_MODULE_JSON="$mod_json"
    
    # Load module translations if they exist
    local mod_lang_file="$mod_dir/lang/${AURA_LANG}.lex"
    if [[ -f "$mod_lang_file" ]]; then
        lexis_load "$mod_lang_file"
    fi

    # Load module script
    source "$mod_script"
}

# List all available modules
list_modules() {
    local modules_dir="$AURA_SHARE_DIR/modules"
    local found_modules=false
    local listed_modules=()
    echo "$(translate "modules_available"):"
    echo ""

    # Check user modules
    if [[ -d "$modules_dir" ]]; then
        for mod_dir in "$modules_dir"/*/; do
            [[ ! -d "$mod_dir" ]] && continue
            found_modules=true
            local mod_name=$(basename "$mod_dir")
            listed_modules+=("$mod_name")
            list_module_entry "$mod_dir"
        done
    fi
    
    system_mod_dir="/usr/local/share/auraconfig/modules"
    # Check system modules
    if [[ -d "$system_mod_dir" ]]; then
        for mod_dir in "$system_mod_dir"/*/; do
            [[ ! -d "$mod_dir" ]] && continue
            local mod_name=$(basename "$mod_dir")
            # Skip if already listed from user modules
            if [[ " ${listed_modules[*]} " =~ " ${mod_name} " ]]; then
                continue
            fi
            found_modules=true
            list_module_entry "$mod_dir"
        done
    fi
    if [[ "$found_modules" == "false" ]]; then
        echo "  $(translate "modules_none")"
    fi
}

# Helper function to list a single module
list_module_entry() {
    local mod_dir="$1"
    local mod_name=$(basename "$mod_dir")
    local mod_json="$mod_dir/module.json"
    
    if [[ -f "$mod_json" ]]; then
        local icon=$(jq -r '.icon // "📦"' "$mod_json" 2>/dev/null)
        local desc=$(jq -r ".description_${AURA_LANG} // .description // \"\"" "$mod_json" 2>/dev/null)
        
        printf "  %s %-15s - %s\n" "$icon" "$mod_name" "$desc"
    else
        echo "  📦 $mod_name"
    fi
}

# Show detailed module information
show_module_info() {
    local mod_name="$1"
    
    # Find module
    local mod_dir=""
    local user_mod_dir="$AURA_SHARE_DIR/modules/${mod_name}"
    local system_mod_dir="/usr/local/share/auraconfig/modules/${mod_name}"
    
    if [[ -d "$user_mod_dir" ]]; then
        mod_dir="$user_mod_dir"
    elif [[ -d "$system_mod_dir" ]]; then
        mod_dir="$system_mod_dir"
    else
        log "error" "$(translate "error_module_not_found" "$mod_name")"
        exit 1
    fi
    local mod_json="$mod_dir/module.json"
    if [[ ! -f "$mod_json" ]]; then
        log "error" "$(translate "error_module_json_missing"): $mod_name"
        exit 1
    fi
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $(translate "module_info_header"): $mod_name"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    printf "%-13s %s\n" "$(translate "module_info_name"):" "$(jq -r '.name // "N/A"' "$mod_json")"
    printf "%-13s %s\n" "$(translate "module_info_version"):" "$(jq -r '.version // "N/A"' "$mod_json")"
    printf "%-13s %s\n" "$(translate "module_info_author"):" "$(jq -r '.author // "N/A"' "$mod_json")"
    printf "%-13s %s\n" "$(translate "module_info_category"):" "$(jq -r '.category // "N/A"' "$mod_json")"
    printf "%-13s %s\n" "$(translate "module_info_icon"):" "$(jq -r '.icon // "N/A"' "$mod_json")"
    echo ""
    printf "%-13s %s\n" "$(translate "module_info_description"):" "$(jq -r ".description_${AURA_LANG} // .description // \"N/A\"" "$mod_json")"
    echo ""
    printf "%-13s %s\n" "$(translate "module_info_path"):" "$mod_dir"
    echo ""
    
    # Show config if exists
    local config=$(jq -r '.config // empty' "$mod_json" 2>/dev/null)
    if [[ -n "$config" && "$config" != "{}" && "$config" != "null" ]]; then
        echo "$(translate "module_info_configuration"):"
        echo "$config" | jq '.' 2>/dev/null || echo "$config"
    fi

    # Show available translations
    if [[ -d "$mod_dir/lang" ]]; then
        local langs=$(ls "$mod_dir/lang"/*.lex 2>/dev/null | xargs -n1 basename 2>/dev/null | sed 's/\.lex$//' | tr '\n' ', ' | sed 's/,$//')
        if [[ -n "$langs" ]]; then
            printf "%-13s %s\n" "$(translate "module_info_languages"):" "$langs"
            echo ""
        fi
    fi
}

# Module Management Commands
manage_modules() {
    local action="${1:-list}"
    local target="${2:-}"
    
    case "$action" in
        "list"|"-l"|"--list")
            list_modules
            ;;
        "info"|"-i"|"--info")
            if [[ -z "$target" ]]; then
                log "error" "$(translate "error_no_module")"
                exit 1
            fi
            show_module_info "$target"
            ;;
        *)
            log "error" "$(translate "error_unknown_action"): $action"
            echo ""
            echo "Available actions:"
            echo "  list              List all modules"
            echo "  info <module>     Show module information"
            exit 1
            ;;
    esac
}
