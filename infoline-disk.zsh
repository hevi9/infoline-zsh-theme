infoline-disk() {
  local use color
  use=${(S)$(df --output=pcent .)//[^0-9]}
  use=${(S)use// } # use have strange space, kill it
  if [[ $use -gt 80 || x$PWD = x$HOME ]]; then
    color=$infoline_color[note]
    [[ $use -gt 80 ]] && color=$infoline_color[focus]
    [[ $use -gt 90 ]] && color=$infoline_color[error]
    print -n $color${use}$infoline_sign[disk]
  fi
}
infoline_right+=infoline-disk
