# Dotfiles

Cross-platform Zsh development environment for **Arch Linux / WSL**, **Ubuntu / Codespaces**, and **macOS**.

## Install

Install Git first, then clone this repository to `~/.dotfiles`:

```sh
git clone https://github.com/wllmr/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
bash install.sh
```

Includes Zsh, Zsh completions, autosuggestions, syntax highlighting, GitHub CLI, SCM Breeze, fzf, Starship, eza, bat, zoxide, wget, Git, Vim and Ruby.

- Arch uses pacman; Ubuntu uses apt plus the official Starship installer; macOS uses Homebrew (install Homebrew first).
- Backs up existing dotfiles and symlinks `.zshrc`, `.gitconfig`, and `starship.toml`.
- Does not change the login shell automatically. Run `chsh -s "$(command -v zsh)"`.
- SCM Breeze's upstream installer may ask interactive questions.
- Run `gh auth login` separately. Never commit credentials.
- On older Ubuntu releases, `eza`, `zoxide`, or `gh` might not be available from default apt repositories.
- On WSL, use Windows VS Code with the WSL extension.
