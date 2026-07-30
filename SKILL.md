[//]: # (Source of truth: .ai/base-instructions.md + .ai/stacks/shell-scripts.md — update those, then regenerate by re-running /sync-ai-instructions)

# SKILL.md — OpenClaw Agent Skill

This skill configures OpenClaw for this project.

# AI Agent Base Instructions

Canonical, **stack-agnostic** reference for all AI coding agents. Applies to every project regardless of language or framework. Stack-specific overlays live in `.ai/stacks/<stack>.md` and are loaded alongside this file. A project loads **base + exactly one stack overlay**. Tool-specific files (`CLAUDE.md`, `.github/copilot-instructions.md`, `SKILL.md`) derive from base + the chosen stack.

> **Workflow role:** If a `WORKFLOW-ROLE.md` exists at the repo root, read it before continuing — it describes this repo's place in the personal dev workflow (implementer / consumer / workflow infrastructure). See `ai-instructions/workflows/personal-dev-workflow.md` for the workflow doc itself.
>
> **Project context:** If a `PROJECT-OVERVIEW.md` exists at the repo root, read it before continuing — it describes this repo's product/project context (name, purpose, stakeholders, vision, core customer need, key features, architecture in one paragraph). Per-feature PRDs live under `docs/specs/` or `designs/`; ADRs under `docs/adr/`.
>
> **Agent notes:** If an `AGENT-NOTES.md` exists at the repo root, read it before continuing — it holds project-specific agent-facing context that doesn't fit in the regenerated CLAUDE.md: operational gotchas, project-specific commands, repo-local workflow conventions (branch naming, PR conventions, etc.).

---

## Working Method (before any code)

Meta-rules for *how* to approach a task. Framing adapted from [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills).

- **State assumptions explicitly.** If multiple interpretations exist, present them — don't pick silently.
- **Ask when unclear.** Don't hide confusion behind plausible-looking code.
- **Push back when a simpler approach exists.** Minimum code that solves the problem; nothing speculative (no unrequested flexibility, configurability, or error handling for impossible cases).
- **Surgical edits.** Every changed line must trace to the request. Don't "improve" adjacent code, comments, or formatting. Match existing style. Remove orphans *your* change created — leave pre-existing dead code alone (mention it instead).
- **Goal-driven execution.** Restate the task as a verifiable success criterion before starting. For multi-step work, write a brief numbered plan with a `verify:` check per step, then loop until each check passes.

---

## Clean Code Principles

Apply to all generated and modified code, regardless of language:

- **Small methods/functions** — each does one thing at one level of abstraction; aim for ≤20 lines
- **Guard clauses** — validate and return/throw early at the top; avoid nested `if/else` pyramids
- **Command-Query Separation** — a function either performs an action (command, returns nothing) or returns data (query), never both
- **No flag arguments** — avoid boolean parameters that switch behaviour; split into two clearly named functions instead
- **Meaningful names** — names reveal intent; no abbreviations (`cnt`, `mgr`, `svc`) except universally understood ones (`id`, `url`, `dto`)
- **One level of abstraction per function** — don't mix high-level orchestration with low-level detail; extract helpers
- **Fail fast** — detect invalid state as early as possible and throw specific errors; don't let bad data travel deep into the call stack
- **DRY** — if the same logic exists in two places, extract it; but prefer duplication over the wrong abstraction — wait until the pattern is clear before generalising
- **No dead code** — delete unreachable branches, unused parameters, and vestigial methods; git has history
- **No commented-out code blocks** — delete them, git has history

---

## Testing — TDD, Tests First, No Shortcuts

Applies to every language and framework:

1. Write the failing test first
2. Write the minimum implementation to make it pass
3. Refactor
4. **Never modify a test to make it green** — fix the implementation
5. **Never hardcode return values, mock results, or stub logic** to satisfy a test
6. **Never silently swallow exceptions** to make a test green
7. **After implementation, run the full test suite** — not just the new test
8. **If a test fails after 3 attempts, STOP** and explain what's going wrong instead of continuing to iterate
9. Test naming: `MethodName_StateUnderTest_ExpectedBehavior` (or the idiomatic equivalent for the target language)
10. E2E tests must be independent and idempotent — seed and clean up their own data

Framework-specific test project layout, mocking library choice, and assertion library live in the stack overlay.

---

## UI Development Workflow (Mandatory Phase Order)

**Never skip phases. Never write component code before wireframe approval.**

| Phase | Command | Gate |
|---|---|---|
| 1 — Brainstorm | `/ui:brainstorm` | ASCII wireframe approved |
| 2 — Flow       | `/ui:flow`       | Mermaid diagrams approved |
| 3 — Build      | `/ui:build`      | Shell → logic → interactions → polish |
| 4 — Review     | `/ui:review`     | Checklist passes |

These commands ship from the global operator console (`agent-workflow`), installed once into `~/.claude/commands/ui/` — they are **not** synced per-project. They are stack-neutral: UI component library preferences (e.g. MudBlazor, shadcn/ui, Material, Flutter widgets) are read from the active stack overlay when one is present, otherwise inferred from the existing codebase.

### What to check before writing UI code

- [ ] Does a similar component already exist in a shared folder?
- [ ] Has the ASCII wireframe been approved?
- [ ] Has the Mermaid flow been approved?
- [ ] Are you building the shell first (no business logic yet)?
- [ ] Does the component need a unit/component test?

---

## Localization (i18n) & Regional Formatting

User-facing apps support **`de` and `en`** (CI/dev tooling exempt). Regional formatting follows the **OS region**, not the UI language; `de` with an unknown region falls back to **`de-CH`**. Render via the platform localization API, never `string.Format` / `toString()`.

Full rules: [`localization.md`](https://github.com/freaxnx01/ai-instructions/blob/main/.ai/references/base/localization.md)

---

## Versioning (SemVer)

All projects follow [Semantic Versioning 2.0.0](https://semver.org/): `MAJOR.MINOR.PATCH` — `MAJOR` = breaking, `MINOR` = new feature (backwards-compatible), `PATCH` = bug fix.

Conventional Commits mapping: `BREAKING CHANGE:` footer or `!` after type → MAJOR; `feat` → MINOR; `fix`, `perf` → PATCH; `chore`, `docs`, `ci`, `test`, `refactor` → no bump.

- Git tags follow `v<MAJOR>.<MINOR>.<PATCH>` (e.g. `v1.3.0`) — tag on `main` after merge
- Pre-release: `v1.0.0-alpha.1`, `v1.0.0-beta.2`, `v1.0.0-rc.1`
- **git-cliff** is the changelog and release notes tool — configured via `cliff.toml`
- Where the version is declared in the project (build file, manifest, etc.) is defined by the stack overlay — but it must be declared in **exactly one place**

---

## Changelog

All projects maintain a `CHANGELOG.md` in the repo root following [Keep a Changelog](https://keepachangelog.com) conventions. **Sections per release:** `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

- `[Unreleased]` section accumulates changes until a release is cut
- Auto-generation: **git-cliff** with `cliff.toml` configured for Conventional Commits
- CI integration: `orhun/git-cliff-action` in GitHub Actions generates release notes into GitHub Releases
- CI can validate that `[Unreleased]` is not empty before allowing a release branch

Example: [`.ai/references/base/changelog-example.md`](https://github.com/freaxnx01/ai-instructions/blob/main/.ai/references/base/changelog-example.md)

---

## 12-Factor App Compliance

Projects follow the [12-Factor App](https://www.12factor.net/) methodology: one repo per service, all deps declared, env-var config, attached backing services, separate build/release/run stages, stateless processes, port binding, scale via replicas not threads, fast disposability, dev/prod parity, logs to stdout, admin processes as one-offs.

Stack-specific enforcement details (logging library, migrations, etc.) live in the stack overlay.

Full per-factor table: [`.ai/references/base/12-factor.md`](https://github.com/freaxnx01/ai-instructions/blob/main/.ai/references/base/12-factor.md)

---

## Branching Strategy (GitHub Flow + protection rules)

```text
main              ← always deployable, protected
  └── feature/<issue-id>-short-description
  └── fix/<issue-id>-short-description
  └── chore/<short-description>
  └── release/<version>   ← only if needed for staged releases
```

- `main` requires: passing CI, at least 1 PR review, no direct push
- Branch from `main`, PR back to `main`
- Delete branch after merge
- Rebase or squash merge — no merge commits on `main`

All changes go through a PR, including docs-only ones. There is no trivial-edit exception: a direct push to a protected `main` lands before the required checks report, so they become a postmortem instead of a gate, and it leaves open PRs' branches stale.

---

## Git Worktrees

### Worktree directory

- Use **project-local** worktrees under `.worktrees/` at the repo root (hidden directory)
- `.worktrees/` must be listed in `.gitignore` — add and commit it before creating the first worktree in a repo
- Use a **random, short branch name** when the user does not specify one (e.g. `wt/<8-hex-chars>`); do not prompt for a branch name

Agent tooling that automates worktree creation should discover these rules from `CLAUDE.md` / `AGENTS.md` (e.g. a `worktree.*director` grep) and honour them without asking.

---

## Commit Messages (Conventional Commits)

```text
<type>(<scope>): <short summary>

[optional body]

[optional footer: Closes #<issue>]
```

**Types:** `feat`, `fix`, `test`, `refactor`, `chore`, `docs`, `ci`, `perf`
**Scope:** module or layer name, e.g. `orders`, `auth`, `infra`, `ui`

```text
feat(orders): add order cancellation endpoint

Implements POST /api/v1/orders/{id}/cancel.
Validates order is in Pending state before cancelling.

Closes #42
```

- Subject line: imperative mood, ≤72 chars, no period
- Body: explain *why*, not *what*
- Breaking changes: add `BREAKING CHANGE:` footer (or `!` after the type)

---

## Pull Request Conventions

### PR Title

Follow Conventional Commits format: `feat(orders): add cancellation endpoint`

### PR Description Template

Body sections: **Summary** · **Changes** · **Testing** (unit, component/integration, E2E, local) · **Checklist** (tests pass, no new vulnerable deps, no secrets, migrations included if schema changed, API/OpenAPI spec still valid).

Template: [`.ai/references/base/pr-description-template.md`](https://github.com/freaxnx01/ai-instructions/blob/main/.ai/references/base/pr-description-template.md)

### Review Guidelines

- PRs should be small and focused — one concern per PR
- Reviewers check: architecture adherence, test quality, security, no shortcuts that make tests green
- Auto-assign reviewers via `CODEOWNERS`

---

## CI/CD (generic outline)

Pipeline stages: `build` → `test` → `security-scan` → `container-build` → `push`

- Build and test run on every PR
- Vulnerable-dependency scan fails the build on HIGH/CRITICAL
- Container image built and pushed only on `main` after tests pass
- E2E tests run against the built image before it is marked as a release candidate

Concrete CI configuration (GitHub Actions YAML, commands, package scanners) lives in the stack overlay.

---

## Scripting

**PowerShell — customer-delivered scripts target Windows PowerShell 5.1.** Anything a customer runs (`build.ps1`, install/deploy scripts, release artifacts) must run on 5.1 unless the project documents a PS 7+ floor; `pwsh` is not installed there.

- **Never** use `??`, `??=`, ternary `? :`, `?.`, `&&` / `||` chains — *parse* errors on 5.1, so the script dies before its first line — nor `ForEach-Object -Parallel`, `Sort-Object -Stable`, `-SslProtocol`
- `$IsWindows` / `$IsLinux` / `$IsMacOS` **do not exist** on 5.1 — they are `$null`, so the branch is silently skipped. Use `$env:OS -eq 'Windows_NT'`
- Pass `-Depth` to `ConvertTo-Json` (defaults to 2, truncates silently) and `-UseBasicParsing` to the web cmdlets (a patched host prompts and hangs)
- Start with `#requires -Version 5.1`, pin encoding, verify with PSScriptAnalyzer
- **Exempt:** dev-loop tooling (`justfile` recipes) may require `pwsh`

Full rules: [`powershell-5.1.md`](https://github.com/freaxnx01/ai-instructions/blob/main/.ai/references/base/powershell-5.1.md)

---

## Documentation Structure

Repo-root `docs/` contains:

- `design/<feature-name>/` — UI wireframes (`wireframe.md`) & Mermaid flows (`flow.md`) per feature
- `adr/` — Architecture Decision Records
- `ai-notes/` — AI agent working notes

Rules:

- `README.md` and `CHANGELOG.md` live in the repo root
- UI design artifacts are saved per feature during the UI workflow phases
- AI agents write working notes to `docs/ai-notes/`, not `.ai/`
- `.ai/` is reserved for agent instructions and skill files only

Layout: [`.ai/references/base/documentation-structure.md`](https://github.com/freaxnx01/ai-instructions/blob/main/.ai/references/base/documentation-structure.md)

---

## Security (baseline)

- Transport security enforced (HTTPS + HSTS)
- No secrets in source files or per-environment config files — environment variables or a secrets manager only
- Validate all inputs at system boundaries before any domain logic
- Run a vulnerable-dependency scan in CI — fail the build on HIGH/CRITICAL findings
- Standard security response headers on every HTTP response

Language- and framework-specific enforcement (specific scanners, validation libraries, header mechanisms) lives in the stack overlay.

---

## Agent Guardrails

- Do not install additional packages without asking first
- Do not change the project's target runtime or framework version
- Do not modify build/project files unless the task requires it
- Do not introduce new architectural patterns unless explicitly asked
- Do not touch files outside the scope of the current task
- Keep changes minimal and focused — do not refactor unrelated code unless asked
- Never skip git hooks (`--no-verify`) unless the user explicitly asks
- Never commit secrets or credential files

Stack-specific guardrails (e.g. "do not add NuGet packages") live in the stack overlay.

---

## Project Scaffold Checklist (baseline)

Init-time checklist (every project, regardless of stack) — including baseline, .NET, and WebAPI layers — lives at [`.ai/references/scaffold-checklists.md`](https://github.com/freaxnx01/ai-instructions/blob/main/.ai/references/scaffold-checklists.md). Stack-specific additions are in the same file under their respective sections.

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
