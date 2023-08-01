
langs() {
	# Go
	export GOPATH="$HOME/go"
	pathadd "/usr/local/go/bin"
	pathadd "$GOPATH/bin"
	
	# Rust
	pathadd "$HOME/.cargo/bin"
	
	# Ruby
	pathadd "/usr/local/opt/ruby/bin"
	has rbenv && {
		pathadd "$HOME/.rbenv/bin"
		eval "$(rbenv init -)"
	}
	
	# Python
	if command -v pyenv > /dev/null 2>&1; then
	  eval "$(pyenv init --path)"
	fi
}
