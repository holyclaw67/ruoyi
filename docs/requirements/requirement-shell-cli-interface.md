**file**: docs/requirements/requirement-shell-cli-interface.md  
**Status**: Active (Version 1.0.0)  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered)

## 1. Purpose

This requirement is the **project Single Source of Truth** for the **POSIX shell CLI interface** of the ruoyi tool: command surface, privilege typing, global flags, dispatcher behavior, output modes, and interactive vs non-interactive rules.

It defines a self-managed shell CLI (install / update / uninstall of the tool itself). It does **not** invent host-bootstrap or dedicated-system-user app-ops commands unless a future requirement adds them.

### 1.1 Human-facing

**In one sentence:** This file is the list of commands and flags you can type to `ruoyi`, and how unknown words fail.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Anyone invoking `ruoyi` | `ruoyi help` · `ruoyi version` |
| The other role | Domain verbs owned in depth by the domain file | `setup`, `mariadb`, `run` — also named here for routing |
| Not this file | Checksum algorithm, empty-argv case matrix, `out_*` catalog | Peer shell requirements |

| Includes | Excludes |
|----------|----------|
| Command table, flags, dispatcher, unknown-command fatal | Checksum sidecar policy |
| Dual mention: every live verb is named here **and** on a topic-owner | Treating `help` text as the second law mention |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./ruoyi` | ship unit | `app_main` routing |
| `ruoyi help` | command | listed verbs and flags |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| See the catalog | Help lists every routed verb. Unknown tokens fail with a pointer to help. | `ruoyi help` |
| Unknown word | Loud error; no silent ignore. | `ruoyi no-such-command` |

**Scope:** User-facing command names, flags, dispatch, privilege labels, and mode contracts.  
**Out of scope (own requirements when specialized):** Online-install checksum mechanics detail, self-management safety beyond the command surface, shell coding style, full output-function catalog (cited, not re-owned).

---

## 2. Core Rules / Requirements (Mandatory)

### 2.1 Command surface (portable shape)

Every CIAO-Lite shell CLI **MUST** expose a documented command set. Commands **MUST** map to exactly one privilege type. Unclassified commands are incomplete design.

| Category | Privilege | Meaning | Portable examples |
|----------|-----------|---------|-------------------|
| **Type 0 – Self-management / CLI lifecycle** | Invoking user (no elevation required for user-owned install) | Manage the CLI binary and diagnostics | `version`, `about`, `help`, `version-check`, `self-update`, `self-uninstall` |
| **Type 0 – Install CLI binary** | Invoking user (root → global path; non-root → user path) | First-time or explicit placement of the CLI | `install`; empty argv **Type O install-ensure** (not installed / local / global) — `requirement-shell-cli-zero-arguments.md` |
| **Type 1 – Host preparation** | Elevated (internal escalation when designed) | Host packages (domain DB/Redis via internal sudo) | **Partial** — domain `mariadb`/`mysql`/`redis` may elevate; not full host-bootstrap product |
| **Type 2 – App ops under system user** | Dedicated least-privilege system user | App install/configure/runtime under app identity | *Not in scope for current product surface* |

**Execution rules (core):**

1. Type 0 commands **MUST** run as the invoker without requiring a dedicated system user.
2. Type 1 (when added later) **MUST** use controlled internal escalation; normal users **MUST NOT** be forced to manually prefix every privileged sub-step as a permanent UX rule.
3. Type 2 (when added later) **MUST** run as the dedicated system user (context switch if needed). Mixing Type 1 host bootstrap with Type 2 app toolchain in one command is forbidden (see incident policy under system-user / three-layer privilege terms).
4. Privilege type for each command **MUST** be documented in help and in this requirement’s Implementation Notes.

### 2.2 Global flags (portable)

| Flag | Env / state | Behavior |
|------|-------------|----------|
| `--quiet`, `-q` | `QUIET=1` | Suppress non-error human output; errors and fatal paths still visible |
| `--json` | `JSON=1` (implies quiet) | Machine-readable structured output; no human banner text |
| `--debug` | `DEBUG=1` | Extra diagnostics when designed (must not break JSON purity on stdout) |
| `--force` | Force/reinstall policy vars | Skip safe confirms or force reinstall only where documented; never silent security bypass |

Additional flags **MAY** be added only when documented here (or a superseding requirement) and wired in the dispatcher.

### 2.3 Dispatcher and entry rules (portable)

1. **Single entry:** A single main dispatcher (e.g. `app_main`) **MUST** parse global flags and route commands.
2. **Unknown command:** **MUST** fail loudly with a clear error and pointer to `help` (via output SSOT).
3. **Zero-arg install-ensure:** Empty argv **MUST** mean install-ensure (not help). Not installed → install (TTY may confirm; non-interactive / quiet / json auto). Already installed (global or local) → success no-op (“already installed”), not help and not blind reinstall. Full contract: `requirement-shell-cli-zero-arguments.md`.
4. **Idempotent install skip:** Install **MUST** no-op when already installed unless force/reinstall policy is set.
5. **No raw user I/O:** User-facing messages **MUST** go through the centralized `out_*` system (see output template/term).

### 2.4 Output and mode contracts (portable)

| Mode | Contract |
|------|----------|
| Human (default TTY) | Prefixed messages via `out_*`; colors only when TTY and not quiet/json |
| Quiet | Suppress info/success/plain noise; still show errors / fatal |
| JSON | Force quiet; emit structured JSON via `out_json` / `out_json_error`; no mixed human lines on success path |
| Non-interactive | Never hang on prompts; use safe defaults or `--force`/env policy |

Destructive Type 0 actions (e.g. uninstall) **MUST** confirm when interactive unless force policy is set; non-interactive **MUST NOT** block on stdin.

### 2.5 Help surface (portable)

`help` **MUST** list:

- Usage line  
- Every supported command with one-line purpose  
- Privilege category (at least Type 0 vs elevated vs system-user when those exist)  
- Global flags  

In JSON mode, help **MUST NOT** dump long human text; return a short structured success/note object instead.

### 2.6 Implementation Notes (this project)

| Item | Value for ruoyi |
|------|------------------------|
| **Product / binary name** | `ruoyi` (`APP_NAME`, default `ruoyi`) |
| **Primary executable** | Repo root `./ruoyi` (`#!/bin/bash`, single-file for `curl \| bash`; re-exec into bash when needed) |
| **Dispatcher** | `app_main` (always invoked at end of script: `app_main "$@"` — no `${0##*/}` / APP_NAME basename gate; required for `curl \| sh`) |
| **Output SSOT** | `out_text` + wrappers (`out_info`, `out_success`, `out_warn`, `out_error`, `out_die`, `out_plain`, `out_json`, …) |
| **Version SSOT** | `VERSION` hard-assign `2.3.2` (script header / config block) |
| **Install paths** | Global: `GLOBAL_BIN` default `/usr/local/bin`; User: `USER_BIN` default `${HOME}/.local/bin` |
| **Remote channel env (help surface)** | `REPO_USER` / `REPO_NAME` (defaults `cloudgen` / `ruoyi`); `SCRIPT_URL` composed default `https://raw.githubusercontent.com/${REPO_USER}/${REPO_NAME}/main/${APP_NAME}` (literal product default: `https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi`; override via env). **`help` / `about` MUST list these operator channel vars as designed — MUST NOT list `CHECKSUM`** (install-path runtime pin only; see `requirement-shell-automatic-checksum.md`) |
| **Type 1 / Type 2 surface** | Domain may escalate with **internal `sudo`** for package/DB ops (`mariadb`/`mysql`/`redis`); default CLI lifecycle remains Type 0. Domain catalog: `requirement-domain-ruoyi.md` |
| **Dedicated system user** | **Not required** for Type 0 CLI self-management |

