export VIRTUAL_ENV_DISABLE_PROMPT=yes

infoline-virtualenv() {
  if [ -n "$VIRTUAL_ENV" ]; then
    print -n -- ${VIRTUAL_ENV:t}
  fi
}
infoline_left+=infoline-virtualenv
