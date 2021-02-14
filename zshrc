# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

DOT_REPO="https://github.com/jheyse/dotfiles.git"
DOT_DIR="$HOME/.dotfiles"

secretive="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent"
if [ -d "$secretive" ]; then
  export SSH_AUTH_SOCK=$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
fi

SOCK="/tmp/ssh-agent-$USER-screen"
if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]
then
    rm -f /tmp/ssh-agent-$USER-screen
    ln -sf $SSH_AUTH_SOCK $SOCK
    export SSH_AUTH_SOCK=$SOCK
fi

export PATH="$HOME/.jenv/bin:$PATH"
export PATH="$HOME/miniconda3/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.cargo/env:$PATH"
export PATH="/usr/local/opt/awscli@1/bin:$PATH"
export PATH="/usr/local/Cellar/gcc/10.2.0_3/bin:$PATH"
export PATH="/usr/local/Cellar/llvm/11.0.1/bin:$PATH"

if command -v brew &> /dev/null; then
  export PATH=$(brew --prefix llvm)/bin:$PATH
fi

[[ $- != *i* ]] && return

if [[ $(pwd) == /mnt/c/* ]]; then
  cd ~
fi
# Use the VIM-like keybindings
bindkey -v

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/jheyse/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/jheyse/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/jheyse/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/jheyse/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<
#

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Keybindings for substring search plugin. Maps up and down arrows.
bindkey -M main '^[OA' history-substring-search-up
bindkey -M main '^[OB' history-substring-search-down
bindkey -M main '^[[A' history-substring-search-up
bindkey -M main '^[[B' history-substring-search-up

# Keybindings for autosuggestions plugin
bindkey '^ ' autosuggest-accept
bindkey '^f' autosuggest-accept

# Gray color for autosuggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=247'

# fzf settings. Uses sharkdp/fd for a faster alternative to `find`.
FZF_CTRL_T_COMMAND='fd --type f --hidden --exclude .git --exclude .cache'
FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'

if [[ ! -d ~/.zplug ]];then
    git clone https://github.com/b4b4r07/zplug ~/.zplug
fi

# Load Plugins
source ~/.zplug/init.zsh
zplug "zpm-zsh/colors"
zplug "romkatv/powerlevel10k", as:theme, depth:1

zplug "zpm-zsh/autoenv"
zplug "junegunn/fzf", use:"shell/*.zsh"
zplug "zpm-zsh/ls"
zplug "zpm-zsh/ssh"
zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "ssh0/dot", use:"*.sh"

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "nnao45/zsh-kubectl-completion"
zplug "greymd/docker-zsh-completion"

case `uname` in
  Darwin)
    export SSH_AUTH_SOCK=/Users/josh/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
  ;;
  Linux)
    zplug "bobsoppe/zsh-ssh-agent", use:ssh-agent.zsh, from:github
  ;;
esac

autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws


# Aliases
alias la='ls -la'
alias l=ll
alias la=l -a


alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gc='git commit -m '
alias gca='git commit -a -m '
alias gpd='git pull'
alias gpu='git push'

# Actually install plugins, prompt user input
if ! zplug check --verbose; then
    printf "Install zplug plugins? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

zplug load

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet


export EDITOR=vim
