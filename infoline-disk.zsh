infoline-disk() {
  local use
  use=${(S)$(df --output=pcent .)//[^0-9]}
  use=${(S)use// } # use have strange space, kill it
  if [ $use -gt 80 ]; then
    print -n $infoline_color[error]${use}$infoline_sign[disk]
  fi
}
infoline_right+=infoline-disk