#### Supported commands (normative for this project)

| Command | Type | Handler (current) | Required behavior |
|---------|------|-------------------|-------------------|
| *(no args — empty argv)* | Type 0 | `app_main` → `inst_maybe_install` / `inst_perform_install` | **Type O-S install-ensure** for **CLI ship unit only** (not domain stack); see `requirement-shell-cli-zero-arguments.md` + `requirement-shell-online-install.md` |
| `install` | Type 0 | `inst_perform_install` | Install CLI binary (root→global, user→local); idempotent unless force reinstall |
| `version` | Type 0 | `app_version` | Print local version; JSON when `--json` |
| `about` | Type 0 + domain diagnostics | `ruo_about` | Install state + SDKMAN/Java/Maven/project/port diagnostics; **no `CHECKSUM` field** |
| `version-check` | Type 0 | `ver_check` | Compare local vs remote `VERSION` from `SCRIPT_URL` |
| `self-update` | Type 0 | `inst_self_update` | Reinstall CLI when channel allows |
| `self-uninstall` | Type 0 | `inst_self_uninstall` | Remove managed CLI binary; safe PATH cleanup |
| `help` | Type 0 + domain catalog | `ruo_help` | Domain verbs **and** Type 0; Environment lists channel vars only — **not** `CHECKSUM` |
| `setup` | Domain | `setup_sdkman` → `setup_java_21` → `setup_maven_3_9` → `ruo_clone` → optional `ruo_build_run` | Stack ensure + clone; `--no-run` skips run |
| `mariadb` / `mysql` / `db` | Domain (may elevate) | `db_setup` → engine helpers | DB ensure; internal sudo allowed for package/DB only — see domain SSOT |
| `redis` | Domain (may elevate) | `setup_redis_for_ruoyi` | Redis ensure for RuoYi |
| `run` | Domain | `ruo_build_run` | Build and run `ruoyi-admin` |
| `db-extract` | Domain | `db_extract_credentials` | Extract credentials from `application-druid.yml` |

