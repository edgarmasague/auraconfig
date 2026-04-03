#!/bin/bash
# Module: Weather

WEATHER_TTL="$(lethe_minutes "$(get_module_setting "ttl" "60")")"
WEATHER_CACHE_KEY="$(get_module_setting "cache_key" "weather")"
WEATHER_GEO_TTL="$(lethe_minutes "$(get_module_setting "geo_ttl" "1440")")"
WEATHER_GEO_URL="$(get_module_setting "geo_url" "https://ipapi.co/json")"
WEATHER_API_URL="$(get_module_setting "api_url" "https://api.met.no/weatherapi/locationforecast/2.0/compact")"
WEATHER_USER_AGENT="$(get_module_setting "user_agent" "AuraConfig")/${AURA_VERSION:-0.1.0}"

_weather_icon() {
    local map
    map=$(get_module_setting "icon_map" "{}")
    echo "$map" | jq -r --arg code "$1" '.[$code] // "❓"'
}

_weather_class() {
    local map
    map=$(get_module_setting "class_map" "{}")
    echo "$map" | jq -r --arg code "$1" '.[$code] // "unknown"'
}

_weather_error() {
    local msg="$1" mode="$2"
    local display="$(get_module_setting "display" "icon-text")"
    local data=$(jq -nc \
                    --arg     icon    "⚠" \
                    --arg     text    "$(translate "weather_error")" \
                    --arg     class   "error" \
                    --arg     display "$display" \
                    --argjson tooltip "[\"$msg\"]" \
                    '{icon:$icon, text:$text, class:$class, display:$display, tooltip:$tooltip}')
    render "$mode" "$data"
}

_weather_fetch_geo() {
    local geo_data=$(curl -sf --max-time 10 "$WEATHER_GEO_URL") || return 1
    local lat=$(echo "$geo_data"      | jq -r '.latitude')
    local lon=$(echo "$geo_data"      | jq -r '.longitude')
    local city=$(echo "$geo_data"     | jq -r '.city')
    local country=$(echo "$geo_data"  | jq -r '.country_name')
    local timezone=$(echo "$geo_data" | jq -r '.timezone')
    local result=$(jq -nc \
                    --arg tz      "$timezone" \
                    --arg city    "$city" \
                    --arg country "$country" \
                    --arg lat     "$lat" \
                    --arg lon     "$lon" \
                    '{tz:$tz, city:$city, country:$country, lat:$lat, lon:$lon}')
    lethe_set "geo" "$result" "$WEATHER_GEO_TTL"
    echo "$result"
}

_weather_fetch() {
    local mode="$1"

    if ! command -v curl &>/dev/null; then
        _weather_error "curl not found" "$mode"; return 1
    fi

    local geo
    if ! geo=$(lethe_get "geo"); then
        geo=$(_weather_fetch_geo) || {
            _weather_error "$(translate "weather_geo_error")" "$mode"; return 1
        }
    fi

    local lat=$(echo "$geo"     | jq -r '.lat')
    local lon=$(echo "$geo"     | jq -r '.lon')
    local city=$(echo "$geo"    | jq -r '.city')
    local country=$(echo "$geo" | jq -r '.country')
    local met_data=$(curl -sf --max-time 10 \
        -H "User-Agent: $WEATHER_USER_AGENT" \
        "${WEATHER_API_URL}?lat=${lat}&lon=${lon}") || {
        _weather_error "$(translate "weather_fetch_error")" "$mode"; return 1
    }
    local timeseries=$(echo "$met_data" | jq '.properties.timeseries[0]')
    local temp=$(echo "$timeseries"      | jq -r '.data.instant.details.air_temperature')
    local humidity=$(echo "$timeseries"  | jq -r '.data.instant.details.relative_humidity')
    local wind=$(echo "$timeseries"      | jq -r '.data.instant.details.wind_speed')
    local precip=$(echo "$timeseries"    | jq -r '.data.next_1_hours.details.precipitation_amount')
    local icon_code=$(echo "$timeseries" | jq -r '.data.next_1_hours.summary.symbol_code')
    local wind_kmh=$(echo "$wind * 3.6"  | bc -l | cut -c1-4)
    local result=$(jq -nc \
                    --arg icon     "$icon_code" \
                    --arg temp     "$temp" \
                    --arg city     "$city" \
                    --arg country  "$country" \
                    --arg humidity "$humidity" \
                    --arg wind     "$wind_kmh" \
                    --arg precip   "$precip" \
                    '{icon:$icon, temperature:$temp, city:$city, country:$country,
                    humidity:$humidity, wind_speed:$wind, precipitation:$precip}')
    lethe_set "$WEATHER_CACHE_KEY" "$result" "$WEATHER_TTL"
    echo "$result"
}

module_weather() {
    local mode="${1:-terminal}"

    local weather
    if ! weather=$(lethe_get "$WEATHER_CACHE_KEY"); then
        weather=$(_weather_fetch "$mode") || return 1
    fi

    local temp icon_code city humidity wind precip
    local temp=$(echo "$weather"      | jq -r '.temperature')
    local icon_code=$(echo "$weather" | jq -r '.icon')
    local city=$(echo "$weather"      | jq -r '.city')
    local humidity=$(echo "$weather"  | jq -r '.humidity')
    local wind=$(echo "$weather"      | jq -r '.wind_speed')
    local precip=$(echo "$weather"    | jq -r '.precipitation')
    local icon=$(_weather_icon "$icon_code")
    local class=$(_weather_class "$icon_code")

    local lex_city=$(translate "weather_city")
    local lex_temp=$(translate "weather_temp")
    local lex_hum=$(translate "weather_humidity")
    local lex_wind=$(translate "weather_wind")
    local lex_precip=$(translate "weather_precip")
    local lex_cond=$(translate "weather_cond")
    local lex_cache=$(translate "weather_cached")

    local ttl_min=$(( $(lethe_ttl "$WEATHER_CACHE_KEY") / 60 ))
    local tooltip_json=$(jq -nc \
                            --arg city   "<b>${lex_city}:</b> ${city:-N/A}" \
                            --arg temp   "<b>${lex_temp}:</b> ${temp:-N/A}°C" \
                            --arg hum    "<b>${lex_hum}:</b> ${humidity:-N/A}%" \
                            --arg wind   "<b>${lex_wind}:</b> ${wind:-N/A} km/h" \
                            --arg precip "<b>${lex_precip}:</b> ${precip:-N/A} mm/h" \
                            --arg cond   "<b>${lex_cond}:</b> $(translate "weather_cond_${icon_code:-unknown}")" \
                            --arg cache  "<b>${lex_cache}:</b> ${ttl_min}min" \
                            '[$city, $temp, $hum, $wind, $precip, $cond, $cache]')
    local display="$(get_module_setting "display" "icon-text")"
    local data=$(jq -nc \
                    --arg     icon    "$icon" \
                    --arg     text    "${temp:-?}°C" \
                    --arg     class   "$class" \
                    --arg     display "$display" \
                    --argjson tooltip "$tooltip_json" \
                    '{icon:$icon, text:$text, class:$class, display:$display, tooltip:$tooltip}')
    render "$mode" "$data"
}
