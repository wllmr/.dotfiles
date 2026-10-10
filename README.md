# Dotfiles

Portable Zsh configuration for Arch Linux (including WSL) and Ubuntu/Codespaces.

## Features

- **Oh My Zsh + Powerlevel10k:** prompt theme, with existing `.p10k.zsh` settings preserved
- **fzf:** Ctrl+R history search, Ctrl+T file search, Alt+C directory navigation (where supported)
- **zoxide:** `z project` / `zi` for directory jumping
- **eza:** `ls`, `ll`, `tree` aliases
- **bat:** `cat` alias, with `command cat` available for original behavior
- Git, zsh-autosuggestions and zsh-completions Oh My Zsh plugins

## Setup

```bash
git clone https://github.com/wllmr/.dotfiles.git ~/.dotfiles
bash ~/.dotfiles/install.sh
exec zsh
```

The installer uses pacman on Arch or apt on Ubuntu and symlinks only the managed dotfiles. Existing regular files are backed up. On older Ubuntu distributions, eza and zoxide may need to be installed separately if unavailable in apt.

Install a Nerd Font (such as **MesloLGS NF**) in your **Windows Terminal host** when using WSL, then select it under the Arch profile's Appearance settings.

Run `p10k configure` to change the prompt. The tracked `.p10k.zsh` is shared across machines; commit changes if you'd like to synchronize them.

If Zsh is not your login shell, change it separately using `chsh -s "$(command -v zsh)"` (WSL may also need default-user configuration).

## Notes

- Starship is deliberately not initialized; Powerlevel10k owns the prompt.
- Missing optional utilities are skipped by `.zshrc` rather than causing startup errors.
- System locale is left unchanged to avoid errors when `sv_SE.UTF-8` has not been generated.
