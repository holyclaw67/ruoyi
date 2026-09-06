**file**: docs/requirements/requirement-shell-online-install.md  
**Status**: Active (Version 1.1.0 – P1 mold-depth resync from `template-online-install` / LM-ONLINE-INSTALL)  
**Area**: shell  
**Key**: `requirement-shell-online-install`  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

Single Source of Truth for **online one-liner install** of the **ruoyi CLI ship unit**: pipe-safe bootstrap, channel Config composition, atomic place, integrity, user vs system paths, post-install UX, and alignment with empty-argv install-ensure of the CLI command only.

### 1.1 Human-facing

**In one sentence:** You install ruoyi with a copy-paste `curl | bash` line; that places the command in `~/.local/bin` (or `/usr/local/bin` as root).

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Newcomer installing the command | User one-liner without `sudo` |
| The other role | Root / system-wide place | `sudo bash` one-liner |
| Not this file | Cloning RuoYi / starting the admin app | `ruoyi setup` / `ruoyi run` |

| Includes | Excludes |
|----------|----------|
| Literal channel URL one-liners; user vs global paths | Empty-argv also ensuring the Java stack |
| Pipe-safe `app_main "$@"` (no `$0` basename gate) | Dual local-checkout install class |

| Surface | What you open | What for |
|---------|---------------|----------|
| README Quick Installation | product docs | copy-paste one-liners |
| `./ruoyi` | ship unit | `SCRIPT_URL` default |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| User install | Command lands in `~/.local/bin/ruoyi`. | `curl -fsSL https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi \| bash` |
| System-wide | Command lands in `/usr/local/bin/ruoyi`. | `curl -fsSL https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi \| sudo bash` |

**Product class:** **Type O-S** (script-alone). Domain stack ensure is **not** part of empty-argv — see `requirement-domain-ruoyi.md` and `requirement-shell-cli-zero-arguments.md`.  
**Not Type O-P:** do not use `template-payload-online-install` as this product’s empty-argv law unless product class is intentionally reclassified.

### 1.0 Ownership map (anti-duplication)

| Concern | Owner |
|---------|--------|
| Pipe bootstrap + channel + atomic place of **CLI** | **This file** |
| Empty-argv case matrix (O-S) | `requirement-shell-cli-zero-arguments.md` |
| Companion / pin integrity | `requirement-shell-automatic-checksum.md` |
| Lifecycle `version-check` / `self-update` / `self-uninstall` | `requirement-shell-self-management.md` |
| PATH integration after user-bin install | `requirement-shell-path-and-shell-support.md` |
| Domain stack (SDKMAN/Java/DB/run) | `requirement-domain-ruoyi.md` |
| Command table / flags | `requirement-shell-cli-interface.md` |
| Output SSOT | `requirement-shell-output-requirements.md` |

### Identity SSOT (live)

| Field | Value |
|-------|--------|
| **APP_NAME** | `ruoyi` |
| **VERSION** | `2.3.3` |
| **REPO_USER** / **REPO_NAME** | `cloudgen` / `ruoyi` |
| **SCRIPT_URL** | `https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi` |
| **One-liner (user)** | `curl -fsSL https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi \| bash` |
| **One-liner (global)** | `curl -fsSL https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi \| sudo bash` |
| **Shebang** | `#!/bin/bash` (+ re-exec when installed path invoked under non-bash) |
| **Dispatcher** | `app_main "$@"` always (no `$0` basename gate) |
| **Install-mode package** | **Online-only** Type O-S (not dual local-self-managed; not bare `uninstall` as online remove) |

## 2. Supported installation methods

### 2.1 User installation (recommended)

Non-root one-liner → place `${USER_BIN}/ruoyi` (default `~/.local/bin/ruoyi`) and integrate PATH when needed.

### 2.2 System-wide installation

Root one-liner / elevated install → `${GLOBAL_BIN}/ruoyi` (default `/usr/local/bin/ruoyi`).

### 2.3 Channel Config composition

| Variable | Family | Role | Live default |
|----------|--------|------|--------------|
| `APP_NAME` | identity | Binary / raw file segment | hard-assign `ruoyi` + `: "${APP_NAME:=ruoyi}"` |
| `VERSION` | identity | Local version SSOT | hard-assign `2.3.3` |
| `REPO_USER` | channel | Git owner | `cloudgen` |
| `REPO_NAME` | channel | Git repo | `ruoyi` |
| `SCRIPT_URL` | channel | Full install channel URL | composed from REPO_* + APP_NAME; env override allowed |
| `CHECKSUM` | integrity | Optional strict pin (secondary) | empty default; **not** listed in help/about |
| `REMOTE_VERSION` | install op | Messaging / compare seed | empty until fetch; else `$VERSION` |
| `FORCE_REINSTALL` | install op | Force re-download/replace | `0` |

## 3. Core requirements

### 3.0 Shell CLI bootstrap (mandatory)

| How the user runs it | Typical `${0##*/}` | Entry expectation |
|----------------------|--------------------|-------------------|
| Installed binary / `./ruoyi` | Often `ruoyi` | Call `app_main` |
| `bash /path/to/ruoyi` | File basename | Call `app_main` |
| `curl … \| bash` / `… \| sudo bash` | **`bash`** / **`sh`** / … | **Must still call `app_main`** |

