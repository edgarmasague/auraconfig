#!/bin/bash
# AuraConfig - Help System
show_help() {
    local help_file="$AURA_SHARE_DIR/lang/help/${AURA_LANG}.txt"
    
    if [[ ! -f "$help_file" ]]; then
        help_file="$AURA_SHARE_DIR/lang/help/en.txt"
    fi
    
    if [[ -f "$help_file" ]]; then
        # Read content and replace with bash substitution
        local content=$(<"$help_file")
        echo "${content//__VERSION__/v${AURA_VERSION}}"
    else
        echo "AuraConfig v${AURA_VERSION} - Waybar Module Framework"
        echo ""
        echo "Usage:"
        echo "  aura <module>                   # Run module (terminal mode)"
        echo "  aura waybar <module>            # Run module (Waybar JSON mode)"
        echo "  aura pretty <module>            # Run module (pretty/neofetch mode)"
        echo "  aura action <module> <command>  # Execute module action"
        echo ""
        echo "  aura list                       # List all modules"
        echo "  aura modules list               # List all modules (detailed)"
        echo "  aura modules info <name>        # Show module information"
        echo "  aura modules enable <name>      # Enable module"
        echo "  aura modules disable <name>     # Disable module"
        echo ""
        echo "  aura version                    # Show version"
        echo "  aura help                       # Show this help"
        echo ""
        echo "Examples:"
        echo "  aura power                      # Show battery status"
        echo "  aura waybar power               # Battery status as JSON"
        echo "  aura pretty sysinfo             # System info (neofetch style)"
        echo "  aura action radio toggle        # Toggle radio play/pause"
    fi
}
