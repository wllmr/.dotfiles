# Portable Zsh settings for Arch Linux, Ubuntu, Kali and macOS.
# Swedish regional formats and UTF-8, with English command messages.
# LC_ALL would override the individual settings, including LC_MESSAGES.
unset LC_ALL
export LANG=sv_SE.UTF-8
export LC_CTYPE=sv_SE.UTF-8
export LC_MESSAGES=C
export LANGUAGE=en

# Homebrew environment is needed on Apple Silicon and Intel macOS.
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
export PATH="$HOME/.cargo/bin:$HOME/.local/bin:$PATH"
# nvm is a shell function; initialize it for interactive Zsh sessions.
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
export EDITOR=vim
export VISUAL=vim
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt APPEND_HISTORY HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS
setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS
bindkey -e

# Configure completion before the first completion initialization.
if (( $+commands[brew] || $+functions[brew] )); then
  completion_dir="$(brew --prefix)/share/zsh-completions"
  [[ ! -d "$completion_dir" ]] || fpath=("$completion_dir" $fpath)
  unset completion_dir
fi
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

[[ -r "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"

# Standard Git shortcuts come from a pinned Oh My Zsh Git plugin.
# Starship owns the prompt, so the Git library's async prompt is disabled.
git_plugin_dir="$HOME/.local/share/dotfiles/oh-my-zsh/current"
if [[ -s "$git_plugin_dir/plugins/git/git.plugin.zsh" &&
      -s "$git_plugin_dir/lib/git.zsh" && -s "$git_plugin_dir/lib/clipboard.zsh" ]]; then
  zstyle ':omz:alpha:lib:git' async-prompt no
  source "$git_plugin_dir/lib/git.zsh"
  source "$git_plugin_dir/lib/clipboard.zsh"
  source "$git_plugin_dir/plugins/git/git.plugin.zsh"
else
  print -u2 'Git shortcuts are not installed. Run bash install.sh from your dotfiles repository.'
fi
unset git_plugin_dir

# SCM Breeze adds numbered file helpers; managed settings disable standard aliases.
[[ -s "$HOME/.scm_breeze/scm_breeze.sh" ]] && source "$HOME/.scm_breeze/scm_breeze.sh"

if (( $+commands[fzf] )); then
  if fzf_init=$(fzf --zsh 2>/dev/null); then
    eval "$fzf_init"
  else
    for fzf_dir in /usr/share/fzf /usr/share/doc/fzf/examples; do
      if [[ -r "$fzf_dir/key-bindings.zsh" ]]; then
        source "$fzf_dir/key-bindings.zsh"
        [[ ! -r "$fzf_dir/completion.zsh" ]] || source "$fzf_dir/completion.zsh"
        break
      fi
    done
  fi
  unset fzf_init fzf_dir
fi
(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
(( $+commands[starship] )) && eval "$(starship init zsh)"

# Autosuggestions before syntax highlighting; highlighting must be loaded last.
for file in \
  /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh \
  /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh; do
  if [[ -r "$file" ]]; then source "$file"; break; fi
done
for file in \
  /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
  /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh; do
  if [[ -r "$file" ]]; then source "$file"; break; fi
done
