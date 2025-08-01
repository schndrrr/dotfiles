# 🏠 Personal Dotfiles

A comprehensive collection of my personal development environment configuration files, designed for macOS with a focus on productivity and modern development workflows.

## ✨ What's Included

### 🚀 Core Components
- **Neovim Configuration** - Modern Vim setup with LSP, completion, and productivity plugins
- **Tmux Configuration** - Terminal multiplexer with custom keybindings and plugins
- **Zsh Configuration** - Enhanced shell with Powerlevel10k theme and useful aliases
- **Powerlevel10k Theme** - Beautiful and informative prompt
- **Git Configuration** - Global gitignore and settings
- **Development Scripts** - Utility scripts for enhanced workflow

### 🛠️ Development Environment Features

#### Neovim Setup
- **Plugin Manager**: Lazy.nvim for fast plugin loading
- **LSP Support**: Full Language Server Protocol integration
- **Completion**: nvim-cmp with multiple sources
- **File Navigation**: Telescope for fuzzy finding
- **Code Folding**: UFO plugin with treesitter integration
- **Git Integration**: Git blame, diff, and status indicators
- **AI Assistance**: CodeCompanion plugin integration
- **Theme**: Catppuccin color scheme
- **Quality of Life**: Auto-pairs, comments, marks, hardtime for habit building

#### Tmux Configuration
- **Custom Prefix**: `Ctrl+s` instead of default `Ctrl+b`
- **Vim-style Navigation**: `h/j/k/l` for pane movement
- **Theme**: Catppuccin Mocha with custom status bar
- **Session Management**: Integrated with `sesh` for smart session handling
- **Plugins**: TPM, vim-tmux-navigator, tmux-resurrect, weather info
- **Quick Access**: Cheat sheet integration with `tmux-cht.sh`
- **Popup Terminal**: Quick terminal access with `Ctrl+g`

#### Zsh Configuration
- **Theme**: Powerlevel10k with lean prompt style
- **Package Managers**: Node (nvm), Python (pyenv, conda), Ruby (rvm)
- **Development Tools**: Docker, AWS, Flutter, Go, Java, .NET
- **Enhanced Tools**: 
  - `fzf` for fuzzy finding
  - `thefuck` for command correction
  - `bat` for syntax highlighting
  - `carapace` for completions
- **Useful Aliases**:
  - `inv`: Interactive file opener with Neovim + fzf preview
  - `gco`: Interactive git branch switcher with fzf
  - `weather`: Get weather for Dresden
  - `ll`: Detailed file listing
  - `gs`: Git status shorthand
  - Many more productivity aliases

### 📁 Project Structure
```
.
├── .config/
│   ├── nvim/                 # Neovim configuration
│   │   ├── init.lua         # Main config file
│   │   └── lua/plugins/     # Plugin configurations
│   └── git/ignore           # Global gitignore
├── scripts/
│   └── tmux-cht.sh         # Tmux cheat sheet integration
├── .zshrc                   # Zsh configuration
├── .tmux.conf              # Tmux configuration
├── .p10k.zsh               # Powerlevel10k theme config
└── .gitignore              # Files to ignore in this repo
```

## 🚀 Installation

### Prerequisites
- macOS (tested on recent versions)
- [Homebrew](https://brew.sh/) package manager
- [Stow](https://www.gnu.org/software/stow/) for symlink management

### Required Tools Installation
```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install stow git neovim tmux zsh fzf bat
brew install --cask font-fira-code-nerd-font  # For proper icons

# Install additional tools
brew install zsh-autosuggestions zsh-syntax-highlighting powerlevel10k
brew install nvm pyenv thefuck carapace
```

### Dotfiles Setup
1. **Clone the repository:**
   ```bash
   git clone <your-repo-url> ~/dotfiles
   cd ~/dotfiles
   ```

2. **Install dotfiles using Stow:**
   ```bash
   stow .
   ```
   > **Note**: Stow creates symlinks from the dotfiles directory to your home directory

3. **Handle conflicts (if any):**
   ```bash
   stow --adopt .
   ```
   > **Warning**: `--adopt` moves existing files into the dotfiles directory, potentially overwriting your configs

### Post-Installation Setup

1. **Set Zsh as default shell:**
   ```bash
   chsh -s $(which zsh)
   ```

2. **Install Tmux Plugin Manager:**
   ```bash
   git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
   ```
   Then in tmux: `Ctrl+s + I` to install plugins

3. **Configure Powerlevel10k:**
   ```bash
   p10k configure
   ```

4. **Install Neovim plugins:**
   Open Neovim and plugins will auto-install via Lazy.nvim

## 🎯 Key Features & Shortcuts

### Tmux
- **Prefix**: `Ctrl+s`
- **Pane Navigation**: `Prefix + h/j/k/l`
- **Session Manager**: `Prefix + w` (opens fzf session selector)
- **Popup Terminal**: `Prefix + g`
- **Cheat Sheet**: `Prefix + i`
- **Reload Config**: `Prefix + r`

### Neovim
- **Leader Key**: `Space`
- **File Explorer**: `<Leader>e`
- **Code Actions**: `<Leader>Z` (CodeCompanion)
- **Switch Buffer**: `<Leader>r`
- **Fuzzy Find**: Built-in Telescope integration
- **Fold Toggle**: `zR` (open all), `zM` (close all)

### Zsh
- **Interactive File Open**: `inv` (neovim + fzf + bat preview)
- **Git Branch Switch**: `gco` (fzf branch selector)
- **Weather**: `weather` (Dresden weather)
- **Command Correction**: Type `fuck` after wrong command

## 🔧 Customization

The configuration is modular and easy to customize:

- **Neovim**: Edit files in `.config/nvim/lua/plugins/`
- **Tmux**: Modify `.tmux.conf`
- **Zsh**: Update `.zshrc` or `.zshrc_local` for local overrides
- **Theme**: Run `p10k configure` to reconfigure prompt

## 🎨 Theme Information

- **Overall Theme**: Catppuccin Mocha (consistent across Neovim, Tmux)
- **Terminal Font**: Recommended - Fira Code Nerd Font
- **Prompt**: Powerlevel10k lean style with custom segments

## 📝 Local Customizations

Create `.zshrc_local` in your home directory for machine-specific configurations that won't be tracked by git.

## 🤝 Contributing

Feel free to fork this repository and adapt it to your needs. If you find improvements or fixes, pull requests are welcome!

## 📜 License

This project is open source and available under your preferred license.

---

*Happy coding! 🚀*
