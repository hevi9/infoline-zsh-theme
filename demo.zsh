#!/usr/bin/zsh --interactive

script="$PWD/infoline.zsh-theme"
project=$PWD


if (( ${*[(I)start]} )); then
  ./runvcsgit.mk
  xfce4-terminal --hide-menubar --geometry=80x42 --execute zsh demo.zsh
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

echo
source $script show
cd $project
echo 'xclock &'
xclock &
source $script show

cd $project
virtualenv sample/venv >/dev/null
source sample/venv/bin/activate
echo source sample/venv/bin/activate
source $script show
deactivate


for dir in $project/samplegits/*; do
  cd $dir
  echo cd ${dir:t}
  source $script show
done



read -q done
