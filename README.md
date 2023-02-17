# Sam's dotfiles (home dir)

To set this up on a new machine:

1. Install bash and git.
2. Clone this repo: `git clone https://github.com/samsalisbury/home`
3. Start a new bash shell, and everything should be there.

To make changes:

Type `home` to start a subshell with git configured to manage
the home directory. This uses
[git-dotfiles](https://fieldnotes.tech/2022/11/20/managing-dotfiles-with-git/)
to create an isolated git environment that's only aware of files you explicitly
`git add` to the repo. It also uses `home.git` as its `GIT_DIR` so when you're
not using this shell, other directories don't thing they're in some gigantic
repo (which they would if we used `~/.git` as the git dir).

```shell
~ sam$ home
# Home subshell started.
home.git> ~ sam$ git add README.md
home.git> ~ sam$ git commit -m "Update readme"
home.git> ~ sam$ git push
home.git> ~ sam$ exit
# Home subshell ended.
~ sam$ 
```

