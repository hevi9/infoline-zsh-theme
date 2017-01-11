#!/usr/bin/make -f

dir=samplegits
script=../../vcsgit.zsh

all: empty untracked unstaged staged stash ahead behind merge

$(dir)/empty:
	mkdir -p $@
	cd $@ && git init

empty: $(dir)/empty
	@echo "*** $<"
	@cd $< && zsh $(script)
	@cd $< && git status -s

$(dir)/untracked:
	mkdir -p $@
	cd $@ && git init
	cd $@ && touch README.md

untracked: $(dir)/untracked
	@echo "*** $<"
	@cd $< && zsh $(script)
	@cd $< && git status -s

$(dir)/staged:
	mkdir -p $@
	cd $@ && git init
	cd $@ && touch README.md
	cd $@ && git add README.md

staged: $(dir)/staged
	@echo "*** $<"
	@cd $< && zsh $(script)
	@cd $< && git status -s

$(dir)/unstaged:
	mkdir -p $@
	cd $@ && git init
	cd $@ && touch README.md
	cd $@ && git add README.md
	cd $@ && git commit -m "test"
	cd $@ && echo "thing" >> README.md

unstaged: $(dir)/unstaged
	@echo "*** $<"
	@cd $< && zsh $(script)
	@cd $< && git status -s

$(dir)/stash:
	mkdir -p $@
	cd $@ && git init
	cd $@ && touch README.md
	cd $@ && git add README.md
	cd $@ && git commit -m "test"
	cd $@ && git stash
	cd $@ && echo "thing" >> README.md
	cd $@ && git stash

stash: $(dir)/stash
	@echo "*** $<"
	@cd $< && zsh $(script)
	@cd $< && git status -s

$(dir)/shared:
	mkdir -p $@
	cd $@ && git init --bare

$(dir)/ahead: $(dir)/shared
	mkdir -p $@
	cd $@ && git init
	cd $@ && touch README.md
	cd $@ && git add README.md
	cd $@ && git commit -m "test"
	cd $@ && git remote add origin ../shared
	cd $@ && git push --set-upstream origin master
	cd $@ && echo "thing" >> README.md
	cd $@ && git commit -a -m "test"
	cd $@ && git push
	cd $@ && echo "thing 2" >> README.md
	cd $@ && git commit -a -m "test 2"

ahead: $(dir)/ahead
	@echo "*** $<"
	@cd $< && zsh $(script)
	@cd $< && git status -s

$(dir)/behind: $(dir)/shared
	mkdir -p $@
	cd $@ && git init
	cd $@ && touch README.md
	cd $@ && git add README.md
	cd $@ && git commit -m "test"
	cd $@ && git remote add origin ../shared
	cd $@ && git fetch origin master
	cd $@ && git branch --set-upstream-to=origin/master master

behind: $(dir)/behind
	@echo "*** $<"
	@cd $< && zsh $(script)
	@cd $< && git status -s


$(dir)/merge:
	mkdir -p $@
	cd $@ && git init
	cd $@ && echo testing > README.md
	cd $@ && git add README.md
	cd $@ && git commit -m "test 1"
	cd $@ && git checkout -b second
	cd $@ && echo tetsing > README.md
	cd $@ && git commit -am "test 2"
	cd $@ && git checkout master
	cd $@ && echo tetssng > README.md
	cd $@ && git commit -am "test 3"
	cd $@ && git merge second

merge: $(dir)/merge
	@echo "*** $<"
	@cd $< && zsh $(script)
	@cd $< && git status -s
