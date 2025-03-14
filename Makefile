SHELL := /usr/bin/env bash -euo pipefail -c

BREW_FLAGS := --no-upgrade

MAKEFLAGS += --warn-undefined-variables --always-make --silent

default: help

help:
	echo '  make brew/install   # install missing things'
	echo '  make brew/outdated  # list outdated deps that are mentioned in Brewfile'
	echo '  make brew/upgrade   # upgrade all deps that are mentioned in Brewfile'
	echo '  make devbox         # install and initialise devbox global config'

devbox:
	wget https://github.com/jetpack-io/devbox/releases/download/0.5.7/devbox_0.5.7_linux_amd64.tar.gz

devbox-old:
	./init/devbox

# moreutils has a terrible version of parallel bundled with it,
# this snippet ensures all the moreutils binaries are linked
# then overwrites the moreutils parallel with the gnu parallel,
# and tests that it worked.
FIX_PARALLEL_MOREUTILS := brew unlink parallel sponge && \
						  brew link --force --overwrite moreutils && \
						  brew link --force --overwrite parallel sponge && \
						  parallel --version | head -n1 | grep -qE '^GNU parallel \d+' || \
						  { echo "GNU parallel may not have installed correctly."; exit 1; }; \
						  echo "Fixed moreutils and GNU parallel conflict."

brew/outdated:
	brew-tools outdated_brewfile

brew/upgrade:
	brew unlink moreutils parallel sponge
	brew-tools upgrade_outdated_brewfile_deps moreutils parallel  || true
	$(FIX_PARALLEL_MOREUTILS)

brew/upgrade-neovim-head:
	brew reinstall neovim

brew/install:
	brew unlink moreutils
	brew unlink parallel sponge
	brew-tools install
	$(FIX_PARALLEL_MOREUTILS)

brew/fix:
	brew unlink moreutils
	brew unlink parallel sponge
	$(FIX_PARALLEL_MOREUTILS)

upgrade-all: BREW_FLAGS :=
upgrade-all: brew/install

tmux: .tmux/reset.conf

.tmux/reset.conf:
	~/bin/generate-tmux-reset > "$@"