**Domain ownership:** Full domain semantics, pins, help/about pillars → **`requirement-domain-ruoyi.md`** (Area `domain`). This file owns **routing + help↔dispatcher alignment** for all listed verbs.

#### Global flags (normative wiring for this project)

| Flag | Required wiring |
|------|-----------------|
| `--quiet`, `-q` | Set `QUIET=1` in `app_main` |
| `--json` | Set `JSON=1` and `QUIET=1` in `app_main` |
| `--debug` | Set `DEBUG=1` in `app_main` |
| `--force` | `FORCE=1` and `FORCE_REINSTALL=1`; install reinstall / self-update / uninstall confirm skip |
| `--project-dir PATH` | Set `PROJECT_DIR` for domain ops |
| `--no-run` | With `setup`: skip `ruo_build_run` after clone |

#### Dispatcher acceptance criteria (this project)

1. Unknown token after flag parse → `out_die` with pointer to `ruoyi help`.  
2. Zero-arg → **Type O-S** CLI install-ensure only (not domain stack; not help).  
3. Command routing table in `app_main` **must** include every row in the command table above.  
4. Help text **must** stay aligned with that table (no orphan / unrouted commands).  
5. User-facing strings **must not** use raw `echo`/`printf` outside the `out_*` system (protected low-level helpers excepted).  
6. Domain elevation **MUST NOT** require the user to run the whole CLI under external `sudo` for `mariadb`/`mysql`/`redis` when internal sudo is designed.

#### Explicitly out of scope until a new requirement

- Type O-P payload online install (combined empty-argv CLI+domain stack) — **not** this product’s class (Type **O-S** + explicit domain verbs)  
- Dedicated system user / Type 2 long-running service unit  
- Docker host install as product law  

### 2.7 Why This Requirement Exists (Direct CIAO Alignment)

