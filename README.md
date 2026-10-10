# Dotfiles

Shared **Zsh + Starship** development environment for Arch Linux (including WSL2), Ubuntu (including Codespaces), Kali Linux, and macOS.

## Structure

```text
.dotfiles/
├── install.sh                  # OS detection and orchestration
├── installers/
│   ├── arch.sh                 # pacman + Linux default shell
│   ├── kali.sh                 # Kali packages + default shell
│   ├── ubuntu.sh               # apt + Starship fallback + default shell
│   ├── macos.sh                # Homebrew + macOS default shell
│   └── common.sh               # backups, symlinks, SCM Breeze
├── .zshrc                      # shared Zsh configuration
├── .zsh_aliases                # eza and bat convenience aliases
├── .gitconfig                  # shared Git identity and behavior
└── starship.toml               # shared prompt
```

## Install

Install Git first, plus Homebrew on macOS (https://brew.sh). Then:

```bash
git clone https://github.com/wllmr/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash install.sh
```

The entry point detects the OS and invokes the matching installer. All platforms receive Zsh, zsh-completions, autosuggestions, syntax highlighting, GitHub CLI, SCM Breeze, fzf, Starship, eza, bat, zoxide, wget, Git, Vim, Ruby, curl, plus Rust (rustup, Cargo and stable rustc) where available.

- Arch: `pacman`.
- Kali: `apt`, with its own installer and package availability checks.
- Ubuntu: `apt`. Optional tools unavailable in the configured repositories produce warnings. Starship uses the official installer as a fallback.
- macOS: `brew`. Homebrew must already be installed.

Common setup symlinks `~/.zshrc`, `~/.zsh_aliases`, `~/.gitconfig` and `~/.config/starship.toml`, backing up existing files before replacing them. It installs SCM Breeze if missing. Rust is installed through the official rustup installer and managed consistently across all four OSes; Linux installs build tools for linking. The OS script sets Zsh as the non-root user's default login shell.

The installer can be rerun without duplicating symlinks. SCM Breeze may prompt during its initial installation. Changing the default shell can request your password/sudo access.

## Verify

```bash
zsh --version
starship --version
gh --version
fzf --version
wget --version
rustc --version
cargo --version
```

Authenticate separately with `gh auth login`. Never commit credentials or SSH private keys. Starship is the only prompt: no Oh My Zsh or Powerlevel10k required.

For WSL, terminate and reopen your distribution from Windows PowerShell after installation. For terminal glyphs, use a Nerd Font in your terminal settings.

## Update

```bash
cd ~/.dotfiles
git pull --ff-only
bash install.sh
```
