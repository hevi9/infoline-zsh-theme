infoline-shelllevel() {
  if [ $SHLVL -gt 1 ]; then
    print -n $infoline_color[focus]$infoline_sign[level]
  fi
}
infoline_right+=infoline-shelllevel
