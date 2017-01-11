
# Infoline zsh prompt theme
Python experimental

![Screenshot of Infoline](screenshot.png "Infoline screenshot")


## Features

* Show host if in remote (ssh) computer
* Show Current Working directory
  * show cwd, trunkated from start if not enough room
  * Current dir part as green if can write, red if not
* Show git status if exists
  * Branch name with color: yellow if repo dirty
  * ? Untracked files
  * Repo ⭱ ahead, ⭳ behind or ⭿ diverged from upstream. ⭱ Missing upstream.
* Show python virtual env
* 🗎 Show number of files in current directory with color: green - all writable
  yellow - some not writable, red - none writable
* 📁 Show number of directories in current directory with color:
  green - all writable, yellow - some not writable, red - none writable
* 🕱 Program return code if error
* ⚙ Number of spawned jobs from shell
* ⮇ Shell level indicator
* 🖸 Disk usage alert if over 80% capacity. Show disk usage when cwd is $HOME.
* 🕦 Analog clock (within 30m resolution)
* ▶ Start arrow with color and name if not login user

## Feasibility

  * This prompt uses python for more complex and convenient programming than shell,
    therefore process startup cost is higher. Prompt execution takes usually
    120ms to 340ms depending computer. Usually there in no need to enter
    commands under 500ms, but not having immediate (< 100ms) response gives
    a bit sluggish feeling.
  * Color scheme works best on gray-a-like terminal background.


## Install Instructions

### Antigen

Add `antigen bundle hevi9/infoline-zsh-theme` to your `.zshrc` file. [Antigen](https://github.com/zsh-users/antigen) will handle cloning the plugin for you automatically the next time you start zsh. You can also add the plugin to a running zsh with `antigen bundle hevi9/infoline-zsh-theme` for testing before adding it to your `.zshrc`.

### Installing to use directly in `.zshrc` without a Framework

  * `make install` instead of `make install-omz`
  * Edit infoline.zsh-theme contents into your `.zshrc`

### Oh-My-Zsh

Install theme as symlink to oh my zsh $ZSH/themes
```shell
> cd ~/src   # or wherever you like to collect local git repositories
> git clone https://github.com/hevi9/infoline-zsh-theme.git
> cd infoline-zsh-theme
> make install-omz
```

### Zgen

Add `zgen load hevi9/infoline-zsh-theme` to your `.zshrc` file in the same function you're doing your other `zgen load` calls in. [Zgen](https://github.com/tarjoilija/zgen) will automatically clone the repository for you when you do a `zgen save`.

## Requirements
  * 256 color and unicode terminal
  * zsh as your login shell
  * [oh my zsh](https://github.com/robbyrussell/oh-my-zsh) or another zsh framework that is oh-my-zsh compatible like [Zgen](https://github.com/tarjoilija/zgen) or [Antigen](https://github.com/zsh-users/antigen).
  * Python 3.4+, pip and dependencies via pip install:
    * psutils
    * gitpython

## Notes
  * Set export DEBUG_PROMPT=1 to show debug log on prompt construction
  * Set export VIRTUAL_ENV_DISABLE_PROMPT=yes

## Todos, Enchantments, Bugs, Issues ..

https://github.com/hevi9/infoline-zsh-theme/issues
