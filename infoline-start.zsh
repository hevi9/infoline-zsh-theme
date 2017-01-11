infoline-userstart() {
  if [ $UID -eq 0 ]; then
    print -n $infoline_color[important]$USER
  else
    if [ $USER != $LOGNAME  -o -n "$SUDO_USER" -o $UID -lt 1000 ]; then
      print -n $infoline_color[note]$USER
    fi
  fi
  print -n $infoline_color[focus]$infoline_sign[start]
}
infoline_start+=infoline-userstart
