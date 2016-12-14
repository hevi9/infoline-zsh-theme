themes_dir=$(ZSH)/themes
target=$(themes_dir)/infoline.zsh-theme

help:
	@echo "User targets:"
	@echo "  install   - install (symlink) theme to $(target)"
	@echo "  uninstall - remove $(target)"
	@echo "Developer targets:"


install: $(themes_dir) $(target)

$(target):
	ln -s $(PWD)/infoline.zsh-theme $@

uninstall:
	rm -f $(target)

README.md: readme.sh infoline.zsh-theme
	zsh readme.sh >$@

serve: README.md
	firefox http://localhost:6419/
	grip README.md
