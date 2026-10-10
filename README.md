# Dotfiles

Shared **Zsh + Starship** development environment for Arch Linux (including WSL2), Ubuntu (including Codespaces), Kali Linux, and macOS.

## Structure

```text
.dotfiles/
├── install.sh
├── installers/
│   ├── arch.sh
│   ├── ubuntu.sh
│   ├── kali.sh
│   ├── macos.sh
│   ├── ai-tools.sh
│   └── common.sh
├── zsh/
│   ├── .zshrc
│   └── .zsh_aliases
├── git/
│   └── .gitconfig
├── vim/
│   ├── .vimrc
│   └── colors/oxocarbon.vim
└── starship/
    └── starship.toml
```

## Install

Install Git first, plus Homebrew on macOS (https://brew.sh). Then:

```bash
git clone https://github.com/wllmr/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash install.sh
```

The entry point detects the OS and invokes the matching installer. All platforms receive Zsh, zsh-completions, autosuggestions, syntax highlighting, GitHub CLI, SCM Breeze, fzf, Starship, eza, bat, zoxide, ripgrep, fd, jq, Mike Farah's yq v4, wget, Git, Vim, Ruby, curl, plus Rust (rustup, Cargo and stable rustc) where available.

- Arch: `pacman` (`go-yq` supplies Mike Farah's yq).
- Kali: `apt` for ripgrep/jq and optional fd-find; the official Go yq binary installs into `~/.local/bin`.
- Ubuntu: `apt` for ripgrep/jq and optional fd-find; the official Go yq binary installs into `~/.local/bin`. Optional tools unavailable in the configured repositories produce warnings. Starship uses the official installer as a fallback.
- macOS: `brew` (including `yq`). Homebrew must already be installed.

Common setup symlinks `~/.zshrc`, `~/.zsh_aliases`, `~/.vimrc`, `~/.vim/colors/oxocarbon.vim` and `~/.config/starship.toml`, backing up existing files before replacing them. Git configuration is copied once into `~/.gitconfig` rather than symlinked so `gh auth setup-git` and `git config --global` do not modify tracked repository files. An existing regular Git config is retained; a prior symlink is replaced with an independent copy preserving its effective contents. It installs SCM Breeze if missing. Rust is installed through the official rustup installer and managed consistently across all four OSes; Linux installs build tools for linking. The OS script sets Zsh as the non-root user's default login shell.

The installer can be rerun without duplicating symlinks. SCM Breeze may prompt during its initial installation. Changing the default shell can request your password/sudo access.

## Optional developer tools

After base packages are installed, an `fzf` multi-select menu lets you select Docker, Codex CLI, and Claude Code independently with **Tab** and confirm with **Enter** (or **Esc** to skip). None are installed by default in non-interactive sessions.

```bash
./install.sh --with-codex --with-claude
./install.sh --with-docker --with-codex
```

**Codex:** installed into the user-local `~/.local` npm prefix from `@openai/codex` (npm is required). If npm is unavailable the installer logs a warning, rather than changing the system Node.js setup.

**Claude Code:** installed with Anthropic's native `https://claude.ai/install.sh` installer. This is an optional external installer; review the source before running it in a security-restricted environment.

Neither installation stores credentials in this repository. Authenticate manually by running `codex` or `claude` after installation.

## Vim theme

The Oxocarbon reference theme targets Neovim only. This repository includes a native Vim colorscheme based on the official [Oxocarbon Base16 dark palette](https://github.com/nyoom-engineering/base16-oxocarbon), so the existing `vim` command works without Neovim or a plugin manager. Open Vim and run `:colorscheme` to verify `oxocarbon` is active. This is a Vim-compatible adaptation, not the original Neovim renderer.

## CLI tools

`rg` searches files, `fd` finds files, `jq` processes JSON, and `yq` v4 processes YAML. On Ubuntu/Kali, the `fd-find` executable is often named `fdfind`; shared setup links `~/.local/bin/fd` to that executable. The Go-based `yq` is used consistently instead of the differently implemented Debian `yq` package. If optional packages are unavailable, installation logs a warning.

## Optional Docker (no Docker Desktop)

Run `./install.sh` interactively and select Docker in the `fzf` menu, or specify `./install.sh --with-docker`. Docker is off by default for non-interactive installs (or use `--no-docker`).

- **Arch Linux / native Linux**: installs `docker` and Compose packages. The local daemon is not automatically enabled or started. On a systemd installation, use `sudo systemctl enable --now docker` when you want to enable it.
- **Ubuntu / Kali**: installs `docker.io` and `docker-compose-v2` when available in configured apt repositories. On native Linux with systemd, use `sudo systemctl enable --now docker` if the daemon is not running.
- **WSL2**: Docker Desktop is **not required or used**. Run a Linux Docker Engine inside your WSL distribution. WSL systemd must be enabled for `systemctl` commands to work: add `[boot]` followed by `systemd=true` to `/etc/wsl.conf`, restart the distro with `wsl --shutdown` from Windows PowerShell, then `sudo systemctl enable --now docker`. Check `ps -p 1 -o comm=` to verify systemd. WSL daemon operation also depends on kernel capabilities/network configuration.
- **macOS**: installs `docker`, `docker-compose`, and **Colima**, a Docker-compatible VM backend. Start it with `colima start`; stop it with `colima stop`. No Docker Desktop installation is involved.

The installer does **not** add your account to the `docker` group or automatically start a daemon. Membership of the Linux `docker` group permits root-equivalent access to the host, so use `sudo docker ...` or explicitly configure permissions after reviewing the risk.

`wget` is always installed on all four platforms.

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
# When Docker is selected and an engine is running:
docker --version
docker compose version
docker info
# If the optional AI tools were installed:
codex --version
claude --version
```

Authenticate separately with `gh auth login`. Never commit credentials or SSH private keys. Starship is the only prompt: no Oh My Zsh or Powerlevel10k required.

For WSL, terminate and reopen your distribution from Windows PowerShell after installation. For terminal glyphs, use a Nerd Font in your terminal settings.

## Update

```bash
cd ~/.dotfiles
git pull --ff-only
bash install.sh
```
