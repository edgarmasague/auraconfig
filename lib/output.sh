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

_join_tooltip() {
    local data="$1"
    local sep="$2"
    echo "$data" | jq -r ".tooltip | join(\"$sep\")"
}

_build_display() {
    local icon="$1"
    local text="$2"
    local display="$3"
    case "$display" in
        "icon")      echo "$icon" ;;
        "text")      echo "$text" ;;
        "icon-text")
            [[ -n "$icon" && -n "$text" ]] \
                && echo "$icon $text" \
                || echo "${icon}${text}" ;;
    esac
}

# Convierte HTML a secuencias ANSI para terminal
_html_to_ansi() {
    sed \
        -e 's|<b>\(.*\)</b>|\x1b[1m\1\x1b[0m|g' \
        -e 's|<i>\(.*\)</i>|\x1b[3m\1\x1b[0m|g' \
        -e 's|<u>\(.*\)</u>|\x1b[4m\1\x1b[0m|g' \
        -e 's|<tt>\(.*\)</tt>|\x1b[2m\1\x1b[0m|g' \
        -e 's|<big>\(.*\)</big>|\x1b[1m\1\x1b[0m|g' \
        -e 's|<small>\(.*\)</small>|\x1b[2m\1\x1b[0m|g' \
        -e "s|<span foreground='#f38ba8'>\(.*\)</span>|\x1b[91m\1\x1b[0m|g" \
        -e "s|<span foreground='#f9e2af'>\(.*\)</span>|\x1b[93m\1\x1b[0m|g" \
        -e "s|<span background='#a6e3a1' foreground='#11111b' weight='bold'>\(.*\)</span>|\x1b[42;30;1m\1\x1b[0m|g" \
        -e 's|<span[^>]*>\(.*\)</span>|\1|g' \
        -e 's|<[^>]*>||g'
}

_parse_data() {
    local data="$1"
    icon=$(echo "$data" | jq -r '.icon // ""')
    text=$(echo "$data" | jq -r '.text // ""')
    tooltip=$(echo "$data" | jq -r '.tooltip // .text')
    class=$(echo "$data" | jq -r '.class // "info"')
    display=$(echo "$data" | jq -r '.display // "icon-text"')
}

# Render for Waybar
render_waybar() {
    local data="$1"
    # Extract fields
    _parse_data "$data"
    local display_text; display_text=$(_build_display "$icon" "$text" "$display")
    local tooltip;      tooltip=$(_join_tooltip "$data" '\n')
    [[ -z "$tooltip" ]] && tooltip="$display_text"
    
    if [[ -n "$class" ]]; then
        jq -nc \
            --arg text    "$display_text" \
            --arg tooltip "$tooltip" \
            --arg class   "$class" \
            '{text:$text, tooltip:$tooltip, class:$class}'
    else
        jq -nc \
            --arg text    "$display_text" \
            --arg tooltip "$tooltip" \
            '{text:$text, tooltip:$tooltip}'
    fi
}

# Render for Terminal
render_terminal() {
    local data="$1"
    
    # Extract fields
    _parse_data "$data"
    
    # Check if icons should be shown (from .env)
    local show_icons=$(get_env "show_icons" "true")
    
    local display_text
    if [[ "$show_icons" == "true" ]]; then
        display_text=$(_build_display "$icon" "$text" "$display")
    else
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
            echo -e "\e[33m[!]\e[0m $data" | jq -r '.tooltip[]?' | _html_to_ansi)
    if [[ -n "$tooltip_lines" ]]; then
        echo ""
        echo -e "$tooltip_lines" | while IFS= read -r line; do
            printf "  %s\n" "$line"
        done
    fi
}
