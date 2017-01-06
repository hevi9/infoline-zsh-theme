
infoline-cwd() {
  local path color maxwidth
  maxwidth=$1
  [[ -w $PWD ]] && color=$infoline_color[ok] || color=$infoline_color[error]
  path="%~"
  path=${(%)path}
  path="%$maxwidth<$infoline_sign[cont]<$path%<<"
  path=${(%)path}
  if [ $path = "~" ] || [ $path = "/" ]; then
    print -n ${color}${path}
    return
  fi
  print -n ${path:h}
  [[ ${path:h} != "/" ]] && print -n /
  print -n ${color}${path:t}
}
infoline_left+=infoline-cwd
