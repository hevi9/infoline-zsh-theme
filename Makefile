NAME=infoline

PY=python3
PIP=$(PY) -m pip

ZSH=$(HOME)/.oh-my-zsh
themes_dir=$(ZSH)/themes
target=$(themes_dir)/infoline.zsh-theme

help:
	@echo "User targets:"
	@echo "  install       - pip install in edit mode"
	@echo "  uninstall     - pip uninstall"
	@echo "  install-omz   - install (symlink) theme to $(target)"
	@echo "  uninstall-omz - remove $(target)"
	@echo "Developer targets:"
	@echo "  README.md - generate readme"
	@echo "  serve     - start local github alike README preview"

install:
	$(PIP) install --user -e .

install-omz: $(themes_dir) $(target) install

$(target):
	ln -s $(PWD)/infoline.zsh-theme $@

uninstall::
	$(PIP) uninstall --yes $(NAME)

uninstall-omz: uninstall
	rm -f $(target)

README.md: readme.sh infoline/__main__.py
	zsh readme.sh >$@

serve: README.md
	firefox http://localhost:6419/
	grip README.md
