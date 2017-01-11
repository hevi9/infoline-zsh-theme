infoline-host() {
  if [ -n "$SSH_CLIENT" ]; then
    print -n %m$infoline_sign[location]
  fi
}
infoline_left+=infoline-host
