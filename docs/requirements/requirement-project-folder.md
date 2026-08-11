**file**: docs/requirements/requirement-project-folder.md  
**Status**: Active (Version 1.0.0 – specialized from mold `template-project-folder`)  
**Area**: project  
**Key**: `requirement-project-folder`  
**Philosophy**: CIAO / CIAO-Lite

## 1. Purpose

SSOT for **folder ownership** of the ruoyi CLI (Type 1 tool folders) vs the **RuoYi application project** (Type 2 target folder under `PROJECT_DIR`).

## 2. Core rules

### 2.1 Type 1 — CLI tool folders

| Kind | Path pattern | Purpose |
|------|--------------|---------|
| User install | `${USER_BIN}/ruoyi` | Placed binary |
| Global install | `${GLOBAL_BIN}/ruoyi` | Placed binary |
| Cache / scratch | `${XDG_CACHE_HOME}/ruoyi-${USERNAME}` and/or `/dev/shm/ruoyi-…` | Effective storage (`requirement-shell-cli-storage.md`) |

### 2.2 Type 2 — target application project folder

| Variable | Live default | Rules |
|----------|--------------|-------|
| `PROJECT_NAME` | `ruoyi-demo` | Path-safe name |
| `PROJECT_DIR` | `${HOME}/${PROJECT_NAME}` | Overridable via `--project-dir` |
| Contents | Official RuoYi clone + local config edits | Domain owns clone/build |

1. **MUST** keep Type 2 project under the invoking user’s home by default (not forced under root’s home when user runs domain without sudo).  
2. **MUST** refuse dangerous deletes (`/`, `$HOME`, empty) for project wipe.  
3. **MUST NOT** treat Type 1 CLI install path as the RuoYi Java project path.

## 3. Implementation Notes

| Item | Live |
|------|------|
| Domain clone | `ruo_clone` into `PROJECT_DIR` |
| Override | `--project-dir PATH` in `app_main` |
| Peer storage | Effective scratch for CLI ops: `requirement-shell-cli-storage.md` |

## 4. Protection Rule

**MUST NOT** conflate `INSTALL_PATH` with `PROJECT_DIR`, or `rm -rf` project without path safety + backup policy.

## 5. Acceptance criteria

1. Defaults documented and match ship unit Config.  
2. Override flag wired.  
3. Registry row present.
