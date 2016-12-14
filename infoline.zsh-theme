#!/usr/bin/zsh
# infoline

# TODO cleanup "exported" variables

# desc => readme
local -a readme

# local _return_value

# color settings
# color settings embed into %{ %}
# uses spectrum from omz
# local cOk cFocus cError cNote cImportant cReset cDefault
autoload -U colors && colors
cOk="%{$fg[green]%}"
cFocus="%{$fg[yellow]%}"
# cFocus="%{$FG[214]%}"
cError="%{$fg[red]%}"
# cError="%{$FG[125]%}"
cNote="%{$fg[blue]%}"
cImportant="%{$fg[magenta]%}"
cReset="%{$reset_color%}"
cDefault="%{$fg[default]%}"

info_user() {
  local face="☻"
  if [ $UID -eq 0 ]; then
    echo -n "${cFocus}%n${face}"
  else
    echo -n "%n${face}"
  fi
}

## * Show host if in remote (ssh) computer
info_host() {
  local face="⌘"
  if [ -n "$SSH_CLIENT" ]; then
    print -n "${cFocus}${face}%m"
  fi
}

## * Program return code if error
info_rc() {
  local face_ok face_err
  face_ok="☑"
  face_ok="🗹"
  face_err="☒"
  face_err="⚠"
  face_err="🗷"
  if [ $_return_value -ne 0 ]; then
    print -n $cError$_return_value$face_err
  fi
  unset _return_value
}

info_history() {
  local face="h"
  face="⛬"
  echo -n "%h${face}"
}

## * Current Working directory
##   * show cwd, trunkated from start if not enough room
##   * last path part as focus if writable
##   * last path part as error if not writable'
info_cwd() {
  local path color maxwidth
  maxwidth=$(( 1 - 5 ))
  [[ -w $PWD ]] && color=$cNote || color=$cError
  path="%~"
  path=${(%)path}
  path="%$maxwidth<...<$path%<<"
  path=${(%)path}
  if [ $path = "~" ] || [ $path = "/" ]; then
    print -n ${color}${path}
    return
  fi
  print -n ${path:h}
  [[ ${path:h} != "/" ]] && print -n /
  print -n ${color}${path:t}
}

ZSH_THEME_GIT_PROMPT_UNTRACKED="${cImportant}?"
ZSH_THEME_GIT_PROMPT_ADDED="${cFocus}➕"
ZSH_THEME_GIT_PROMPT_MODIFIED="${cImportant}🟉"
ZSH_THEME_GIT_PROMPT_RENAMED="${cNote}~"
ZSH_THEME_GIT_PROMPT_DELETED="${cNote}➖"
ZSH_THEME_GIT_PROMPT_STASHED="${cFocus}#"
ZSH_THEME_GIT_PROMPT_UNMERGED="${cNote}&"
ZSH_THEME_GIT_PROMPT_AHEAD="${cNote}⏫"
ZSH_THEME_GIT_PROMPT_BEHIND="${cNote}⏬"
ZSH_THEME_GIT_PROMPT_DIVERGED="${cImportant}!"

## * Git status
info_git() {
  local branch
  branch=$(git_current_branch)
  print -n $(git_prompt_status)${branch}
}

## * Number of spawned jobs from shell
info_jobs() {
  local njobs
  njobs=$(jobs -l | wc -l)
  [[ $njobs -gt 0 ]] && print -n "${cNote}${njobs}⚙"
}

info_stub() {
  print -n $cOk"12345"
}

info_empty() {
  print -n ""
}

## * Colored start arrow if root
info_start() {
  if [ $UID -eq 0 ]; then
    print -n $cImportant"%n ▶ "
  else
    print -n $cFocus"▶ "
  fi
}

## * Shell level
info_level() {
  if [ $SHLVL -gt 1 ]; then
    print -n "$cFocus⮇"
  fi
}

info_time() {
  print -n "%*"
}

# local clock
typeset -AHg clock

clock=(
  0000 🕛 0030 🕧 0100 🕐 0130 🕜 0200 🕑 0230 🕝
  0300 🕒 0330 🕞 0400 🕓 0430 🕟 0500 🕔 0530 🕠
  0600 🕕 0630 🕡 0700 🕖 0730 🕢 0800 🕗 0830 🕣
  0900 🕘 0930 🕤 1000 🕙 1030 🕥 1100 🕚 1130 🕦
)

## * Analog clock (within 30m)
info_clock() {
  local hours minutes
  hours=$(date +%I)
  minutes=$(date +%M)
  if [ $minutes -lt 15 ]; then
    minutes=00
  elif [ $minutes -lt 45 ]; then
    minutes=30
  else
    hours=$(( hours + 1 ))
    [[ hours -ge 12 ]] && hours=00
    minutes=00
  fi
  print -n $clock[$(printf "%02d%02d" $hours $minutes)]
}

## * Disk usage alert if over 80% capacity
info_disk() {
  local use
  use=${(S)$(df --output=pcent .)//[^0-9]}
  use=${(S)use// } # use have strange space, kill it
  if [ $use -gt 80 ]; then
    print -n "${cFocus}${use}🖸"
  fi
}

## * Number of todo items in files
info_todos() {
  [[ ! -w $PWD ]] && return
  local value
  value=$(grep  --directories=skip 'TODO ' * | wc -l)
  if [ $value -gt 0 ]; then
    print -n "${cFocus}${value}🔨"
  fi
}

infoline_parts=(info_cwd info_git info_jobs info_rc info_host info_level  info_todos info_disk info_clock)

infoline_prompt=(info_start)

render_prompt() {
  _return_value=$? # have to be first, before any command

  local -a parts_info parts_prompt
  local part value
  local remain=$((COLUMNS-2))

  foreach part ($infoline_parts)
    value=$($part $remain)
    if [ -n "$value" ]; then
      width=${#${(%)${(S)value//\%\{*\%\}}}}
      if [ $width -lt $remain ]; then
        parts_info+=${value}${cDefault}
        remain=$((remain - width - 1))
      fi
    fi
  end
  remain=$((remain + 1))

  foreach part ($infoline_prompt)
    tmp=$($part)
    if [ -n "$tmp" ]; then
      parts_prompt+=$tmp${cDefault}
    fi
  end

  print -n $cReset
  print -n $BG[237]
  print -n " "
  print -n ${(j: :)parts_info}
  print -n ${(l:$remain:: :)}
  print -n " "
  print -n $cReset
  print -n ${(j: :)parts_prompt}
}

PROMPT='$(render_prompt)'
#print ${(%)$(render_prompt)}
