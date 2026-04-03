#!/bin/bash
# Module: System Updates

#Config
UPDATES_TTL="$(lethe_minutes "$(get_module_setting "ttl" "60")")"
UPDATES_CACHE_KEY="$(get_module_setting "cache_key" "updates")"

#Fetch System
_updates_fetch_system() {
    local distro=$(grep "^ID=" /etc/os-release 2>/dev/null | cut -d'=' -f2 | tr -d '"')
    local count=0
    case "$distro" in
        opensuse-leap|opensuse-tumbleweed)
            count=$(zypper --non-interactive lu 2>/dev/null | grep -c "^v " || true) ;;
        opensuse-microos)
            count=$(transactional-update --quiet pkg-list-updates 2>/dev/null \
                | grep -c "^[A-Za-z]" || true) ;;
        arch|manjaro|endeavouros)
            count=$(checkupdates 2>/dev/null | wc -l || true) ;;
        debian|ubuntu|linuxmint|pop)
            count=$(apt list --upgradable 2>/dev/null | grep -c "upgradable" || true) ;;
        fedora)
            count=$(dnf check-update --quiet 2>/dev/null | grep -c "^[a-zA-Z]" || true) ;;
    esac
 
    echo "$count"
}

#Fetch Flatpak
_updates_fetch_flatpak() {
    local check_flatpak="${1:-true}"
 
    if [[ "$check_flatpak" != "true" ]] || ! command -v flatpak &>/dev/null; then
        echo "0"
        return
    fi
 
    flatpak remote-ls --updates 2>/dev/null | wc -l || echo "0"
}

#Fetch Snap
_updates_fetch_snap() {
    local check_snap="${1:-false}"
 
    if [[ "$check_snap" != "true" ]] || ! command -v snap &>/dev/null; then
        echo "0"
        return
    fi
 
    snap refresh --list 2>/dev/null | tail -n +2 | wc -l || echo "0"
}

#Fetch
_updates_fetch() {
    local check_flatpak="${1:-true}"
    local check_snap="${2:-false}"
 
    local system_count=$(_updates_fetch_system)
    local flatpak_count=$(_updates_fetch_flatpak "$check_flatpak")
    local snap_count=$(_updates_fetch_snap "$check_snap")
 
    local result=$(jq -nc \
                        --argjson system  "$system_count" \
                        --argjson flatpak "$flatpak_count" \
                        --argjson snap    "$snap_count" \
                        '{system:$system, flatpak:$flatpak, snap:$snap}')
    lethe_set "$UPDATES_CACHE_KEY" "$result" "$UPDATES_TTL"
    echo "$result"
}

module_updates() {
    local mode="${1:-terminal}"
    local check_flatpak="$(get_module_setting "check_flatpak" "true")"
    local check_snap="$(get_module_setting "check_snap" "false")"
 
    # Translations
    local lex_total=$(translate "updates_total")
    local lex_system=$(translate "updates_system")
    local lex_flatpak=$(translate "updates_flatpak")
    local lex_snap=$(translate "updates_snap")
    local lex_uptodate=$(translate "updates_up_to_date")
 
    # Cache or fetch
    local counts
    if ! counts=$(lethe_get "$UPDATES_CACHE_KEY"); then
        counts=$(_updates_fetch "$check_flatpak" "$check_snap")
    fi
 
    local system_count=$(echo "$counts"  | jq -r '.system')
    local flatpak_count=$(echo "$counts" | jq -r '.flatpak')
    local snap_count=$(echo "$counts"    | jq -r '.snap')
    local total=$(( system_count + flatpak_count + snap_count ))
 
    # Icon and class
    local icon css_class
    if [[ "$total" -eq 0 ]]; then
        icon="$(get_module_setting "icon_no_update" "󰑓")"; css_class="up-to-date"
    else
        icon="$(get_module_setting "icon_update" "󱄋")"; css_class="update"
    fi
 
    # Display text
    local text
    if [[ "$total" -eq 0 ]]; then
        text="$lex_uptodate"
    else
        text="$total"
    fi
 
    # Tooltip array
    local tooltip_json=$(jq -nc \
                            --arg t "<b>${lex_total}:</b> ${total}" \
                            --arg s "<b>${lex_system}:</b> ${system_count}" \
                            '[$t, $s]')

    if [[ "$check_flatpak" == "true" ]]; then
        tooltip_json=$(echo "$tooltip_json" \
            | jq --arg f "<b>${lex_flatpak}:</b> ${flatpak_count}" '. + [$f]')
    fi
 
    if [[ "$check_snap" == "true" ]]; then
        tooltip_json=$(echo "$tooltip_json" \
            | jq --arg s "<b>${lex_snap}:</b> ${snap_count}" '. + [$s]')
    fi

    local display="$(get_module_setting "display" "icon-text")"

    # Build data and render
    local data
    data=$(jq   -nc \
                --arg     icon    "$icon" \
                --arg     text    "$text" \
                --arg     class   "$css_class" \
                --arg     display "$display" \
                --argjson tooltip "$tooltip_json" \
                '{icon:$icon, text:$text, class:$class, display:$display, tooltip:$tooltip}')
 
    render "$mode" "$data"
}