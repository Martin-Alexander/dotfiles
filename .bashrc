# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

function git-status-count {
  git rev-parse --git-dir >/dev/null 2>&1 || return

  local files_changed=0 lines_added=0 lines_deleted=0

  while IFS=$'\t' read -r add del file; do
    [[ $add =~ ^[0-9]+$ ]] && ((lines_added += add))
    [[ $del =~ ^[0-9]+$ ]] && ((lines_deleted += del))
  done < <(git diff --numstat 2>/dev/null)

  while IFS=$'\t' read -r add del file; do
    [[ $add =~ ^[0-9]+$ ]] && ((lines_added += add))
    [[ $del =~ ^[0-9]+$ ]] && ((lines_deleted += del))
  done < <(git diff --numstat --cached 2>/dev/null)

  while IFS= read -r file; do
    [[ -f "$file" ]] && {
      local lines
      lines=$(wc -l < "$file" 2>/dev/null) && [[ $lines =~ ^[0-9]+$ ]] && ((lines_added += lines))
    }
  done < <(git ls-files --others --exclude-standard 2>/dev/null)

  files_changed=$(git status -s | wc -l)

  local output=""
  (( files_changed > 0 )) && output+="$(tput setaf 7)${files_changed}$(tput sgr0) "
  (( lines_added > 0 )) && output+="$(tput setaf 2)+${lines_added}$(tput sgr0) "
  (( lines_deleted > 0 )) && output+="$(tput setaf 1)-${lines_deleted}$(tput sgr0)"

  echo "${output% }"
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\o33[36m\1\o33[0m) $(git-status-count)/"
}

PS1='\[\033[0;35m\]\w\[\033[0m\] $(parse_git_branch)\n$(if [ $? -eq 0 ]; then echo "\[\033[0;32m\]"; else echo "\[\033[0;31m\]"; fi)$\[\033[0m\] '

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PATH=$PATH:/usr/local/go/bin

if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
  . /etc/bash_completion
fi

bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
bind '"\e[1;5A":history-search-backward'
bind '"\e[1;5B":history-search-forward'

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
