typeset -AHg _infoline_clock

_infoline_clock=(
  0000 🕛 0030 🕧 0100 🕐 0130 🕜 0200 🕑 0230 🕝
  0300 🕒 0330 🕞 0400 🕓 0430 🕟 0500 🕔 0530 🕠
  0600 🕕 0630 🕡 0700 🕖 0730 🕢 0800 🕗 0830 🕣
  0900 🕘 0930 🕤 1000 🕙 1030 🕥 1100 🕚 1130 🕦
)

infoline-clock() {
  local hours minutes color
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
  print -n $_infoline_clock[$(printf "%02d%02d" $hours $minutes)]
}

infoline_right+=infoline-clock
