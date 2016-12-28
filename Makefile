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
	@echo "  install-omz   - in addition install theme under .oh-my-zsh"
	@echo "  uninstall-omz - remove theme from .oh-my-zsh"
	@echo "Developer targets:"
	@echo "  dev       - setup development tools"
	@echo "  check     - verify code"
	@echo "  README.md - generate readme"
	@echo "  serve     - start local github alike README preview"

# user

install:
	$(PIP) install --user  .

install-omz: $(themes_dir) $(target) install

$(target):
	ln -s $(PWD)/infoline.zsh-theme $@

uninstall::
	$(PIP) uninstall --yes $(NAME) # pip uninstall does not work on --user

uninstall-omz: uninstall
	rm -f $(target)

# Developer

dev: uninstall
	$(PY) -m pip install --user grip flake8
	$(PIP) install --user -e .

README.md: readme.sh infoline/__main__.py
	zsh readme.sh >$@

serve: README.md
	grip --quiet --browser README.md

check:
	$(PY) setup.py check --metadata --strict
	flake8 --show-source --statistics
