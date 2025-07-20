# ~/.zshrc gọn nhẹ mà vẫn đẹp

# Starship prompt
eval "$(starship init zsh)"

# Lịch sử lệnh
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000

# Gợi ý và highlight
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Alias hay dùng
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Export bổ sung nếu cần
[ -f ~/.profile ] && source ~/.profile
