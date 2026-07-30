[//]: # (Stack overlay — loaded together with .ai/base-instructions.md for personal Bash/PowerShell script collections)

# Shell Scripts Stack Overlay

Applies on top of `.ai/base-instructions.md` for **personal automation script
collections** — Bash and/or PowerShell scripts with no compiled artifact and no
service to deploy. Use it for repos like `linux-scripts`, `powershell`
(profile/dotfiles + reusable modules), and `screenpresso-localsend`
(sender/host halves of a small screenshot-forwarding tool) — loose-to-lightly-
structured personal utilities, not application code.

This is a **lighter-weight stack than the others**: no build step, usually no
test framework, and the "project" may be a handful of loose scripts rather than
a structured solution. Don't force base-instructions' Clean Code / TDD
machinery onto a five-line alias script — apply it where the script has real
logic worth protecting, and use judgment elsewhere.

---

## Tech Stack

Bash (Linux/macOS scripts, `#!/usr/bin/env bash`) and/or **Windows PowerShell**
(profile scripts, modules, Windows-side automation) — pick per-script based on
target OS, don't force one shell where the other is native. `shellcheck` for
Bash, `PSScriptAnalyzer` for PowerShell, when linting is set up. No package
manager, no build step — a script *is* the deliverable.

**PowerShell version target:** unless a script only ever runs interactively on
the author's own up-to-date machine, target **Windows PowerShell 5.1**
compatibility (no `pwsh`-only syntax) for anything that might run unattended or
on another machine — see the base PowerShell 5.1 scripting rules this repo's
`base-instructions.md` links to. `pwsh`-only scripts are fine when the script
explicitly requires `pwsh` (e.g. cross-platform tooling) — say so in a
`#Requires -Version 7` line rather than discovering it at runtime.

---

## Project Structure

There's no single mandated layout — these repos range from a flat pile of
scripts at the root to a `mymodules/`-style reusable-module folder. What
matters:

- **A script that's meant to be sourced/imported (a PowerShell module, a Bash
  function library) lives separately from a script that's meant to be run
  directly** — don't mix `source`-only helper code into an executable script's
  top level.
- Reusable logic used by more than one script goes into a shared module/library
  file, not copy-pasted across scripts.
- Config, credentials, and machine-specific paths never get hardcoded into a
  script — see Security below.

---

## Bash Conventions

- `set -euo pipefail` at the top of any script beyond a trivial one-liner —
  fail fast on an unset variable, a failed command, or a broken pipe, rather
  than continuing on bad state.
- Quote variable expansions (`"$var"`, `"${arr[@]}"`) — an unquoted expansion
  that happens to work on the author's test input is a latent word-splitting
  bug.
- Prefer `$(...)` over backticks; prefer `[[ ... ]]` over `[ ... ]` for
  conditionals (fewer quoting footguns).
- Functions for anything reused more than once in the same script; a script
  that's grown past ~50 lines of linear logic is a candidate for functions
  even if nothing's reused yet.
- `shellcheck` clean where lint tooling exists for the repo; fix what it flags
  rather than suppressing with `# shellcheck disable=` without a reason
  comment.

---

## PowerShell Conventions

- **Windows PowerShell 5.1 compatibility is the default assumption** for any
  script that isn't explicitly `pwsh`-only (see Tech Stack). The 5.1 gotchas
  that silently break a script instead of erroring:
  - `??`, `??=`, ternary `? :`, `?.`, `&&`/`||` chains — these are **parse**
    errors on 5.1, so the script dies before its first line runs
  - `$IsWindows`/`$IsLinux`/`$IsMacOS` don't exist on 5.1 — they evaluate to
    `$null`, so an `if ($IsWindows)` branch is silently skipped, not an error
  - `ForEach-Object -Parallel`, `Sort-Object -Stable` are `pwsh`-only
  - `ConvertTo-Json` truncates silently past its default `-Depth 2` — pass
    `-Depth` explicitly for anything nested
  - Web cmdlets (`Invoke-WebRequest`/`Invoke-RestMethod`) want
    `-UseBasicParsing` on a machine with IE's engine not initialized, or the
    call hangs waiting on a prompt
