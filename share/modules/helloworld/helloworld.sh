#!/bin/bash
# Module: helloworld - Simple example module

module_helloworld() {
    local mode="$1"
    
    # Get module config
    local icon=$(get_module_meta "icon" "👋")
    local greeting=$(get_module_setting "greeting" "Hello")
    
    # Get translations
    local world=$(translate "helloworld_world")
    
    # Build display text
    local text="${greeting}, ${world}!"
    local tooltip=$(translate "helloworld_tooltip")
    
    # Build JSON data
    local data=$(cat <<EOF
{
  "icon": "$icon",
  "text": "$text",
  "tooltip": "$tooltip",
  "class": "success"
}
EOF
)
    
    # Render
    render "$mode" "$data"
}

# Action: greet with custom name
helloworld_greet() {
    local name="${1:-World}"
    local greeting=$(get_module_setting "greeting" "Hello")
    
    log "success" "${greeting}, ${name}!"
}