#### 3.0.1 Forbidden bootstrap patterns

**MUST NOT** gate the only call to main solely on process `$0` matching product filename or Config app name (silent no-op under pipe).

#### 3.0.2 Required bootstrap behavior

1. **MUST** invoke `app_main "$@"` when executed **or** piped into a shell.  
2. Preferred: always call main at end of file; `source` unsupported.  
3. Empty-argv install-ensure lives **inside** dispatcher after bootstrap succeeds.  
4. Regression: at least one check should feed script on stdin to `bash` and prove dispatcher entry.

### 3.0a Empty argv = Type O-S install-ensure (mandatory)

Full matrix: `requirement-shell-cli-zero-arguments.md`. Summary:

| Case | Empty argv, force **off** |
|------|---------------------------|
| **A. Not installed** | Install CLI ship unit (TTY may confirm; non-TTY/quiet/json **auto**) |
| **B. Installed — local** | Success no-op (not help; **not** domain setup) |
| **C. Installed — global** | Success no-op |

Empty argv **MUST NOT** run domain `setup`/SDKMAN/project pipeline (that would be Type O-P).

#### Forbidden empty-argv outcomes

| Forbidden | Why |
|-----------|-----|
| Full help when Case B/C | Looks broken |
| Silent exit 0 when Case A should install | False confidence |
| Blind re-download every one-liner without force | Breaks idempotency |
| Requiring `--force` only because already installed | Force is replace, not ensure |
| Basename gate so pipe never reaches empty-argv | §3.0 regression |

### 3.0b Payload products — pointer only

Type O-P law is **out of scope**. Do not implement combined ensure solely by changing O-S Cases B/C.

### 3.1 Atomic & safe installation

1. Download to unique temp via `mktemp`  
2. Verify companion `.sha256` and/or `CHECKSUM` pin (peer automatic-checksum)  
3. Atomic move to `INSTALL_PATH`; `chmod +x`  
4. Cleanup staging on failure  
5. Fail loud non-zero on integrity failure  

### 3.2 Checksum protection

- **Default:** automatic companion `${SCRIPT_URL}.sha256` (primary)  
- **Secondary:** env pin `CHECKSUM=<sha256>` strict  
- **help/about MUST NOT** list or print pin env name/value  

### 3.3 User vs system installation logic

- Non-root → user bin; root → global bin  
- After user-bin install: PATH integration per `requirement-shell-path-and-shell-support.md`  
- Orchestrator prefix: `inst_*`  
- Channel vars are **not** install-directory vars  

### 3.4 Post-install actions

- Success via `out_*` with next steps  
- Zero-arg behavior is §3.0a  
- Non-interactive: never hang on prompts  

### 3.5 Idempotency

Already installed (local or global) → success no-op on empty argv / `install` unless force; see `requirement-shell-idempotency.md`.

### 3.6 Function inventory (names only — live ship unit)

| Function | Role |
|----------|------|
| `inst_perform_install` | Orchestrator |
| `inst_maybe_install` | TTY confirm path when not installed |
| `inst_perform_install_prepare_target` | Ensure bin dir |
| `inst_perform_install_download_with_checksum` | Pin path |
| `inst_perform_install_download_without_checksum` | Companion path |
| `inst_perform_install_atomic_install` | Place + PATH hook |
| `util_sha256_file` | Digest helper |
| `util_fetch_remote_version` | Remote VERSION extract |

## 4. Implementation Notes (this project)

| Item | Live |
|------|------|
| Install orchestrator | `inst_perform_install` / helpers as shipped in `./ruoyi` |
| Empty argv branch | Top of `app_main` before help default |
| Domain after install | Explicit `setup` / `run` / `mariadb` — not empty argv |
| Companion digest file | `ruoyi.sha256` at publish time |

## 5. Why this pattern exists (CIAO)

Caution (loud integrity), Intentional (channel SSOT), Anti-fragile (pipe + dual paths), Over-protect (no silent basename gate).

## 6. Protection Rule (Sacred)

**MUST NOT**:

1. Reintroduce `$0` basename gate as sole entry.  
2. Make empty argv dump help when CLI already installed.  
3. Treat empty argv as domain payload ensure without reclassifying to Type O-P.  
4. List `CHECKSUM` in help/about as primary install story.  
5. Dual-mode local-self-managed **and** online install without dual-mode matrix (default: **online-only**).  
6. Use bare online `uninstall` as primary remove name (online remove = `self-uninstall`).

## 7. Verification (minimum)

| Check | Expect |
|-------|--------|
| Piped bash entry | Reaches `app_main` |
| Empty argv A | Installs CLI or fails non-zero |
| Empty argv B/C | Already-installed success, not help |
| Channel defaults | cloudgen/ruoyi |
| Companion path | Documented + implemented |

## 8. Acceptance criteria

1. Pipe-safe bootstrap holds.  
2. Type O-S empty-argv matrix holds.  
3. Atomic install + integrity path hold.  
4. Registry row present in `index.md`.

## Design-time verification (product)

| TP-ID | Suite |
|-------|-------|
| TP-INST-01/02/08 | install, idempotent, integrity transparency |
| TP-CLI-02 | companion digest matches ship unit |
