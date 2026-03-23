#!/bin/bash
# AuraConfig - Installation Script

set -e

# Get script directory and aura directory
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AURADIR="$(cd "${SCRIPTDIR}/.." && pwd)"
SHAREDIR="$(cd "${AURADIR}/share" && pwd)"

# Get version
if [[ -f "${AURADIR}/share/VERSION" ]]; then
    VERSION=$(cat "${AURADIR}/share/VERSION")
else
    VERSION="0.1.0"
fi

# Load common functions
source "${SCRIPTDIR}/common.sh"

# Create directories
create_directories() {
    log_info "Creating directories..."
    mkdir -p "${BINDIR}"
    mkdir -p "${LIBDIR}"
    mkdir -p "${DATADIR}/lang/help"
    mkdir -p "${DATADIR}/modules"
    log_success "Directories created"
}

# Install files
install_files() {
    log_info "Installing files..."
    # Change to project root
    cd "${AURADIR}"
    log_info "  Installing executable..."
    install -m 755 bin/auraconfig "${BINDIR}/aura"
    log_info "  Installing libraries..."
    install -m 644 lib/*.sh "${LIBDIR}/"
    log_info "  Installing translations..."
    install -m 644 share/lang/*.lex "${DATADIR}/lang/"
    install -m 644 share/lang/help/*.txt "${DATADIR}/lang/help/"
    log_info "  Installing modules..."
    cp -r share/modules/* "${DATADIR}/modules/"
    find "${DATADIR}/modules" -type f -name "*.sh" -exec chmod 755 {} \;
    find "${DATADIR}/modules" -type f -name "*.json" -exec chmod 644 {} \;
    find "${DATADIR}/modules" -type f -name "*.lex" -exec chmod 644 {} \;
    log_info "  Installing VERSION..."
    install -m 644 share/VERSION "${DATADIR}/"
    log_success "Files installed"
}

# Show completion message
show_completion() {
    echo ""
    log_success "AuraConfig v${VERSION} installed successfully!"
    echo ""
    echo "Get started:"
    echo "  aura help          # Show help"
    echo "  aura list          # List modules"
    echo "  aura power         # Test battery module"
    echo ""
}

# Main installation
main() {
    echo "┌─────────────────────────────────────────┐"
    echo "│         AuraConfig Installation         │"
    echo "└─────────────────────────────────────────┘"
    echo ""
    
    check_requirements
    create_directories
    install_files
    
    show_completion
    check_path
    check_iconfonts
}

# Run
main
