# development helpers
debug() {
  print -b "D |$@|" 1>&2
}

# define colors
autoload -U colors && colors
typeset -A infoline_color
infoline_color=(
  ok "%{$fg[green]%}"
  focus "%{$fg[yellow]%}"
  error "%{$fg[red]%}"
  note "%{$fg[blue]%}"
  important "%{$fg[magenta]%}"
  reset "%{$reset_color%}"
  default "%{$fg[default]%}"
  line "%{$bg[grey]%}"
)

# define signs
typeset -A infoline_sign
infoline_sign=(
  cont '…'
  plus '✚'
  cross '✖'
  dot '●'
  dots '⛬'
  star '🟉'
  flag '⚑'
  skull '🕱'
  jobs '⚙'
  level '⮇'
  disk '🖸'
  memory '🖫'
  untracked '?'
  ahead '⭱'
  behind '⭳'
  diverged '⭿'
  differ '⭾'
  stashes '≡'
  start '▶'
  file '🗎'
  dir '📁'
  todo '🔨'
  action '↯'
  location '⌘'
  check '🗹'
)

# infoline sections
infoline_left=()
infoline_right=()
infoline_start=()

# source sections
source ${0:A:h}/infoline-host.zsh
source ${0:A:h}/infoline-cwd.zsh
source ${0:A:h}/infoline-vcsgit.zsh
source ${0:A:h}/infoline-rc.zsh
source ${0:A:h}/infoline-start.zsh
# source ${0:A:h}/infoline-history.zsh
source ${0:A:h}/infoline-jobs.zsh
source ${0:A:h}/infoline-shelllevel.zsh
source ${0:A:h}/infoline-disk.zsh
source ${0:A:h}/infoline-clock.zsh


# render prompt on each new command line
infoline-prompt() {
  _return_value=$?

  local -a left right start
  maxwidth=$((COLUMNS / 2))

  # right section
  foreach part ($infoline_right)
    value=$($part $maxwidth)
    if [ -n "$value" ]; then
      # right+="%$maxwidth<…<$value"$cdefault
      right+=$value$infoline_color[default]
    fi
  end
  right_value=${(j: :)right}
  right_width=${#${(%)${(S)right_value//\%\{*\%\}}}}

  # left section
  maxwidth=$(( ( COLUMNS - right_width ) / 2 ))
  foreach part ($infoline_left)
    value=$($part $maxwidth)
    if [ -n "$value" ]; then
      #left+="%$maxwidth<…<$value"$cdefault
      left+=$value$infoline_color[default]
    fi
  end
  left_value=${(j: :)left}
  left_width=${#${(%)${(S)left_value//\%\{*\%\}}}}

  # start section
  foreach part ($infoline_start)
    start+=$($part)$infoline_color[default]
  end
  start_value=${(j: :)start}

  # center fill
  width=$((COLUMNS - left_width - right_width - 2))
  if [ $width -gt 0 ]; then
    fill=${(r:$width:: :)}
  else
    fill=" "
  fi

  # render
  print -nr -- "$infoline_color[line] $left_value$fill$right_value $infoline_color[reset]"
  print -nr -- "$start_value $infoline_color[reset]"
}

if (( ${*[(I)show]} )); then
  if (( ${*[(I)false]} )); then
    false
    print -n -P "$(infoline-prompt)"
  else
    true
    print -n -P "$(infoline-prompt)"
  fi
else
  PROMPT='$(infoline-prompt)'
fi

# cleanup
unset debug
