#!/usr/bin/zsh

script="$PWD/infoline.zsh-theme"
project=$PWD


if (( ${*[(I)start]} )); then
  ./runvcsgit.mk
  xfce4-terminal --hide-menubar --execute zsh demo.zsh
  exit
fi

cd
source $script show

echo false
source $script show false

cd /usr/bin
echo cd /usr/bin
source $script show

echo sudo -s
sudo zsh $script show

for dir in $project/samplegits/*; do
  cd $dir
  echo cd ${dir:t}
  source $script show
done

cd
echo xclock &
xclock &
source $script show


read -q done
