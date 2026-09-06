**file**: docs/requirements/requirement-shell-script-coding.md  
**Status**: Active (Version 1.0.0 – specialized from `template-shell-script-coding` / LM-SHELL-SCRIPT-CODING; alias mold `template-sh-coding-style` points here)  
**Area**: shell  
**Key**: `requirement-shell-script-coding`  
**Philosophy**: CIAO / CIAO-Lite

## 1. Purpose

SSOT for **shell coding style** of ship unit `./ruoyi` (bash shebang for SDKMAN domain; lifecycle core remains POSIX-style defensive patterns inherited from selfmanaged).

**Intention:** without this file, portable learned lessons arrive **raw** (agents would treat coding skills as product law). This file is the specialize-in home; peer requirements still own output, prefixes, TTY, and temps — this file **points**, it does not duplicate those bodies.

**Alias note:** a portable coding-style alias is findability-only; this specialized file is product law (not a second body of that alias).

### 1.1 Human-facing

**In one sentence:** Maintainers write the ruoyi script in a shared style (named prefixes, no global `set -e`, fail with `out_die`) so later edits do not arrive as a random mix of habits.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Maintainer changing `./ruoyi` | `bash -n ./ruoyi`; `set -u` with `HOME` unset still works |
| The other role | Peer files that already own output / prefixes / TTY | Point; do not copy the full tables here |
| Not this file | User-facing command names | `requirement-shell-cli-interface` |

| Includes | Excludes |
|----------|----------|
| Shebang, `set -u`, prefix names, `out_die` instead of global `set -e` | Treating a coding skill as product law |
| Specialize-in home for later portable lessons | Second copy of the full `out_*` catalog |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./ruoyi` | ship unit | style under test |
| `./tests/run.sh` | suite | TP-CLI-01 syntax, TP-CLI-08 `HOME` unset |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Syntax check | The file must parse as bash. | `bash -n ./ruoyi` |

## 2. Core rules

### 2.1 Runtime

1. Shebang **`#!/bin/bash`** while SDKMAN/Java domain requires bash; re-exec into bash when invoked under non-bash for file path.  
2. Pipe one-liner **SHOULD** use `bash` (`curl … | bash`).  
3. Under `set -u`; **MUST NOT** use global `set -e` as sole error strategy — use explicit `out_die` / checks.  
4. Prefer POSIX-portable constructs in Type 0 core; domain may use bash features only where required and documented.

### 2.2 Function naming (mandatory)

| Prefix | Category | Live examples |
|--------|----------|---------------|
| `out_` | Output SSOT | `out_info`, `out_die`, `out_json` |
| `inst_` | Install / self-management | `inst_perform_install`, `inst_self_update` |
| `util_` | Utilities | `util_backup`, `util_resolve_storage`, `util_sha256_file` |
| `app_` | Generic CLI surface | `app_main`, `app_version` (help/about may be domain-aware wrappers) |
| `ver_` | Version compare | `ver_check`, `ver_gt` |
| `path_` | PATH integration | `path_add_shell`, `path_add_bashrc` |
| `ruo_` / `db_` / `setup_` / `env_` / `debconf_` | **Domain** | `ruo_clone`, `db_setup_mariadb`, `setup_sdkman` |

**MUST NOT** put domain ops under `app_*` or generic lifecycle under domain prefixes only.

### 2.3 Function structure

Public/complex functions **SHOULD** carry GENERAL PURPOSE header, CIAO notes, and Protection Zone warnings on critical install/dispatch paths.  
**MUST NOT** strip Protection Zones for brevity.

### 2.4 SSOT principles

| Concern | SSOT |
|---------|------|
| Identity / version / channel | Config hard-assign + defaults |
| User messages | `out_*` only |
| Install orchestration | `inst_perform_install*` |
| Dispatch | `app_main` |

### 2.5 General coding rules

1. Quote variables; handle empty paths.  
2. No bash arrays required in Type 0 core if avoidable.  
3. `.` for sourcing when needed (not `source`) in portable helpers.  
4. Traps for temp cleanup on install paths.  
5. Interactive prompts only when TTY; never hang non-interactive (`requirement-shell-interactive-vs-noninteractive.md`).  
6. Type 1 elev traps: no `$(sudo …)` password swallowing patterns that hang non-TTY — follow elev design in least-privilege peer.

### 2.6 Compatibility

Harsh environments: Alpine, containers, `curl|bash`, minimal PATH. Domain may require bash + network for SDKMAN.

## 3. Implementation Notes

| Item | Live |
|------|------|
| Ship unit | `./ruoyi` |
| Bootstrap architecture | from `./selfmanaged` (A) |
| Modular peer | `requirement-shell-modular-function-design.md` |
| Output peer | `requirement-shell-output-requirements.md` |
| Privilege peer | `requirement-shell-least-privilege.md` |

## 4. Protection Rule (Sacred)

**MUST NOT**:

1. Replace `out_*` with raw echo for user prose.  
2. Drop `app_main` always-on entry for pipe safety.  
3. Flatten prefixes into unprefixed helpers as default style.  
4. “Simplify” Protection Zones on install/dispatch.  
5. Cite this file’s mold path as runtime authority in product source (cite this requirement only).

## 5. Acceptance criteria

1. Prefix table matches ship unit inventory.  
2. `bash -n ./ruoyi` clean.  
3. Registry row present.
