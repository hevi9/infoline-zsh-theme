themes_dir=$(ZSH)/themes
target=$(themes_dir)/infoline.zsh-theme

help:
	@echo "User targets:"
	@echo "  install   - install (symlink) theme to $(target)"
	@echo "  uninstall - remove $(target)"
	@echo "Developer targets:"
	@echo "  README.md - generate readme"
	£echo "  serve     - start local github alike README preview"

install: $(themes_dir) $(target)
	python3.5 setup.py develop --user

$(target):
	ln -s $(PWD)/infoline.zsh-theme $@

uninstall:
	rm -f $(target)

README.md: readme.sh infoline.zsh-theme
	zsh readme.sh >$@

serve: README.md
	firefox http://localhost:6419/
	grip README.md
