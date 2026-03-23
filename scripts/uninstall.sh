#!/bin/bash
# AuraConfig - Uninstallation Script

set -e

# Get script directory
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common functions
source "${SCRIPTDIR}/common.sh"

# Confirm uninstall
confirm_uninstall() {
    log_warn "This will uninstall AuraConfig from your system"
    echo ""
    echo "The following will be deleted:"
    echo " (executable)     - ${BINDIR}/aura"
    echo " (libraries)      - ${LIBDIR}"
    echo " (data)           - ${DATADIR}"

    if [[ -d "${CONFDIR}" ]]; then
        echo ""
        echo "Configuration will be preserved:"
        echo " (user config) - ${CONFDIR}/.env"
        echo ""
        read -p "Do you want to remove configuration too? [y/N] " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            REMOVE_CONFIG=true
        else
            REMOVE_CONFIG=false
        fi
    fi
    if [[ -d "${CACHEDIR}" ]]; then
        echo " (cache)      - ${CACHEDIR}"
    fi
    
    echo ""
    read -p "Continue with uninstall? [y/N] " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "Uninstall cancelled"
        exit 0
    fi
}

# Remove files
remove_files() {
    log_info "Removing files..."
    
    local removed=false
    
    # Remove executable
    if [[ -f "${BINDIR}/aura" ]]; then
        rm -f "${BINDIR}/aura"
        log_success "Removed executable"
        removed=true
    fi
    
    # Remove libraries
    if [[ -d "${LIBDIR}" ]]; then
        rm -rf "${LIBDIR}"
        log_success "Removed libraries"
        removed=true
    fi
    
    # Remove data files
    if [[ -d "${DATADIR}" ]]; then
        rm -rf "${DATADIR}"
        log_success "Removed data files"
        removed=true
    fi
    
    # Remove config (if requested)
    if [[ "${REMOVE_CONFIG:-false}" == "true" ]] && [[ -d "${CONFDIR}" ]]; then
        rm -rf "${CONFDIR}"
        log_success "Removed configuration"
    fi

    # Remove cache
    if [[ -d "${CACHEDIR}" ]]; then
        rm -rf "${CACHEDIR}"
        log_success "Clean cache"
    fi
    
    if [[ "$removed" == "false" ]]; then
        log_warn "AuraConfig was not found or already removed"
    fi
}

# Show completion message
show_completion() {
    echo ""
    log_success "AuraConfig uninstall successfully"
    if [[ "${REMOVE_CONFIG:-false}" == "false" ]] && [[ -d "${CONFDIR}" ]]; then
        echo ""
        log_info "Configuration preserved in: ${CONFDIR}"
    fi
    echo ""
    echo "Thank you for using AuraConfig!"
    echo ""
}

# Main uninstallation
main() {
    echo "┌─────────────────────────────────────────┐"
    echo "│          AuraConfig Uninstall           │"
    echo "└─────────────────────────────────────────┘"
    echo ""
    # Check if installed
    if [[ ! -f "${BINDIR}/aura" ]] && [[ ! -d "${LIBDIR}" ]] && [[ ! -d "${DATADIR}" ]]; then
        log_info "AuraConfig is not installed"
        exit 0
    fi
    
    confirm_uninstall
    remove_files
    show_completion
}

# Run
main
