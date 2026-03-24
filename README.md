<p align="center"> <img src="assets/logo.png" width="150" alt="AuraConfig Logo"> </p>

# ⚙️ AuraConfig

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Bash](https://img.shields.io/badge/bash-4.0%2B-orange)

**Modular and minimalist framework for custom widgets on Linux systems.**

[🇪🇸 Español](README.es.md) | [🇵🇹 Português](README.pt.md)

AuraConfig is a lightweight Bash-based ecosystem for creating modular widgets. Designed under the Unix philosophy, it is fully XDG-compliant and powered by the **Lexis** translation engine for efficient, high-performance multi-language support.

---

## 📺 Demo

![AuraConfig Demo](assets/demo.gif)

*Example of `list`, `info`, Waybar output, and error handling.*

---

## 🎯 Quick Start

```bash
# Clone and install
git clone https://github.com/edgarmasague/auraconfig.git
cd auraconfig
make install

# Try it out
aura helloworld
aura list
aura help
```

## ✨ Features

- 🌍 **i18n with [Lexis](https://github.com/edgarmasague/lexis)** - Integrated high-performance translation engine with zero external dependencies.

- 🎨 **Output Architecture:** Agnostic rendering system currently supporting Terminal and JSON formats, designed for extensibility.

- 🔧 **Modular Design** - Add functionality simply by dropping scripts into the modules folder.

- 📦 **XDG Compliant** - Respects system directory hierarchy (`~/.config`, `~/.local/share`, etc.) to keep your HOME clean.

- ⚡ **Action System** - Native support for click events, scrolling, and background commands (like controlling `mpv` or services).

- 🎯 **Pure Bash** - No overhead, fast execution, and extremely easy to customize.

---

## 📋 Requirements

- **Bash 4.0+**

- **jq:** Essential JSON processor for module communication and configuration.

- **GNU Make (Optional):** For simplified install/uninstall management.

- **Nerd Fonts (Optional):** For extended icon support in widgets.

| Distribution        | Install Command               |
| ------------------- | ----------------------------- |
| **openSUSE**        | `sudo zypper install jq make` |
| **Arch Linux**      | `sudo pacman -S jq make`      |
| **Debian / Ubuntu** | `sudo apt install jq make`    |
| **Fedora**          | `sudo dnf install jq make`    |

If you use `icon_style=nerd-fonts` in `~/.config/auraconfig/.env`, install only the symbols (without changing your current font) with this command:

```bash
# 1. Crear directorio local de fuentes (No Root)
mkdir -p ~/.local/share/fonts

# 2. Descargar e instalar solo los símbolos
cd /tmp
curl -OL https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.tar.xz
tar -xvf NerdFontsSymbolsOnly.tar.xz -C ~/.local/share/fonts

# 3. Actualizar la caché de fuentes
fc-cache -fv
```

---

## 🚀 Installation & Management (No Root)

AuraConfig installs entirely in user space. **No sudo privileges are required** for the framework installation.

###### Option A: Using `make` (Recommended)

The Makefile centralizes the logic by invoking system scripts to avoid duplication:

```bash
make install      # Install AuraConfig

make uninstall    # Uninstall AuraConfig
```

### Opción B: Directamente con Bash

If you don't have make or prefer to run the scripts directly:

```bash
# Install
chmod +x scripts/*.sh
bash scripts/install.sh

# Desinstalar
chmod +x scripts/*.sh
bash scripts/uninstall.sh
```

### Installation Paths (XDG compliant)

```
~/.local/bin/aura                 # Executable
~/.local/lib/auraconfig/          # Libraries
~/.local/share/auraconfig/        # Data (modules, translations)
~/.config/auraconfig/             # Configuration
~/.cache/auraconfig/              # Cache
```

---

## 🖥️ Panel Compatibility

| Interface         | Status             | Output Type          |
| ----------------- | ------------------ | -------------------- |
| **Terminal**      | ✅ Native           | Formatted plain text |
| **Waybar**        | ✅ Native           | Structured JSON      |
| **Polybar / DWM** | 🛠️ In development | Plain text (planned) |

---

## ⚙️ Configuration

AuraConfig is configured via `~/.config/auraconfig/.env`:

```bash
# Language (auto|en|es|pt)
lang=auto

# Icon style (emoji|nerd-fonts|ascii)
icon_style=emoji

# Show icons in terminal (true|false)
show_icons=true

# Update interval (seconds)
update_interval=10
```

---

## 📦 Example: Hello World Module

A functional module integrates through three basic components:

1. **Metadata** (`module.json`) - Defines name, version, and base settings

2. **Logic** (`helloworld.sh`) - Function to process data and action functions

3. **Translation** (`lang/en.lex`) - Key-value dictionary for Lexis

### Usage:

```bash
# View the widget in terminal
aura helloworld
```

### Output esperado:

```bash
$ aura helloworld
[✓] 👋 Hello, World!
This is a simple example module
```

---

## 📁 Estructura del Proyecto

```
auraconfig/
├── bin/
│   └── auraconfig               # Main executable
├── lib/                         # Core libraries
│   ├── lexis.sh                # i18n Engine
│   ├── i18n.sh                 # Language system
│   ├── env.sh                  # Configuration loader
│   ├── log.sh                  # Logging system
│   ├── modules.sh              # Module manager
│   ├── output.sh               # Output rendering
│   └── help.sh                 # Help system
├── share/
│   ├── VERSION
│   ├── lang/                   # Core translations
│   │   ├── en.lex, es.lex, pt.lex
│   │   └── help/               # Help files
│   └── modules/                # Included modules
│       └── helloworld/
│           ├── module.json
│           ├── helloworld.sh
│           └── lang/
│               ├── en.lex
│               ├── es.lex
│               └── pt.lex
├── scripts/                    # Installation scripts
│   ├── common.sh               # Shared functions
│   ├── install.sh              # Installation script
│   └── uninstall.sh            # Uninstallation script
├── Makefile
├── .env.example                # Configuration template
└── README.md
```

---

## 🗺️ Roadmap

- [x] **Core** - Module system and base rendering engine

- [x] **i18n** - Full integration with the Lexis engine

- [ ] **New Outputs** - Native support for Polybar, DWM, Lemonbar

- [ ] **Module Library** - Official widgets (CPU, Memory, Network, Battery)

---

## 🤝 Contributing

Contributions are welcome. Please open an issue or pull request.

---

## 📝 License

MIT License. See the [LICENSE](https://www.google.com/search?q=LICENSE) file for more details.

---

**Made with ⚙️ and ❤️ by [Edgar Masague](https://github.com/edgarmasague)**