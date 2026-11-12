# Git

- **Never push** — no `git push` (any form), `gh pr create`,
  `gh pr merge`, `gh release create`, or other remote write —
  unless I ask in that message. Earlier permission does not
  carry forward. If the work needs a push to be useful, stop
  short and tell me what remains to run.
- **Never rewrite shared history** (`rebase`, `commit --amend`,
  `reset --hard`, force-push on a branch that exists on a
  remote) unless I ask for that specific operation.
- **Before `checkout`, `restore`, `clean` or `stash`**, check for
  uncommitted work and say what would be discarded.

## The home dotfiles repo

`$HOME` is tracked by a repo that plain `git` there will not
see:

```
export GIT_DIR=$HOME/home.git GIT_WORK_TREE=$HOME
```

(`git-dotfiles` in `~/funcs/git-dotfiles.bash` sets this up.) A
second repo tracks `/`.

`~/home.gitignore` is deny-by-default (`/*`), and also ignores
`*.json`, `*.yaml` and `*.yml` as a credential precaution.
Nothing unignores `.claude`, so a new file under `~/.claude` is
invisible rather than untracked — adding one needs `git add -f`.
Check `git check-ignore -v <path>` rather than trusting
`git status` there.
