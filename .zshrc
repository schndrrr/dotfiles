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
source "$HOME/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

export NVM_DIR="$HOME/.nvm" 
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
autoload -Uz compinit && compinit


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
export PATH="$PATH:$HOME/Applications/Flutter/flutter/bin"

export ANDROID_HOME="$HOME/Library/Android/sdk"

alias ..='cd ..'
alias weather='curl https://wttr.in/Dresden'
alias whatsmyip='curl ipecho.net/plain ; echo'
alias gs='git status'
alias nq='networkQuality'
alias gcn='git checkout -b'
alias gcnh='branch-creator'
alias gcom='git commit -m'
alias ccr='npm run clean && clear && npm start'
alias ccb='npm run clean && clear && npm run build'
alias 'ssh?'='history | grep "ssh " | grep @ | grep -v "history"'
alias ll='ls -lisahG'
alias ns='nvm use'
alias gp='git push'
alias uio='npm start'
alias inv='nvim $(fzf -m --preview="bat --color=always {}")'
alias gpo='git push --set-upstream origin'
alias gco='git checkout $(git branch --all | fzf)'
alias python=python3
alias jjl='jj log --limit 10'
alias ssh='ggh'

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
export PATH="/opt/homebrew/opt/php@7.4/bin:$PATH"
export PATH="/opt/homebrew/opt/php@7.4/sbin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

eval $(thefuck --alias)

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$("$HOME/miniconda3/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "$HOME/miniconda3/etc/profile.d/conda.sh" ]; then
        . "$HOME/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="$HOME/miniconda3/bin:$PATH"
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
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.dotnet/tools"
. "$HOME/.cargo/env"

zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
source <(carapace _carapace)

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

 export PATH=$PATH:$(go env GOPATH)/bin
