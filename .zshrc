HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_VERIFY

autoload -Uz compinit
compinit

alias ll='ls -alFG'
alias la='ls -Al'

function git_status_count {
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
      lines=$(wc -l < "$file" | tr -d " " 2>/dev/null) && [[ $lines =~ ^[0-9]+$ ]] && ((lines_added += lines))
    }
  done < <(git ls-files --others --exclude-standard 2>/dev/null)

  files_changed=$(git status -s | wc -l | tr -d " ")

  local output=""
  (( files_changed > 0 )) && output+="$(tput setaf 7)${files_changed}$(tput sgr0) "
  (( lines_added > 0 )) && output+="$(tput setaf 2)+${lines_added}$(tput sgr0) "
  (( lines_deleted > 0 )) && output+="$(tput setaf 1)-${lines_deleted}$(tput sgr0)"

  echo "${output% }"
}

function parse_git_branch {
  git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e "s/* \(.*\)/(\x1B[36m\1\x1B[0m) $(git_status_count)/"
}


setopt PROMPT_SUBST
PS1='%F{magenta}%~%f $(parse_git_branch)
%(?.%F{green}.%F{red})$%f '

export PATH="$PATH:$HOME/.rvm/bin"
