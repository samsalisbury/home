SHELL := /usr/bin/env bash -euo pipefail -c

default: install

install:
	brew bundle --no-upgrade
