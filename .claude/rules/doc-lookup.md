# Documentation lookup

Look documentation up rather than answering from memory —
training data lags releases. But reach for the closest source
first: a locally installed source is authoritative for the
version actually in use, and costs no API call.

Route by what is being asked about.

## Apple ecosystem → `cupertino` skill

Swift the language, SwiftUI, UIKit, AppKit, Foundation, Combine,
and every other Apple framework; iOS, macOS, watchOS, visionOS;
Human Interface Guidelines; Swift Evolution proposals; Apple
sample code.

It searches Apple's documentation set offline, and is both
faster and more complete than any remote source for this
material. Never use Context7 or web search for Apple APIs.

## Go → `go doc`

`go doc <pkg>` and `go doc <pkg>.<Symbol>` for the standard
library, from anywhere.

For third-party Go packages, run `go doc` **from inside a module
that requires the package** — it resolves through `go.mod` and
the module cache. Outside a module it fails with
`go.mod file not found`, which is a signal to `cd` into the
project, not to fall back to a remote lookup.

This reads the exact source of the version pinned in `go.mod`,
so it beats any published documentation for correctness. When a
doc comment is thin, read the source in the module cache.

## CLI tools → probe the installed binary

Delegate to `cli-prober`, or read `man <tool>` and
`<tool> --help` directly.

The installed version is ground truth. When local help output
and published documentation disagree, the local output wins and
the disagreement is worth reporting.

## Other languages → that language's own doc tool

Use the local tool when the language ships one:

- Python: `python3 -m pydoc <module>.<symbol>` — covers
  installed packages, not just the stdlib
- Ruby: `ri <Class>#<method>`
- Perl: `perldoc <module>`, `perldoc -f <builtin>`
- Rust: `rustup doc --std` for the standard library,
  `cargo doc --no-deps` for a project's own dependencies, and
  crate source under the cargo registry when the generated docs
  are thin

Rust has no terminal query tool equivalent to `go doc` — its
output is HTML or source. For a quick API question Context7 is
often faster; use the local docs when the answer must match the
version the project actually pins.

If a language's doc tool is not installed, fall back to Context7
for that lookup and say so, rather than treating the gap as
permanent.

## Claude, Anthropic API, Claude Code → `claude-api` skill

Model IDs, pricing, parameters, streaming, tool use, caching,
token counting. Never answer these from memory.

## Everything else → Context7 MCP

Third-party libraries, frameworks, SDKs, cloud services — React,
Next.js, Prisma, Express, Tailwind, Django, Spring Boot, and the
rest. Use it for API syntax, configuration, version migration,
library-specific debugging, and setup instructions. Prefer it
over web search.

1. Start with `resolve-library-id` using the library name and
   what you want to look up, unless an exact `/org/project` ID
   was given.
2. Pick the best match by exact name match, description
   relevance, code snippet count, source reputation (High/Medium
   preferred), and benchmark score. If the results look wrong,
   try alternate names or rephrase (e.g. "next.js" not
   "nextjs"). Use version-specific IDs when a version is
   mentioned.
3. `query-docs` with that ID and a phrase describing what to
   look up, not a single word, scoped to one concept. For a
   question spanning several distinct concepts, make a separate
   call per concept — combined queries dilute ranking and return
   shallow results for each. The exception is a question about
   how two concepts interact, which belongs in one query.
4. Answer from the fetched docs.

## Web search

Only when the sources above come up empty: release
announcements, breaking-change discussions, blog posts, and
libraries too new or too obscure for Context7.

## Do not look up

Refactoring, writing scripts from scratch, debugging business
logic, code review, and general programming concepts. These need
no external documentation.

## When sources disagree

Local wins for "what does this do here". A remote source
describing a newer version is useful for "what changed" or "how
should I migrate", but say which version each claim came from
rather than blending them into one answer.
