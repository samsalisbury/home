SHELL := /usr/bin/env bash -euo pipefail -c

BREW_FLAGS := --no-upgrade

default: help

help:
	@echo '  make brew/install   # install missing things'
	@echo '  make brew/outdated  # list outdated deps that are mentioned in Brewfile'
	@echo '  make brew/upgrade   # upgrade all deps that are mentioned in Brewfile'

brew/outdated:
	@brew-tools outdated_brewfile

brew/upgrade:
	@brew-tools upgrade_outdated_brewfile_deps

brew/install:
	@brew-tools install

upgrade-all: BREW_FLAGS :=
upgrade-all: brew/install

.PHONY: tmux
tmux: .tmux/reset.conf

.PHONY: .tmux/reset.conf
.tmux/reset.conf:
	~/bin/generate-tmux-reset > "$@"

