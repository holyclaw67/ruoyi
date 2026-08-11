# P1 + P2 requirement coverage — filled

**Date:** 2026-08-11  
**Claim:** C-full-product  
**Verdict:** **Sufficient** (P1 mold-depth + P2 law + domain stack smoke for setup --no-run)

## P1 — Deep mold resync

| Target | Action |
|--------|--------|
| online-install | Rewrote v1.1.0 full ownership/matrix/protection |
| path-and-shell-support | Rewrote v1.1.0 path_* + shells |
| backup-strategy | Rewrote v1.1.0 classify/mutate |
| zero-arguments | Appended O-S case matrix + forbidden |
| self-management | Appended layer map + package inventory |
| storage / output | Appended resolve priority + channel rules |

## P1 — Stack smoke (this host)

| Check | Result |
|-------|--------|
| `bash -n ./ruoyi` | PASS |
| Type 0 version/help/about/unknown | PASS |
| `install` CLI | PASS (remote .sha256 may warn if not published) |
| empty argv already-installed | PASS (success no-op) |
| `setup --no-run --project-dir /tmp/…` | **PASS** after set -u / SDKMAN fixes |
| Java 21 + Maven 3.9.14 via SDKMAN | PASS (session sdk path) |
| RuoYi clone + yml backup | PASS |
| `mariadb` / `run` full stack | **Not fully exercised** (optional; DB elev host-dependent) |
| A integrity | PASS |

### Code fixes during smoke (ship unit)

1. `util_src_user_shell_conf` — stop sourcing full `.bashrc` (hang/exit under set -u); source SDKMAN init with `set +u`.  
2. `setup_sdkman` — re-source when dir exists; `set +u` for init; fail loud if sdk missing.  
3. `_ruo_sdk` wrapper for all `sdk install/default/use` under `set +u`.  
4. `app_main` defaults: `NO_RUN`, `PROJECT_DIR`, `PORT`.

## P2 — New REQs from molds

| Mold | REQ |
|------|-----|
| LM-LEAST-PRIVILEGE-USER | `requirement-shell-least-privilege.md` |
| LM-SHELL-SCRIPT-CODING (+ sh-coding-style alias) | `requirement-shell-script-coding.md` |
| LM-ERROR-HANDLING | `requirement-shell-error-handling.md` |

## Registry

- **19** Active `requirement-*.md`  
- orphans/ghosts: none  

## Residual (optional later)

- Full `mariadb` + `run` integration test on dedicated host  
- Publish `ruoyi.sha256` on channel for companion PASS in online install  
