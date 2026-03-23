#!/bin/bash
# AuraConfig - Common Script

set -e

NAME="auraconfig"

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NoColor='\033[0m'

# XDG Base Directory Specification
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# Paths
readonly PREFIX="${HOME}/.local"
readonly BINDIR="${PREFIX}/bin"
readonly LIBDIR="${PREFIX}/lib/${NAME}"
readonly DATADIR="${XDG_DATA_HOME}/${NAME}"
readonly CONFDIR="${XDG_CONFIG_HOME}/${NAME}"
readonly CACHEDIR="${XDG_CACHE_HOME}/${NAME}"  

# Functions Logs
log_info() {
    echo -e "${BLUE}[i]${NoColor} $*"
}

log_success() {
    echo -e "${GREEN}[✓]${NoColor} $*"
}

log_error() {
    echo -e "${RED}[✗]${NoColor} $*" >&2
}

log_warn() {
    echo -e "${YELLOW}[!]${NoColor} $*"
}

# Check requirements
check_requirements() {
    log_info "Checking requirements..."
    
    # Check Bash version
    if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
        log_error "Bash 4.0+ is required (current: ${BASH_VERSION})"
        exit 1
    fi
    log_success "Bash version: ${BASH_VERSION}"
    
    # Check jq
    if ! command -v jq &>/dev/null; then
        log_error "jq is required but not installed"
        echo ""
        echo "Install with:"
        echo "  openSUSE:  sudo zypper install jq"
        echo "  Arch:      sudo pacman -S jq"
        echo "  Debian:    sudo apt install jq"
        echo "  Fedora:    sudo dnf install jq"
        echo "  macOS:     brew install jq"
        exit 1
    fi
    log_success "jq version: $(jq --version)"
}

# Check PATH
check_path() {
    if [[ ":$PATH:" != *":${BINDIR}:"* ]]; then
        log_warn "Warning: ${BINDIR} is not in your PATH"
        echo ""
        echo "Add this to your shell rc file (~/.bashrc, ~/.zshrc, etc.):"
        echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
        echo ""
    fi
}
check_iconfonts() {
    local icon_style=$(grep "^icon_style=" "${CONFDIR}/.env" 2>/dev/null | cut -d'=' -f2 | tr -d '"' || echo "emoji")
    
    if [[ "$icon_style" == "nerd-fonts" ]]; then
        log_info "Note: Nerd Fonts are required for icon_style=nerd-fonts"
        log_info "Install from: https://www.nerdfonts.com/"
        echo ""
    fi
}
