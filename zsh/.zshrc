typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
# --- Powerlevel10k instant prompt (must stay at the very top) ---
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"
# Path for srcipts
export PATH="$HOME/scripts:$PATH"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Syntax highlighting plugin
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Preferred editor
export EDITOR='nvim'

# Path
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias gaa='git add .'
alias gc='git commit -m'
alias bwunlock='export BW_SESSION=$(bw unlock --raw) && echo "✅ Vault unlocked and session set"'
# Prompt fix for WSL or headless servers
export DISABLE_AUTO_TITLE="true"
export DEFAULT_USER=$USER

# --- Load Powerlevel10k theme config ---
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

if command -v fastfetch >/dev/null 2>&1; then
  fastfetch
fi
