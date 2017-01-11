infoline-stub() {
  print -n $cok"0123456789"
}

infoline-longstub() {
  print -n $cok"012345678901234567890123456789012345678901234567890123456789"
}
#infoline_left+=infoline-longstub

infoline-empty() {
  print -n ""
}
infoline_left+=infoline-empty


infoline_right+=infoline-stub
infoline_right+=infoline-stub
infoline_left+=infoline-stub
infoline_left+=infoline-stub
infoline_start+=infoline-stub
