# Credentials and secrets

Applies to every session and every subagent.

- **Never run auth commands yourself** — `gcloud auth login`,
  `aws sso login`, `gh auth login`, `docker login`, `npm login`,
  `vault login`, or anything that prompts for a password, MFA
  code or passphrase, or writes a token. Give the user the exact
  command to run with the `!` prefix, then continue once they
  confirm. An auth error is the signal to hand back, not to go
  looking for a credential.
- **Never read credential material** — `.env*`, `~/.ssh`,
  `~/.aws`, `~/.netrc`, `~/.git-credentials`, `~/.npmrc`,
  keychains, `*.pem`, `*.p12`, service-account JSON. The
  settings deny list is a backstop, not the boundary. To check a
  variable is set, test without printing:
  `[ -n "$TOKEN" ] && echo set`.
- **Never emit a secret.** If one appears in output, write
  `sk-...REDACTED`, say where it came from, and flag the leak.
