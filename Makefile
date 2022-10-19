SHELL := /usr/bin/env bash -euo pipefail -c

default: install

BREW_FLAGS := --no-upgrade

install:
	brew bundle $(BREW_FLAGS) | grep -Ev '^Using'

upgrade-all: BREW_FLAGS :=
upgrade-all: install

.PHONY: tmux
tmux: .tmux/reset.conf

.PHONY: .tmux/reset.conf
.tmux/reset.conf:
	~/bin/generate-tmux-reset > "$@"

