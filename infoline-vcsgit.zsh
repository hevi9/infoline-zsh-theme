+vi-git-stash() {
    local -a stashes
    if [[ -s ${hook_com[base]}/.git/refs/stash ]] ; then
        stashes=$(git stash list 2>/dev/null | wc -l)
        hook_com[misc]+="${stashes}$infoline_sign[stashes]"
    fi
}

+vi-git-st() {
    local ahead behind
    local -a gitstatus
    ahead=$(git rev-list ${hook_com[branch]}@{upstream}..HEAD 2>/dev/null | wc -l)
    (( $ahead )) && gitstatus+=( "${infoline_color[note]}${ahead}${infoline_sign[ahead]}${infoline_color[default]}" )
    behind=$(git rev-list HEAD..${hook_com[branch]}@{upstream} 2>/dev/null | wc -l)
    (( $behind )) && gitstatus+=( "${infoline_color[note]}${behind}${infoline_sign[behind]}${infoline_color[default]}" )
    hook_com[misc]+=${(j::)gitstatus}
}

+vi-home-path() {
  autoload -U regexp-replace
  hook_com[base]="${hook_com[base]/$HOME/~}"
}

+vi-git-untracked() {
  if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
    git status --porcelain | grep '??' &> /dev/null ; then
    hook_com[unstaged]+=$infoline_color[important]
  fi
}

autoload -Uz vcs_info
zstyle ':vcs_info:*+*:*' debug false

zstyle ':vcs_info:*+set-message:*' hooks git-st git-stash git-untracked

zstyle ':vcs_info:*' get-revision true
zstyle ':vcs_info:*' check-for-changes true

zstyle ':vcs_info:*' branchformat '%b@%r'
zstyle ':vcs_info:*' unstagedstr $infoline_color[focus]
zstyle ':vcs_info:*' stagedstr $infoline_color[note]
zstyle ':vcs_info:git:*' patch-format "${infoline_color[focus]}%n${infoline_sign[differ]}${infoline_color[default]} "
zstyle ':vcs_info:*' formats '%c%u%b %m'
zstyle ':vcs_info:*' actionformats "%c%u%b ${infoline_color[important]}%a${infoline_color[default]}%m"


infoline-vcsgit() {
  vcs_info
  print "${vcs_info_msg_0_}"
}
infoline_left+=infoline-vcsgit
