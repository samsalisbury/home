# Delegating to agents

Run test suites, builds, linters and type checkers through the
`test-runner` agent rather than inline. Tell it what you changed
and what breakage you expect — "run the auth suite; I changed
token refresh and expect failures around expiry" beats "run the
tests".

When an agent reports low confidence or something it could not
verify, carry that qualification through to me rather than
flattening it into a plain assertion.
