print '
# Infoline zsh theme
'

print '
## Features'
sed -n 's/^## \(.*\)/\1/p' < infoline.zsh-theme

print '
## TODOs'
sed -n 's/\# TODO \(.*\)/ * \1/p' < infoline.zsh-theme
