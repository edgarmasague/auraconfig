# AuraConfig - Makefile

NAME     := auraconfig
VERSION  := $(shell cat share/VERSION 2>/dev/null || echo "0.1.0")
PREFIX   ?= $(HOME)/.local

# Directories
BINDIR      := $(PREFIX)/bin
LIBDIR      := $(PREFIX)/lib/$(NAME)
SHAREDIR    := $(PREFIX)/share/$(NAME)

# Scripts
INSTALL_SCRIPT     := scripts/install.sh
UNINSTALL_SCRIPT   := scripts/uninstall.sh
COMMON_SCRIPT   := scripts/common.sh

.PHONY: install uninstall clean help

install:
	@chmod +x $(INSTALL_SCRIPT)
	@chmod +x $(COMMON_SCRIPT)
	@bash $(INSTALL_SCRIPT)

uninstall:
	@chmod +x $(UNINSTALL_SCRIPT)
	@chmod +x $(COMMON_SCRIPT)
	@bash $(UNINSTALL_SCRIPT)

clean:
	@echo "Cleaning temporary files..."
	@find . -type f -name "*.swp" -delete
	@find . -type f -name "*.swo" -delete
	@find . -type f -name "*~" -delete
	@find . -type f -name ".DS_Store" -delete
	@echo "✓ Clean complete"

help:
	@echo "┌─────────────────────────────────────────┐"
	@echo "│      AuraConfig - Module Framework      │"
	@echo "└─────────────────────────────────────────┘"
	@echo ""
	@echo "Targets:"
	@echo "  make install    - Install AuraConfig"
	@echo "  make uninstall  - Uninstall AuraConfig"
	@echo "  make clean      - Clean build artifacts"
	@echo "  make help       - Show this help"
	@echo ""
	@echo "Requirements:"
	@echo "  - Bash 4.0+"
	@echo "  - jq"
	@echo ""
