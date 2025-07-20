# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="agnoster"

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Enable syntax highlighting
source $ZSH/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable autosuggestions
source $ZSH/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Preferred editor
export EDITOR='nvim'

# Add your custom paths here
export PATH="$HOME/bin:/usr/local/bin:$PATH"

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Git aliases
alias gst='git status'
alias gl='git pull'
alias gp='git push'
alias gaa='git add .'
alias gc='git commit -m'

# Prompt fix for WSL or headless servers
export DISABLE_AUTO_TITLE="true"

# Highlight current directory
export DEFAULT_USER=$USER
