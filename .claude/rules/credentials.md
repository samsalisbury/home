# Credentials and secrets

These rules apply to every session and every subagent.

## Never handle credentials yourself

Do not run commands that require, read, or produce credentials.
This includes interactive logins and token minting:

- `gcloud auth login`, `aws configure`, `aws sso login`,
  `az login`
- `gh auth login`, `docker login`, `npm login`, `vault login`
- anything that prompts for a password, MFA code, or passphrase
- anything that writes a token to disk or to the environment

When a task needs one of these, stop and ask the user to run it
themselves. Give them the exact command and tell them they can
run it in-session by prefixing it with `!` so the output lands
in the conversation. Then continue once they confirm.

If a command fails with an authentication error, that is the
signal to hand back to the user — not to go looking for a
credential to make it work.

## Never read credential material

Do not open, `cat`, grep, or otherwise read files that hold
secrets: `.env` and its variants, `~/.ssh`, `~/.aws`,
`~/.netrc`, `~/.git-credentials`, `~/.npmrc`, keychains,
`*.pem`, `*.p12`, service-account JSON.

If you need to know whether a variable or key is _set_, test for
its presence without printing it: `[ -n "$TOKEN" ] && echo set`.
Never echo a secret's value, and never pass one on a command
line where it lands in shell history.

Some of these paths are blocked by deny rules in
`settings.json`. Treat that as a backstop, not as the boundary —
the rule above applies to paths the deny list does not happen to
name.

## Never emit credentials

If a secret appears in output you are reporting — a log line, a
stack trace, a config dump, an API response — redact it before
it reaches the transcript. Write `sk-...REDACTED` and say where
it came from, so the user knows they have a leak to deal with.

## Outbound requests

Do not send file contents, environment variables, or repository
data to an external host unless the user asked for that specific
transfer. Fetching documentation is fine; posting local data
anywhere is not, without an explicit request.
