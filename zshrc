# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

# If not in an interactive shell exit immediatley
[[ $- != *i* ]] && return

# WSL likes to start in the root of C, so cd to home
if [[ $(pwd) == /mnt/c/* ]]; then
  cd ~
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

DOT_REPO="https://github.com/jheyse/dotfiles.git"
DOT_DIR="$HOME/.dotfiles"

# secretive="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent"
# if [ -d "$secretive" ]; then
#   export SSH_AUTH_SOCK=$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh
# fi

# Keep the same ssh sock in remote sessions to keep ssh agent forwarding in TMUX between sessions
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  SOCK="/tmp/ssh-agent-$USER-screen"
  if test $SSH_AUTH_SOCK && [ $SSH_AUTH_SOCK != $SOCK ]
  then
      rm -f /tmp/ssh-agent-$USER-screen
      ln -sf $SSH_AUTH_SOCK $SOCK
      export SSH_AUTH_SOCK=$SOCK
  fi
else
  export GPG_TTY="$(tty)"
  export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  gpgconf --launch gpg-agent
  # gpgconf --launch gpg-agent
  # export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  # export SSH_AUTH_SOCK=$HOME/.gnupg/S.gpg-agent.ssh
  # ssh-add -l &> /dev/null
fi

export PATH="$HOME/.jenv/bin:$PATH"
export PATH="$HOME/.cargo/env:$HOME/.cargo/bin:$PATH"
export PATH="/usr/local/opt/awscli@1/bin:$PATH"
export PATH="$HOME/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotfiles/bin:$PATH"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"



if command -v brew &> /dev/null; then
  export PATH="$(brew --prefix)/bin:$(brew --prefix)/sbin:$PATH"
  export PATH=$(brew --prefix llvm)/bin:$PATH

  if [ -d "/Applications/Alacritty.app" ]; then
    export PATH="/Applications/Alacritty.app/Contents/MacOS:$PATH"
  fi
fi

# fpath+=~/.zsh_functions

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
        conda deactivate
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

if [[ ! -d ~/.zplug ]];then
    git clone https://github.com/b4b4r07/zplug ~/.zplug
fi

export ZSH_256COLOR_DEBUG="ANY"

# Load Plugins
source ~/.zplug/init.zsh
zplug "zpm-zsh/colors"
zplug "romkatv/powerlevel10k", as:theme, depth:1

if command -v fzf &> /dev/null; then
	zplug "junegunn/fzf-bin", \
			from:gh-r, \
			as:command, \
			rename-to:fzf, \
			use:"*linux*amd64*"
	zplug "junegunn/fzf", use:"shell/*.zsh", defer:2
fi

zplug "zpm-zsh/autoenv"
zplug "zpm-zsh/ls"
zplug "zpm-zsh/ssh"
zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "ssh0/dot", use:"*.sh"

zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "nnao45/zsh-kubectl-completion"
zplug "greymd/docker-zsh-completion"
zplug "agkozak/zsh-z"

autoload bashcompinit && bashcompinit
complete -C '/usr/local/bin/aws_completer' aws


# Aliases
alias la='ls -la'
alias l=ll
alias la=l -a

alias cdp='cd $(npm prefix)'
alias cdg='cd $(git rev-parse --show-toplevel)'

function cdl() {
  local cdw=$PWD
  while [ ! -f ./lerna.json ]; do
    cd ..
    if [[ "$PWD" == "$HOME" || "$PWD" == '/' ]]; then
      cd $cdw
      return 1
    fi
  done
}

alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias ga='git add .'
alias gaa='git add -A :/'
alias gc='git commit -m '
alias gca='git commit -a -m '
alias gco='git checkout'
alias gcb='git checkout -b'
alias gpd='git pull'
alias gpu='git push -u origin HEAD'
alias gpp='git pull && git push'

function title() {
  if [ -n "$TMUX" ]; then
    tmux rename-window $1
  else
    echo -e "\e]2;$1\007"
  fi
}

alias vim=nvim

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
