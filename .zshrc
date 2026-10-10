# Powerlevel10k instant prompt must load before other shell initialization.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export EDITOR=vim

# Avoid forcing a locale that may not be generated on the current machine.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-completions)

if [[ -f "$ZSH/oh-my-zsh.sh" ]]; then
  source "$ZSH/oh-my-zsh.sh"
elif [[ -f "$HOME/.powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  # Standalone installation when Oh My Zsh isn't installed.
  source "$HOME/.powerlevel10k/powerlevel10k.zsh-theme"
fi

# fzf's modern shell integration (Ctrl+R, Ctrl+T, Alt+C).
if (( $+commands[fzf] )); then
  if fzf --help 2>/dev/null | grep -q -- '--zsh'; then
    source <(fzf --zsh)
  elif [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
    [[ -f /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
  fi
fi

(( $+commands[zoxide] )) && eval "$(zoxide init zsh)"
[[ -f "$HOME/.zsh_aliases" ]] && source "$HOME/.zsh_aliases"

# Load user-customized Powerlevel10k configuration last.
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"
