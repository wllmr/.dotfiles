# Dotfiles — Arch Linux, Ubuntu, macOS

One portable Zsh setup with **Starship**, completions, autosuggestions, syntax highlighting, SCM Breeze, fzf, zoxide, eza, bat, GitHub CLI and wget. Existing Git author/editor/rebase settings are retained.

## Install

Install Git on your system and Homebrew on macOS (https://brew.sh), then:

```bash
git clone https://github.com/wllmr/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash install.sh
```

The installer uses `pacman` on Arch, `apt` on Ubuntu and `brew` on macOS. It installs Zsh, completions, autosuggestions, syntax highlighting, `gh`, SCM Breeze, fzf, Starship, eza, bat, zoxide, wget, Git, Vim, Ruby and curl. On Ubuntu, unavailable optional packages are reported and skipped; availability depends on the Ubuntu version and enabled repositories. Starship is installed from its official script if missing.

The installer backs up existing files before symlinking `~/.zshrc`, `~/.zsh_aliases`, `~/.gitconfig`, and `~/.config/starship.toml`. It sets Zsh as the non-root user's login shell using `usermod` (Linux) or `chsh` (macOS). It may prompt for sudo/password. The SCM Breeze upstream installer may prompt. Rerunning the installer is safe.

Restart your terminal afterwards; with WSL, terminate the distribution from Windows PowerShell to start a fresh session.

## Check installation

```sh
getent passwd "$USER" | cut -d: -f7  # Linux only; on macOS use: echo "$SHELL"
zsh --version
starship --version
gh --version
fzf --version
wget --version
```

Authenticate GitHub CLI using `gh auth login`. Authentication, SSH keys, and credentials are not committed.

Starship is the **only** prompt; Powerlevel10k and Oh My Zsh are not required. For glyphs, set a Nerd Font in Windows Terminal or your macOS terminal.

## Updating

```sh
cd ~/.dotfiles
git pull --ff-only
bash install.sh
```
