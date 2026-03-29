#!/bin/bash
# =============================================================================
# Lethe - Minimalist cache system runtime for Bash
# https://github.com/edgarmasague/lethe
# =============================================================================

# Cache directory — uses AURA_CACHE_DIR if available, else XDG default
_lethe_dir() {
    echo "${AURA_CACHE_DIR:-${XDG_CACHE_HOME:-$HOME/.cache}/auraconfig}"
}

# Internal: path to cache file for a given key
_lethe_path() {
    local key="$1"
    echo "$(_lethe_dir)/${key}.cache"
}

# Internal: path to metadata file (stores expiry timestamp)
_lethe_meta() {
    local key="$1"
    echo "$(_lethe_dir)/${key}.meta"
}

# Ensure cache directory exists
_lethe_init() {
    mkdir -p "$(_lethe_dir)"
}

# lethe_set <key> <data> [ttl_seconds]
# Store data in cache with optional TTL (default: 300s)
lethe_set() {
    local key="$1"
    local data="$2"
    local ttl="${3:-300}"

    _lethe_init

    local cache_file; cache_file=$(_lethe_path "$key")
    local meta_file;  meta_file=$(_lethe_meta "$key")
    local expires_at=$(( $(date +%s) + ttl ))

    printf '%s' "$data" > "$cache_file"
    printf '%s' "$expires_at" > "$meta_file"
}

# lethe_get <key>
# Print cached data to stdout
# Returns 0 if cache is valid, 1 if missing or expired
lethe_get() {
    local key="$1"
    local cache_file; cache_file=$(_lethe_path "$key")
    local meta_file;  meta_file=$(_lethe_meta "$key")

    # Check files exist
    [[ ! -f "$cache_file" || ! -f "$meta_file" ]] && return 1

    # Check TTL
    local expires_at; expires_at=$(cat "$meta_file")
    local now; now=$(date +%s)

    if [[ "$now" -ge "$expires_at" ]]; then
        # Expired — clean up
        rm -f "$cache_file" "$meta_file"
        return 1
    fi

    cat "$cache_file"
    return 0
}

# lethe_has <key>
# Returns 0 if cache is valid, 1 if missing or expired (no output)
lethe_has() {
    local key="$1"
    local cache_file; cache_file=$(_lethe_path "$key")
    local meta_file;  meta_file=$(_lethe_meta "$key")

    [[ ! -f "$cache_file" || ! -f "$meta_file" ]] && return 1

    local expires_at; expires_at=$(cat "$meta_file")
    local now; now=$(date +%s)

    [[ "$now" -lt "$expires_at" ]]
}

# lethe_ttl <key>
# Print remaining TTL in seconds, or 0 if expired/missing
lethe_ttl() {
    local key="$1"
    local meta_file; meta_file=$(_lethe_meta "$key")

    [[ ! -f "$meta_file" ]] && echo 0 && return 1

    local expires_at; expires_at=$(cat "$meta_file")
    local now; now=$(date +%s)
    local remaining=$(( expires_at - now ))

    [[ "$remaining" -gt 0 ]] && echo "$remaining" || echo 0
}

# lethe_clear <key>
# Remove a specific cache entry
lethe_clear() {
    local key="$1"
    rm -f "$(_lethe_path "$key")" "$(_lethe_meta "$key")"
}

# lethe_clear_all
# Remove all cache entries
lethe_clear_all() {
    local dir; dir=$(_lethe_dir)
    [[ -d "$dir" ]] && rm -f "$dir"/*.cache "$dir"/*.meta
}

# lethe_info <key>
# Print cache status info (debug)
lethe_info() {
    local key="$1"
    local cache_file; cache_file=$(_lethe_path "$key")
    local meta_file;  meta_file=$(_lethe_meta "$key")

    echo "Key:     $key"
    echo "File:    $cache_file"

    if [[ ! -f "$meta_file" ]]; then
        echo "Status:  not cached"
        return 1
    fi

    local expires_at; expires_at=$(cat "$meta_file")
    local now; now=$(date +%s)
    local remaining=$(( expires_at - now ))

    if [[ "$remaining" -gt 0 ]]; then
        echo "Status:  valid"
        echo "Expires: in ${remaining}s ($(date -d "@$expires_at" "+%H:%M:%S"))"
        echo "Size:    $(wc -c < "$cache_file") bytes"
    else
        echo "Status:  expired"
    fi
}
