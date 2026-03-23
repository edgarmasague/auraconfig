#!/bin/bash
# AuraConfig - Output System

# Main render function
render() {
    local mode="$1"
    local data="$2"
    
    case "$mode" in
        "waybar")
            render_waybar "$data"
            ;;
        "terminal")
            render_terminal "$data"
            ;;
        *)
            render_terminal "$data"
            ;;
    esac
}

# Render for Waybar
render_waybar() {
    local data="$1"
    
    # Extract fields
    local icon=$(echo "$data" | jq -r '.icon // ""')
    local text=$(echo "$data" | jq -r '.text // ""')
    local tooltip=$(echo "$data" | jq -r '.tooltip // .text')
    local class=$(echo "$data" | jq -r '.class // "info"')
    
    # Build display text with icon
    local display_text=""
    if [[ -n "$icon" && -n "$text" ]]; then
        display_text="${icon} ${text}"
    elif [[ -n "$icon" ]]; then
        display_text="$icon"
    elif [[ -n "$text" ]]; then
        display_text="$text"
    fi
    
    # Use text as tooltip fallback if tooltip is empty
    if [[ -z "$tooltip" ]]; then
        tooltip="$text"
    fi
    
    # Output JSON using jq
    jq -nc \
        --arg text "$display_text" \
        --arg tooltip "$tooltip" \
        --arg class "$class" \
        '{text: $text, tooltip: $tooltip, class: $class}'
}

# Render for Terminal
render_terminal() {
    local data="$1"
    
    # Extract fields
    local icon=$(echo "$data" | jq -r '.icon // ""')
    local text=$(echo "$data" | jq -r '.text // ""')
    local tooltip=$(echo "$data" | jq -r '.tooltip // ""')
    local class=$(echo "$data" | jq -r '.class // "info"')
    
    # Check if icons should be shown (from .env)
    local show_icons=$(get_env "show_icons" "true")
    
    # Build display text
    local display_text=""
    
    if [[ "$show_icons" == "true" ]]; then
        # With icons
        if [[ -n "$icon" && -n "$text" ]]; then
            display_text="${icon} ${text}"
        elif [[ -n "$icon" ]]; then
            display_text="$icon"
        elif [[ -n "$text" ]]; then
            display_text="$text"
        fi
    else
        # Without icons
        display_text="$text"
    fi
    
    # Show with color based on class
    case "$class" in
        "success")
            echo -e "\e[32m[✓]\e[0m $display_text"
            ;;
        "error")
            echo -e "\e[31m[✗]\e[0m $display_text"
            ;;
        "warning")
            echo -e "\e[33m[!]\e[0m $display_text"
            ;;
        *)
            echo -e "\e[34m[i]\e[0m $display_text"
            ;;
    esac
    
    # Show tooltip if exists and different from text
    if [[ -n "$tooltip" && "$tooltip" != "$text" ]]; then
        echo "$tooltip"
    fi
}
