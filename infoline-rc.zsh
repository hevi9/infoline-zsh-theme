infoline-rc() {
  if [ $_return_value -ne 0 ]; then
    print -n $infoline_color[error]$_return_value$infoline_sign[skull]
  fi
  unset _return_value
}
infoline_right+=infoline-rc
