#!/bin/bash
# AuraConfig - Log System
log() {
    local level="$1"
    shift
    local message="$*"
    
    case "$level" in
        "error")
            echo -e "\e[31m[✗]\e[0m $message" >&2
            ;;
        "warn")
            echo -e "\e[33m[!]\e[0m $message" >&2
            ;;
        "success")
            echo -e "\e[32m[✓]\e[0m $message"
            ;;
        "info")
            echo -e "\e[34m[i]\e[0m $message"
            ;;
        *)
            echo "$message"
            ;;
    esac
}
