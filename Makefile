SHELL := /usr/bin/env bash -euo pipefail -c

BREW_FLAGS := --no-upgrade

default: help

help:
	@echo '  make brew/install   # install missing things'
	@echo '  make brew/outdated  # list outdated deps that are mentioned in Brewfile'
	@echo '  make brew/upgrade   # upgrade all deps that are mentioned in Brewfile'

# moreutils has a terrible version of parallel bundled with it,
# this snippet ensures all the moreutils binaries are linked
# then overwrites the moreutils parallel with the gnu parallel,
# and tests that it worked.
FIX_PARALLEL_MOREUTILS := brew unlink parallel && \
						  brew link --force --overwrite moreutils && \
						  brew link --force --overwrite parallel && \
						  parallel --version | head -n1 | grep -qE '^GNU parallel \d+' || \
						  { echo "GNU parallel may not have installed correctly."; exit 1; }; \
						  echo "Fixed moreutils and GNU parallel conflict."

brew/outdated:
	@brew-tools outdated_brewfile

brew/upgrade:
	@brew-tools upgrade_outdated_brewfile_deps
	@$(FIX_PARALLEL_MOREUTILS)

brew/install:
	@brew-tools install
	@$(FIX_PARALLEL_MOREUTILS)

brew/fix:
	@$(FIX_PARALLEL_MOREUTILS)

upgrade-all: BREW_FLAGS :=
upgrade-all: brew/install

.PHONY: tmux
tmux: .tmux/reset.conf

.PHONY: .tmux/reset.conf
.tmux/reset.conf:
	~/bin/generate-tmux-reset > "$@"

