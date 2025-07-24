# shellcheck disable=SC1090,SC1091
[[ -f ~/.bashrc ]] && source ~/.bashrc

source-if-exists() { if [[ -f "$1" ]]; then source "$1"; fi; }

# The next line updates PATH for the Google Cloud SDK.
source-if-exists "$HOME/google-cloud-sdk/path.bash.inc"
source-if-exists "$HOME/google-cloud-sdk/completion.bash.inc"
