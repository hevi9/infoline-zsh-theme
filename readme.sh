#!/usr/bin/env bash

file=infoline/__main__.py

print '
# Infoline zsh prompt theme

![Screenshot of Infoline](screenshot.png "Infoline screenshot")

'

print '
## Features
'
sed -n 's/^## \(.*\)/\1/p' < $file

print '
## Install
Install theme as symlink to oh my zsh $ZSH/themes
```shell
> cd ~/src   # or wherever you like to collect local git repositories
> git clone https://github.com/hevi9/infoline-zsh-theme.git
> cd infoline-zsh-theme
> make install-omz
```

Install to use directly in .zshrc
  * make install instead make install-omz
  * Edit infoline.zsh-theme contents into your .zshrc
'


print '
## Requirements
  * 256 color and unicode terminal
  * zsh
  * oh my zsh - https://github.com/robbyrussell/oh-my-zsh
  * Python 3.4+, pip and dependencies via pip install:
    * psutils
    * gitpython
'

print '
## Notes
 * This prompt uses python for more complex and convient programmnig than shell,
   therefore process startup cost is higher. Prompt execution takes usually
   130ms.'
sed -n 's/\# NOTE \(.*\)/ * \1/p' < $file


print '
## Todos
 * bash support, after bash unicode and non-printable wrap issues are resolved'
sed -n 's/\# TODO \(.*\)/ * \1/p' < $file
