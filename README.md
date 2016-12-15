
# Infoline zsh theme

![Screenshot of Infoline](screenshot.png "Infoline screenshot")



## Features

* ⌘ Show host if in remote (ssh) computer
* 🕱 Program return code if error
* Current Working directory
  * show cwd, trunkated from start if not enough room
  * last path part as focus if writable
  * last path part as error if not writable'
* Git status
* ⚙ Number of spawned jobs from shell
* ▶ Prompt start arrow colored (and named) by user
* ⮇ Shell level indicator
* 🕒 Analog clock (within 30m)
* 🖸 Disk usage alert if over 80% capacity
* 🔨 Number of todo items in files

## Install
Install theme as symlink to $ZSH/themes
```shell
> cd ~/src   # or wherever you like to collect local git repositories
> git clone https://github.com/hevi9/infoline-zsh-theme.git
> cd infoline-zsh-theme
> make install
```


## Requirements
  * 256 color and unicode terminal
  * oh my zsh - https://github.com/robbyrussell/oh-my-zsh


## TODOs

 * cleanup "exported" variables
 * better rc sigil
 * git status by priority
 * colored clock depending quandrant ?
