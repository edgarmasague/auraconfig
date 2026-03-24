<p align="center"> <img src="assets/logo.png" width="150" alt="AuraConfig Logo"> </p>

# ⚙️ AuraConfig

![Version](https://img.shields.io/badge/version-0.1.0-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Bash](https://img.shields.io/badge/bash-4.0%2B-orange)

**Framework modular e minimalista para widgets personalizados em sistemas Linux.**

[🇬🇧 English](README.md) | [🇪🇸 Español](README.es.md)

AuraConfig é um ecossistema leve baseado em Bash para criar widgets modulares. Projetado sob a filosofia Unix, é totalmente compatível com os padrões XDG e utiliza o motor de traduções **Lexis** para um suporte multi-idioma eficiente e de alto desempenho.

---

## 📺 Demo

![AuraConfig Demo](assets/demo.gif)

*Exemplo de `list`, `info`, saída para `waybar` e gestão de erros.*

---

## 🎯 Quick Start

```bash
# Clonar e instalar
git clone https://github.com/edgarmasague/auraconfig.git
cd auraconfig
make install

# Testar
aura helloworld
aura list
aura help
```

## ## ✨ Características

- 🌍 **i18n com [Lexis](https://github.com/edgarmasague/lexis)** - Integração com o motor de traduções de alto desempenho sem dependências externas.

- 🎨 **Arquitetura de Saída:** Sistema de renderização agnóstico que suporta atualmente Terminal e formatos JSON, desenhado para ser extensível.

- 🔧 **Arquitetura Modular** - Adicione funcionalidades simplesmente colocando scripts na pasta de módulos.

- 📦 **Compatível com XDG** - Respeita a hierarquia de diretórios do sistema (`~/.config`, `~/.local/share`, etc.) para manter a sua HOME limpa.

- ⚡ **Sistema de Ações** - Suporte nativo para eventos de clique, scroll e comandos de fundo (como controlar `mpv` ou serviços).

- 🎯 **Bash Puro** - Sem sobrecarga, execução rápida e extremamente fácil de personalizar.

---

## 📋 Requisitos

- **Bash 4.0+**

- **jq:** Processador JSON essencial para a comunicação e configuração dos módulos.

- **GNU Make (Opcional):** Para facilitar a gestão de instalação/desinstalação.

- **Nerd Fonts (Opcional):** Para suporte de ícones estendido nos widgets.

| Distribuição        | Comando de Instalação         |
| ------------------- | ----------------------------- |
| **openSUSE**        | `sudo zypper install jq make` |
| **Arch Linux**      | `sudo pacman -S jq make`      |
| **Debian / Ubuntu** | `sudo apt install jq make`    |
| **Fedora**          | `sudo dnf install jq make`    |

Se usar `icon_style=nerd-fonts` em `~/.config/auraconfig/.env`, instale apenas os símbolos (sem alterar a sua fonte atual) com este comando:

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

#### 🚀 Instalação e Gestão (Sem Root)

O AuraConfig instala-se inteiramente no espaço do utilizador. **Não são necessários privilégios de sudo** para a instalação do framework.

###### Opção A: Usando `make` (Recomendado)

O **Makefile** centraliza a lógica invocando os scripts de sistema para evitar duplicidade:

```bash
make install      # Instalar AuraConfig

make uninstall    # Desinstalar AuraConfig
```

###### Opción B: Directamente con Bash

Se não tiver o `make` ou preferir executar os scripts diretamente:

```bash
# Instalar
chmod +x scripts/*.sh
bash scripts/install.sh

# Desinstalar
chmod +x scripts/*.sh
bash scripts/uninstall.sh
```

### Caminhos de Instalação (compatível com XDG)

```
~/.local/bin/aura                 # Executável
~/.local/lib/auraconfig/          # Bibliotecas
~/.local/share/auraconfig/        # Dados (módulos, traduções)
~/.config/auraconfig/             # Configuração
~/.cache/auraconfig/              # Cache
```

---

## 🖥️ Compatibilidade de Painéis

| Interface         | Estado                 | Tipo de Saída           |
| ----------------- | ---------------------- | ----------------------- |
| **Terminal**      | ✅ Nativo               | Texto plano formatado   |
| **Waybar**        | ✅ Nativo               | JSON estruturado        |
| **Polybar / DWM** | 🛠️ Em desenvolvimento | Texto plano (planejado) |

---

## ⚙️ Configuração

O AuraConfig é configurado através de `~/.config/auraconfig/.env`:

```bash
# Idioma (auto|en|es|pt)
lang=auto

# Estilo de ícones (emoji|nerd-fonts|ascii)
icon_style=emoji

# Mostrar ícones no terminal (true|false)
show_icons=true

# Intervalo de atualização (segundos)
update_interval=10
```

---

## 📦 Exemplo: Módulo Hello World

Um módulo funcional integra-se através de três componentes básicos:

1. **Metadados** (`module.json`) - Define nome, versão e definições base

2. **Lógica** (`helloworld.sh`) - Função para processar dados e funções de ação

3. **Tradução** (`lang/pt.lex`) - Dicionário chave-valor para Lexis

### Uso:

```bash
# Ver o widget no terminal
aura helloworld
```

### Output esperado:

```bash
$ aura helloworld
[✓] 👋 Hello, Mundo!
Este é um módulo de exemplo simples
```

---

## 📁 Estrutura do Projeto

```
auraconfig/
├── bin/
│   └── auraconfig               # Executável principal
├── lib/                         # Bibliotecas core
│   ├── lexis.sh                # Motor i18n
│   ├── i18n.sh                 # Sistema de idiomas
│   ├── env.sh                  # Carregador de configuração
│   ├── log.sh                  # Sistema de logging
│   ├── modules.sh              # Gestor de módulos
│   ├── output.sh               # Renderização de saída
│   └── help.sh                 # Sistema de ajuda
├── share/
│   ├── VERSION
│   ├── lang/                   # Traduções core
│   │   ├── en.lex, es.lex, pt.lex
│   │   └── help/               # Ficheiros de ajuda
│   └── modules/                # Módulos incluídos
│       └── helloworld/
│           ├── module.json
│           ├── helloworld.sh
│           └── lang/
│               ├── en.lex
│               ├── es.lex
│               └── pt.lex
├── scripts/                    # Scripts de instalação
│   ├── common.sh               # Funções partilhadas
│   ├── install.sh              # Script de instalação
│   └── uninstall.sh            # Script de desinstalação
├── Makefile
├── .env.example                # Modelo de configuração
└── README.md
```

---

## 🗺️ Roadmap

- [x] **Core** - Sistema de módulos e motor de renderização base

- [x] **i18n** - Integração completa com o motor Lexis

- [ ] **Novas Saídas** - Suporte nativo para Polybar, DWM, Lemonbar

- [ ] **Biblioteca de Módulos** - Widgets oficiais (CPU, Memória, Rede, Bateria)

---

#### 🤝 Contribuir

As contribuições são bem-vindas. Por favor, abra um issue ou pull request.

---

## 📝 Licença

Licença MIT. Consulte o ficheiro [LICENSE](https://www.google.com/search?q=LICENSE) para mais detalhes.

---

**Feito com ⚙️ e ❤️ por [Edgar Masagué](https://github.com/edgarmasague)**