# Documentation lookup

Look documentation up rather than answering from memory, and
prefer a local source: it is authoritative for the version
actually installed.

- **Go**: `go doc <pkg>.<Symbol>`, run from inside a module that
  requires the package — `go.mod file not found` means `cd` into
  the project, not fall back to a remote lookup. Read the module
  cache source when doc comments are thin.
- **CLI tools**: the installed binary's `man` page and `--help`.
- **Python** `python3 -m pydoc`, **Ruby** `ri`, **Perl**
  `perldoc`. **Rust**: `cargo doc --no-deps`, or crate source
  under the cargo registry.
- **Apple** (Swift, SwiftUI, UIKit and other Apple frameworks):
  the installed SDK's `.swiftinterface` files and headers
  (`xcrun --show-sdk-path`) for exact signatures, then
  developer.apple.com.
- **Other libraries**: the installed package source in the
  project (`node_modules`, site-packages, vendored code) first,
  then the library's official documentation on the web.

If a local doc tool is missing, use the web and say so. When a
local source and a remote one disagree, local wins for "what
does this do here"; say which version each claim comes from
rather than blending them.
