
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

### Antigen

Add `antigen bundle hevi9/infoline-zsh-theme` to your .zshrc file. [Antigen](https://github.com/zsh-users/antigen) will handle cloning the plugin for you automatically the next time you start zsh. You can also add the plugin to a running zsh with `antigen bundle hevi9/infoline-zsh-theme` for testing before adding it to your `.zshrc`.

### oh-my-zsh

Install theme as symlink to $ZSH/themes
```shell
> cd ~/src   # or wherever you like to collect local git repositories
> git clone https://github.com/hevi9/infoline-zsh-theme.git
> cd infoline-zsh-theme
> make install
```

### zgen

Add `zgen load hevi9/infoline-zsh-theme` to your .zshrc file in the same function you're doing your other `zgen load` calls in. [Zgen](https://github.com/tarjoilija/zgen) will automatically clone the repository for you when you do a `zgen save`.

## Requirements
  * 256 color and unicode terminal
  * [oh my zsh](https://github.com/robbyrussell/oh-my-zsh) or another zsh framework that is oh-my-zsh compatible like [Zgen](https://github.com/tarjoilija/zgen) or [Antigen](https://github.com/zsh-users/antigen).


## TODOs

 * cleanup "exported" variables
 * better rc sigil
 * git status by priority
 * colored clock depending quandrant ?
