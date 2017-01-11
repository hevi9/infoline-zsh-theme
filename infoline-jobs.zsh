infoline-jobs() {
  local njobs
  # Use subshell for jobs !
  # http://unix.stackexchange.com/questions/251868/jobs-wc-getting-weird-return-values
  njobs=$( ( jobs -l ) | wc -l)
  [[ $njobs -gt 0 ]] && print -n $infoline_color[note]${njobs}$infoline_sign[jobs]
}
infoline_right+=infoline-jobs
