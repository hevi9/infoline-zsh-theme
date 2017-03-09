
# Infoline zsh prompt theme

![Screenshot of Infoline](screenshot.png "Infoline screenshot")

## Features

* Line to separate program output and provide information
* Show host if in remote (ssh) computer
* Show Current Working directory
  * Current dir part as green if can write, red if not
* Show git status if exists (and others via zsh vcs_info)
  * Branch name with color: purple for untracked files, yellow for unstaged files
    and blue for staged files
  * Repo N⭱ ahead or N⭳ behind.
  * Merge ⭾ etc action state (via vcs_info)
* Program return code if error
* N⚙ Number of spawned jobs from shell
* ⮇ Shell level indicator
* Disk usage alert if over 80% yellow or 90% red capacity and show on $HOME
  capacity
* ▶ Start arrow with color and name if not login user

Limitations

* Uses 8-colors, works best with Solarized or Dark Pastels color-schemes.

## Install Instructions

1. Git clone
```shell
> cd ~/src   # or wherever you like to collect local git repositories
> git clone https://github.com/hevi9/infoline-zsh-theme.git
```
2. Edit .zshrc
```shell
source $HOME/src/infoline-zsh-theme/infoline.zsh-theme
```

.. or use your's favorite zsh package manager.

## Requirements
  * [zsh](http://www.zsh.org/)

## Configuration

No configuration yet. Good to go as it is. Configurations will be added by
need basis.

## Notes
  * This prompt theme had python implementation, but it was too slow: 120ms to
    350ms for prompt use. User experience was sluggish and slowness interfere completion
    with slow redraw of prompt. If interested about python implementation see
    pythonsave branch.

## Todos, Enchantments, Bugs, Issues ..

https://github.com/hevi9/infoline-zsh-theme/issues