- Advanced functions (`[CmdletBinding()]`, `param()` blocks with typed
  parameters) over positional-parameter scripts once a script takes more than
  one or two arguments.
- Modules (`.psm1` + a manifest when the module is substantial) for anything
  imported by more than one script — see `mymodules/`-style repos.
- `PSScriptAnalyzer` clean where set up; the repo-level template at
  `.ai/examples/dotnet/../templates/pre-commit/PSScriptAnalyzerSettings.psd1`
  (if present in the consuming repo) is the baseline ruleset to start from.

---

## Cross-Platform Pairs (sender/host, Linux/Windows halves)

Some repos ship the same tool as a Bash half and a PowerShell half (e.g. a
Linux host script + a Windows sender script implementing one pipeline). Keep
them behaviourally in sync deliberately:

- Document the shared protocol/contract once (README or a top-of-file
  comment), not duplicated per-language with drift risk.
- A behaviour change on one side is not done until the other side's script (or
  an explicit note that it doesn't apply) is updated in the same change.
- Config file formats/CLI flags stay identical across the two halves unless
  there's a documented OS-specific reason they can't be.

---

## Testing

Base TDD rules apply **in spirit**, scaled to what's actually testable:

- **Bats** (`bats-core`) for Bash scripts with real branching logic worth
  protecting; **Pester** for PowerShell equivalents. Add either when a script
  has logic worth regression-protecting — not for a three-line alias wrapper.
- For scripts with no test framework (the common case for this stack), the
  gate is **running the script against a real or representative input** before
  calling a change done — say so explicitly rather than claiming untested
  changes are verified.
- Never claim a script "works" without having actually run it; shell scripts
  fail in ways static reading doesn't catch (quoting, unset vars, wrong
  working directory assumptions).

---

## Security

- No hardcoded credentials, tokens, API keys, or absolute personal paths
  (`/home/<user>/...`, `C:\Users\<user>\...`) committed to a script — use
  environment variables, a config file the repo's `.gitignore` excludes, or a
  secrets manager/credential store the script reads from at runtime.
- Scripts that call out to a webhook/API (Mattermost, Telegram, etc.) read the
  endpoint/token from environment or config, never inline in the script body.
- Validate/sanitize any input that reaches a shell command built via string
  interpolation — command injection is a real risk in scripts that shell out
  based on external input (filenames, API responses, user args).
- systemd service units / scheduled tasks that run a script unattended should
  run with the least privilege the script actually needs, not as root/SYSTEM
  by default.

---

## Versioning & Changelog

Most repos in this stack are personal utility collections without a formal
release cadence. Where the base SemVer/`git-cliff` conventions are worth
applying (the repo has actual consumers besides the author, or ships something
others install), follow base as-is. Where a repo is genuinely just "scripts I
run," a `CHANGELOG.md` `[Unreleased]` section that gets filled in as changes
land is still good practice even without formal version tags.

---

## Agent Guardrails (this stack)

In addition to the base guardrails:

- Do not add a package manager, build step, or framework to what's a script
  collection — if a script has grown enough to need one, flag it rather than
  silently restructuring the repo.
- Do not assume `pwsh`-only syntax is safe — confirm the script's actual
  execution context (unattended/cross-machine vs. author's own interactive
  shell) before using `??`, ternary, `&&`/`||` chains, or `$IsWindows`.
- Do not hardcode machine-specific paths, usernames, or credentials.
- For sender/host or Bash/PowerShell pairs, do not change one side's behaviour
  without addressing the other side in the same change.

### Never generate (this stack)

- `??`, `??=`, ternary `? :`, `?.`, or `&&`/`||` chains in a script that must
  run on Windows PowerShell 5.1
- `$IsWindows`/`$IsLinux`/`$IsMacOS` checks in a 5.1-target script (they're
  `$null` there)
- Unquoted variable expansions in Bash (`$var` instead of `"$var"`)
- A script that shells out to a command built by unsanitized string
  interpolation of external input
- Hardcoded credentials, tokens, or absolute personal file paths
- A claim that an untested script "works" without having actually run it
