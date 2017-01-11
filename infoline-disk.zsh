infoline-disk() {
  local use color
  use=${(S)$(df --output=pcent .)//[^0-9]}
  use=${(S)use// } # use have strange space, kill it
  [[ $use -gt 80 ]] && color=$infoline_color[error] || color=$infoline_color[note]
  if [[ $use -gt 80 || x$PWD = x$HOME ]]; then
    print -n $color${use}$infoline_sign[disk]
  fi
}
infoline_right+=infoline-disk
