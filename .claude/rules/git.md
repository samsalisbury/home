# Git

## Never push

Do not push, ever, unless the user explicitly asks in that
message. This covers every form of publishing work:

- `git push`, including `--force`, `--force-with-lease`, and tag
  pushes
- `gh pr create`, `gh pr merge`, `gh release create`
- any command that writes to a remote

An earlier "yes" does not carry forward. Permission to push once
is permission to push that once. If a task seems to require a
push to be useful, do everything up to that point, then stop and
say what remains for the user to run.

The same applies to any other outward-facing publish: opening a
PR, commenting on an issue, or posting to an external service.

## Committing

Commit only when asked. When the user does ask, and the current
branch is the default branch, create a branch first.

## History

Never rewrite history that may have been shared — no `rebase`,
`commit --amend`, `reset --hard`, or force-push on a branch that
exists on a remote — unless the user asks for that specific
operation.

Before `git checkout`, `git restore`, `git clean`, or
`git stash`, check for uncommitted work and say what would be
discarded. These silently destroy changes the user may not have
saved.

## Read freely

Reading history is always fine and needs no permission: `log`,
`blame`, `show`, `diff`, `status`. Prefer delegating a broad
history sweep to `git-archaeologist`.

## The home dotfiles repo

`$HOME` is tracked by a repo that ordinary `git` commands run
there will not see, because the git directory is elsewhere:

```
export GIT_DIR=$HOME/home.git GIT_WORK_TREE=$HOME
```

The `git-dotfiles` shell function sets this up interactively; it
lives in `~/funcs/git-dotfiles.bash` and is wired up by
`~/.bashrc.d/80-git-dotfiles.bash`. A second repo tracks `/`.

`~/home.gitignore` is deny-by-default — its third rule is `/*`,
so everything is ignored unless explicitly unignored, and
`*.json`, `*.yaml`, and `*.yml` are ignored as a credential
precaution. Nothing unignores `.claude`, so every tracked file
under it was force-added.

The consequence worth remembering: a new file under `~/.claude`
does not show up as untracked, it is simply invisible. Adding
one requires `git add -f`. When reporting what is or isn't
committed there, check `git check-ignore -v <path>` rather than
trusting `git status`.
