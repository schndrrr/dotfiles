# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

ZSH_THEME="powerlevel10k/powerlevel10k"
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

source <(fzf --zsh)

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source /Users/johann.schneider/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export NVM_DIR="$HOME/.nvm" 
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
autoload -Uz compinit && compinit


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$PATH:/Users/johann.schneider/Applications/Flutter/flutter/bin"

export ANDROID_HOME="/Users/johann.schneider/Library/Android/sdk"

alias ..='cd ..'
alias weather='curl https://wttr.in/Dresden'
alias whatsmyip='curl ipecho.net/plain ; echo'
alias gs='git status'
alias nq='networkQuality'
alias gcn='git checkout -b'
alias gcom='git commit -m'
alias ccr='npm run clean && clear && npm start'
alias 'ssh?'='history | grep "ssh " | grep @ | grep -v "history"'
alias ll='ls -lisahG'
alias ns='nvm use'
alias gp='git push'
alias uio='npm start'
alias inv='nvim $(fzf -m --preview="bat --color=always {}")'
alias gpo='git push --set-upstream origin'
alias python=python3

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

eval $(thefuck --alias)

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/johann.schneider/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/johann.schneider/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/johann.schneider/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/johann.schneider/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

if [ -f ~/.zshrc_local ]; then
  source ~/.zshrc_local
fi

# Created by `pipx` on 2025-02-28 10:06:48
export PATH="$PATH:/Users/johann.schneider/.local/bin"
