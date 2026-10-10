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
├── .vimrc                      # Vim defaults + Oxocarbon colorscheme
├── vim/colors/oxocarbon.vim    # native Vim theme using official Base16 palette
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

The entry point detects the OS and invokes the matching installer. All platforms receive Zsh, zsh-completions, autosuggestions, syntax highlighting, GitHub CLI, SCM Breeze, fzf, Starship, eza, bat, zoxide, ripgrep, fd, jq, Mike Farah's yq v4, wget, Docker CLI/Compose, Git, Vim, Ruby, curl, plus Rust (rustup, Cargo and stable rustc) where available.

- Arch: `pacman` (`go-yq` supplies Mike Farah's yq).
- Kali: `apt` for ripgrep/jq and optional fd-find; the official Go yq binary installs into `~/.local/bin`.
- Ubuntu: `apt` for ripgrep/jq and optional fd-find; the official Go yq binary installs into `~/.local/bin`. Optional tools unavailable in the configured repositories produce warnings. Starship uses the official installer as a fallback.
- macOS: `brew` (including `yq`). Homebrew must already be installed.

Common setup symlinks `~/.zshrc`, `~/.zsh_aliases`, `~/.gitconfig`, `~/.vimrc`, `~/.vim/colors/oxocarbon.vim` and `~/.config/starship.toml`, backing up existing files before replacing them. It installs SCM Breeze if missing. Rust is installed through the official rustup installer and managed consistently across all four OSes; Linux installs build tools for linking. The OS script sets Zsh as the non-root user's default login shell.

The installer can be rerun without duplicating symlinks. SCM Breeze may prompt during its initial installation. Changing the default shell can request your password/sudo access.

## Vim theme

The Oxocarbon reference theme targets Neovim only. This repository includes a native Vim colorscheme based on the official [Oxocarbon Base16 dark palette](https://github.com/nyoom-engineering/base16-oxocarbon), so the existing `vim` command works without Neovim or a plugin manager. Open Vim and run `:colorscheme` to verify `oxocarbon` is active. This is a Vim-compatible adaptation, not the original Neovim renderer.

## CLI tools

`rg` searches files, `fd` finds files, `jq` processes JSON, and `yq` v4 processes YAML. On Ubuntu/Kali, the `fd-find` executable is often named `fdfind`; shared setup links `~/.local/bin/fd` to that executable. The Go-based `yq` is used consistently instead of the differently implemented Debian `yq` package. If optional packages are unavailable, installation logs a warning.

## Docker

Docker commands are installed on all platforms. On native Linux, the `docker` package (Arch) or `docker.io` (Ubuntu/Kali) provides the Docker Engine package, but this installer does **not** enable/start the daemon or grant users access to the Docker socket. To use Docker without sudo on native Linux, review the security implications of membership in the `docker` group (effectively root-level access), and configure the daemon separately.

**WSL2:** Use Docker Desktop WSL integration (or configure an independent WSL Docker daemon manually). Installing a CLI does not automatically provide a running engine. Docker Desktop may already expose its own CLI; avoid using two competing daemons.

**macOS:** Homebrew installs Docker CLI and Compose, but not a running Docker engine. Install Docker Desktop or another compatible engine separately and ensure Compose is discoverable by your Docker client.

`wget` was already installed for all four systems and remains included.

## Verify

```bash
zsh --version
starship --version
gh --version
fzf --version
wget --version
rustc --version
cargo --version
rg --version
fd --version
jq --version
yq --version
wget --version
docker --version
docker compose version
```

Authenticate separately with `gh auth login`. Never commit credentials or SSH private keys. Starship is the only prompt: no Oh My Zsh or Powerlevel10k required.

For WSL, terminate and reopen your distribution from Windows PowerShell after installation. For terminal glyphs, use a Nerd Font in your terminal settings.

## Update

```bash
cd ~/.dotfiles
git pull --ff-only
bash install.sh
```
