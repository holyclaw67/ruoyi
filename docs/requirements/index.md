# Requirements index

**Product:** ruoyi (RuoYi admin framework one-command setup CLI)  
**Workspace state:** Specialized software-development product (bootstrap A = selfmanaged; domain B = ruoyi).  
**Updated:** 2026-09-27 (ship unit `src/ruoyi`; version 2.3.5)

| ID / key | Title | Area | Status | Path | Updated |
|----------|-------|------|--------|------|---------|
| requirement-class-software-dev | Software-development class law + residual stack | class | Active | `requirement-class-software-dev.md` | 2026-09-06 |
| requirement-bootstrap-chain | Bootstrap hop table selfmanaged → ruoyi (A→B only) | bootstrap | Active | `requirement-bootstrap-chain.md` | 2026-09-06 |
| requirement-domain-ruoyi | RuoYi domain four pillars + privilege/backup peers | domain | Active | `requirement-domain-ruoyi.md` | 2026-09-06 |
| requirement-project-folder | CLI install folders vs PROJECT_DIR app project | project | Active | `requirement-project-folder.md` | 2026-09-06 |
| requirement-shell-automatic-checksum | Automatic companion-digest integrity | shell | Active | `requirement-shell-automatic-checksum.md` | 2026-09-06 |
| requirement-shell-backup-strategy | Dated backup before project/yml mutate | shell | Active | `requirement-shell-backup-strategy.md` | 2026-09-06 |
| requirement-shell-cli-interface | Shell CLI interface (lifecycle + domain routing) | shell | Active | `requirement-shell-cli-interface.md` | 2026-09-06 |
| requirement-shell-cli-storage | Per-login per-process cache folder + persistence `${HOME}/.local/${APP_NAME}` | shell | Active (1.1.0) | `requirement-shell-cli-storage.md` | 2026-09-27 |
| requirement-shell-cli-zero-arguments | Empty argv CLI install-ensure (script-alone) | shell | Active | `requirement-shell-cli-zero-arguments.md` | 2026-09-06 |
| requirement-shell-error-handling | Defensive error handling (out_die / fail-fast) | shell | Active | `requirement-shell-error-handling.md` | 2026-09-06 |
| requirement-shell-idempotency | Shell idempotency / re-run safety | shell | Active | `requirement-shell-idempotency.md` | 2026-09-06 |
| requirement-shell-interactive-vs-noninteractive | Interactive vs non-interactive / curl|bash | shell | Active | `requirement-shell-interactive-vs-noninteractive.md` | 2026-09-06 |
| requirement-shell-least-privilege | Privilege map + internal sudo for domain elev | shell | Active | `requirement-shell-least-privilege.md` | 2026-09-06 |
| requirement-shell-modular-function-design | Modular prefixes (out_/inst_/ruo_/db_/setup_) | shell | Active | `requirement-shell-modular-function-design.md` | 2026-09-06 |
| requirement-shell-online-install | Online one-liner install (script-alone channel) | shell | Active | `requirement-shell-online-install.md` | 2026-09-06 |
| requirement-shell-output-requirements | Central out_* output SSOT | shell | Active | `requirement-shell-output-requirements.md` | 2026-09-06 |
| requirement-shell-path-and-shell-support | Install paths + PATH integration | shell | Active | `requirement-shell-path-and-shell-support.md` | 2026-09-06 |
| requirement-shell-script-coding | Shell coding style (specialize-in home) | shell | Active | `requirement-shell-script-coding.md` | 2026-09-06 |
| requirement-shell-self-management | Self-management lifecycle | shell | Active | `requirement-shell-self-management.md` | 2026-09-06 |

**Rules for agents:**

1. Treat rows above as the **live product-law inventory** for ruoyi.  
2. **Do not invent** additional `requirement-*.md` paths — verify on disk and add a registry row in the same change.  
3. Product source comments cite **only** these live requirement files — never `template-*` / `skill-*` as behavioral authority.  
4. Domain catalog ownership is **`requirement-domain-ruoyi`** (Area `domain`).  
5. Install-mode: **online Type O-S only** (not dual local-self-managed; not Type O-P payload empty-argv).  
6. Privilege map: **`requirement-shell-least-privilege`**.  
7. Bootstrap direction is **selfmanaged → ruoyi** only (`requirement-bootstrap-chain`).  
8. Keep Status and Path in sync with each file’s header when status changes.

When adding a requirement: append a row, create the file under `docs/requirements/`, keep Status in sync with the file header.
