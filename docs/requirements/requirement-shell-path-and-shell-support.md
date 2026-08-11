**file**: docs/requirements/requirement-shell-path-and-shell-support.md  
**Status**: Active (Version 1.1.0 – P1 mold-depth from `template-path-and-shell-support`)  
**Area**: shell  
**Key**: `requirement-shell-path-and-shell-support`  
**Philosophy**: CIAO / CIAO-Lite

## 1. Purpose

SSOT for **install path Config variables** and **shell PATH integration** after **user-bin** install of `ruoyi`. Global install **MUST NOT** require user rc edits.

## 2. Installation paths

### 2.1 Shell variables (install path Config SSOT)

| Variable | Role | Live default |
|----------|------|--------------|
| `GLOBAL_BIN` | System install directory | `/usr/local/bin` |
| `USER_BIN` | Per-user install directory | `${HOME}/.local/bin` |
| `INSTALL_PATH` | Selected target for this run | privilege-dependent (`$GLOBAL_BIN/$APP_NAME` or `$USER_BIN/$APP_NAME`) |
| `APP_NAME` | Binary basename | `ruoyi` |
| `HOME` | User home (resolved under `set -u` before `USER_BIN`) | passwd / env / `/tmp` fallback as shipped |

**MUST** resolve `HOME` before expanding `USER_BIN` under `set -u` (INC-style defensive order).

## 3. PATH configuration (shell-path-integration)

### Supported shells (recommended)

| Shell | Config file |
|-------|-------------|
| Bash | `~/.bashrc` |
| Zsh | `~/.zshrc` |
| Fish | `~/.config/fish/config.fish` |

Unknown shells → clear warn + manual PATH instruction (not silent fail of whole install).

### Required functions (prefix `path_`)

| Function | Role |
|----------|------|
| `path_in` | Test whether a directory is already on PATH |
| `path_add_shell` | Orchestrator — run per-shell helpers; restart hint |
| `path_add_bashrc` | Ensure `USER_BIN` export in `~/.bashrc` if file exists |
| `path_add_zshrc` | Ensure `USER_BIN` export in `~/.zshrc` if file exists |
| `path_add_fish` | Ensure `USER_BIN` in Fish config when designed |

Rules:

1. **MUST** be idempotent (`grep -qF "${USER_BIN}"` before append).  
2. **MUST** append installer comment with `APP_NAME` + `VERSION`.  
3. Prefer only modify files that already exist (bash/zsh); fish may create config dir when designed.  
4. User-visible lines via `out_*` (class-C printf only for file redirects).  
5. **MUST NOT** use bare names like `add_path()` without `path_` prefix.  
6. Call site: **after user-bin atomic install success only** — not root/global install path.

## 4. Implementation Notes (this project)

| Item | Live |
|------|------|
| Functions present on ship unit | `path_in`, `path_add_shell`, `path_add_bashrc`, `path_add_zshrc`, `path_add_fish` |
| Call site | User install success branch inside `inst_perform_install_atomic_install` (or equivalent) |
| Domain `PROJECT_DIR` | **Not** this file — `requirement-project-folder.md` |

## 5. Protection Rule (Sacred)

**MUST NOT**:

1. Hard-require a single shell only.  
2. Drop PATH integration silently for user-bin installs.  
3. Write secrets into shell rc files.  
4. Modify system-wide profiles from user install without explicit design.  
5. Conflate PATH integration with domain `PROJECT_DIR` setup.

## 6. Acceptance criteria

1. User-bin install documents PATH next steps when not on PATH.  
2. `path_*` prefixes preserved.  
3. Idempotent re-run does not duplicate PATH lines.  
4. Registry row present.
