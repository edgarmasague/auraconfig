#!/bin/bash
# Module: Clock Timezones

CLOCK_TZ_TTL="$(lethe_minutes "$(get_module_setting "ttl" "5")")"
CLOCK_TZ_CACHE_KEY="$(get_module_setting "cache_key" "clock_timezones")"
CLOCK_GEO_TTL="$(lethe_minutes "$(get_module_setting "geo_ttl" "1440")")"

_clock_tz_fetch_geo() {
    local tz city country

    if tz=$(lethe_get "geo" | jq -r '.tz // empty' 2>/dev/null) && [[ -n "$tz" ]]; then
        city=$(lethe_get "geo"    | jq -r '.city // "Local"')
        country=$(lethe_get "geo" | jq -r '.country // ""')
    else
        tz=$(timedatectl show -p Timezone --value 2>/dev/null || echo "UTC")
        city="$(translate "clock_local")"
        country=""
    fi

    local result=$(jq -nc \
                        --arg tz      "$tz" \
                        --arg city    "$city" \
                        --arg country "$country" \
                        '{tz:$tz, city:$city, country:$country}')
    lethe_set "geo" "$result" "$CLOCK_GEO_TTL"
    echo "$result"
}

_clock_tz_format_offset() {
    local h=$(TZ="$1" date +%:z | cut -d: -f1)
    [[ "$h" =~ ^[+-]?0+$ ]] && echo "" && return
    echo "$h" | sed 's/^+0\([0-9]\)/+\1/; s/^-0\([0-9]\)/-\1/'
}

_clock_tz_tooltip_line() {
    local zone="$1" city="$2" country="$3"
    local hour=$(TZ="$zone" date +%H:%M)
    local offset=$(_clock_tz_format_offset "$zone")
    [[ -n "$offset" ]] && offset=" ($offset)"
    echo "$hour  $city, $country$offset"
}

module_clock_timezones() {
    local mode="${1:-terminal}"

    local location
    if ! location=$(lethe_get "geo"); then
        location=$(_clock_tz_fetch_geo)
    fi

    local local_tz=$(echo "$location"      | jq -r '.tz')
    local local_city=$(echo "$location"    | jq -r '.city')
    local local_country=$(echo "$location" | jq -r '.country')
    local local_time=$(TZ="$local_tz" date +%H:%M)
    local label="$local_time  $local_city${local_country:+, $local_country}"
    local tooltip_json=$(jq -nc --arg l "$label" '[$l]')
    local timezones=$(get_module_setting "timezones" "[]")

    while IFS= read -r entry; do
        local zone=$(echo "$entry"    | jq -r '.zone')
        local city=$(echo "$entry"    | jq -r '.city')
        local country=$(echo "$entry" | jq -r '.country')
        local line=$(_clock_tz_tooltip_line "$zone" "$city" "$country")
        tooltip_json=$(echo "$tooltip_json" | jq --arg l "$line" '. + [$l]')
    done < <(echo "$timezones" | jq -c '.[]')

    local icon="$(get_module_setting "icon" "󰥔")"
    local display="$(get_module_setting "display" "icon-text")"
    local data=$(jq -nc \
                    --arg     icon    "$icon" \
                    --arg     text    "$local_time" \
                    --arg     class   "" \
                    --arg     display "$display" \
                    --argjson tooltip "$tooltip_json" \
                    '{icon:$icon, text:$text, class:$class, display:$display, tooltip:$tooltip}')

    render "$mode" "$data"
}