- **CIAO Principle 1 – Caution** (https://github.com/cloudgen/ciao): Unknown commands fail loud; force and prompts gate destructive ops; quiet/json never hide fatal errors incorrectly.  
- **CIAO Principle 2 – Intentional** (https://github.com/cloudgen/ciao): Every command has one privilege type, one handler, and documented flags.  
- **CIAO Principle 3 – Anti-fragile** (https://github.com/cloudgen/ciao): Works under TTY, `curl | sh`, quiet, and JSON; root vs user install paths.  
- **CIAO Principle 5 – Single Source of Output** and **Principle 14 – Security & Traceability** (https://github.com/cloudgen/ciao): Central `out_*`; JSON/human separation.  
- **CIAO Principle 6 – Single Point of Entry** (https://github.com/cloudgen/ciao): `app_main` is the dispatcher SSOT.  
- **CIAO Principle 10 – Least-Privilege User** (https://github.com/cloudgen/ciao): Type 0 default for CLI self-care; no invented system-user requirement for binary lifecycle.  
- **CIAO Principle 16 – Interactive vs Non-Interactive** (https://github.com/cloudgen/ciao): No hang in non-interactive; prompts only when appropriate.  
- **CIAO Principle 4 (O) / Principle 20 – Over-protect / Protect Against AI & Human Modification** (https://github.com/cloudgen/ciao): Protection Rule below blocks privilege and UX regressions.

---

## 3. Design Principles (CIAO / CIAO-Lite)

- **Caution:** Fail loud on bad input; never silent wrong privilege context.  
- **Intentional:** Command table + help + dispatcher stay synchronized.  
- **Anti-fragile:** Per-user and global install; network/remote optional until `SCRIPT_URL` set.  
- **Over-protect:** Do not collapse Type 0/1/2, remove JSON quiet contract, or reintroduce raw output for user messages.  
- **SSOT:** `APP_NAME` / `VERSION` / flags at config defaults; output via `out_*`; dispatch via `app_main`.  
- **Idempotency:** Already-installed install path is a no-op unless force reinstall.  
- **Respect old working logic:** Surgical changes only; preserve Protection Zones and battle-tested install/self-management helpers unless explicitly redesigning.

---

## 4. Protection Rule (Sacred)

**Future AI assistants, Grok, or maintainers MUST NOT**:

1. Remove or rename the normative Type 0 commands without updating this requirement and help together.  
2. Add Type 1 or Type 2 commands that mix host bootstrap with app toolchain in a single privileged install (three-layer privilege: Type 0 tool self-management must stay separate from Type 1 host bootstrap and Type 2 system-user app ops).  
3. Force manual `sudo` as the only UX for every elevated sub-step when internal escalation is the designed pattern (when Type 1 is introduced).  
4. Bypass `out_*` with raw user-facing `echo`/`printf` for normal messages.  
5. Break the contract that `--json` implies quiet and machine-oriented output.  
6. Drop zero-arg install-ensure for the classic `curl | sh` path (including already-installed success no-op) without an explicit requirement change (`requirement-shell-cli-zero-arguments.md`).  
7. Document flags in help that the dispatcher does not parse (or leave `--force` documented-only).  
8. Invent a dedicated system user as mandatory for Type 0 CLI self-management without a specialized architecture requirement.

**Violating this rule is a critical CLI interface regression.**

---

## 5. Definition of done (CLI interface)

This requirement is satisfied for the ruoyi shell CLI when all of the following hold:

1. Every command in §2.6 is routed and documented.  
2. Global flags in §2.6 are parsed and honored.  
3. Output modes match §2.4 (including JSON purity).  
4. Install privilege paths remain invoker-based (root/global vs user/local).  
5. No Type 1/2 surface claims exist without matching specialized requirements.  
6. Protection Rule items are not violated in code or docs.  
7. Traceability: implementation changes cite this file path / key `requirement-shell-cli-interface`.

---

## 6. Related artifacts

| Artifact | Role |
|----------|------|
| `docs/requirements/requirement-shell-self-management.md` | Lifecycle command semantics |
| `docs/requirements/requirement-shell-output-requirements.md` | Output SSOT and channels |
| `docs/requirements/requirement-shell-interactive-vs-noninteractive.md` | TTY / automation mode behavior |
| `docs/requirements/requirement-shell-cli-zero-arguments.md` | Empty argv install-ensure (not installed / local / global) |
| `docs/requirements/requirement-shell-idempotency.md` | Re-run safety for ensure ops |
| `docs/requirements/requirement-shell-modular-function-design.md` | Prefix ownership (`app_`, `inst_`, `out_*`) |
| `docs/requirements/index.md` | Registry SSOT |
| `./ruoyi` | Implementation under test |

---

**Last Updated**: 2026-07-19  
**Owner**: ruoyi project maintainers  
**Alignment**: Registry `docs/requirements/index.md`; CIAO Principles 1, 2, 3, 5, 6, 10, 16, 4, 20 (v2.10.2) (https://github.com/cloudgen/ciao); CIAO-Lite (https://github.com/cloudgen/ciao-lite).

## Design-time verification (product)

| TP family | Suite |
|-----------|-------|
| TP-CLI-* | `tests/test_cli.sh` |
