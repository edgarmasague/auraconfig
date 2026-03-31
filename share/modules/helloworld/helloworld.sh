#!/bin/bash
# Module: helloworld - Simple example module

module_helloworld() {
    local mode="${1:-terminal}"
    
    # Get module config
    local icon=$(get_module_meta "icon" "👋")
    local greeting=$(get_module_setting "greeting" "Hello")
    
    # Get translations
    local world=$(translate "helloworld_world")
    local tooltip_line1=$(translate "helloworld_tooltip_line1")
    local tooltip_line2=$(translate "helloworld_tooltip_line2")
    
    # Build display text
    local text="${greeting}, ${world}!"
    
    # Build JSON data
    local data=$(jq -nc \
        --arg icon  "$icon" \
        --arg text  "$text" \
        --arg class "$success" \
        --arg line1 "$tooltip_line1" \
        --arg line2 "$tooltip_line2" \
        '{
        "icon": "$icon",
        "text": "$text",
        "class": "success",
        "tooltip": [$line1, $line2]
        }')

    # Render
    render "$mode" "$data"
}

# Action: greet with custom name
helloworld_greet() {
    local name="${1:-World}"
    local greeting=$(get_module_setting "greeting" "Hello")
    local data=$(jq -nc \
        --arg icon  "👋" \
        --arg text  "${greeting}, ${name}!" \
        --arg class "success" \
        '{icon: $icon, text: $text, class: $class, tooltip: []}')

    #Render
    render "terminal" "$data"
}
