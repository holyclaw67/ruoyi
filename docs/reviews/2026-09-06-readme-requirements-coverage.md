# Report: README / requirements readability + coverage — ruoyi 2.3.2

**Date:** 2026-09-06  
**Mode:** full product (docs + law + suite)  
**Status:** closed for this pass (optional host residuals remain)

## Summary

Product README did not match the product README kit (H1 short-description, Stars banner, required headings, Last Update, plain-language Description). Every registered requirement lacked **§1.1 Human-facing**. Live `about` skipped CLI scratch storage fields that `requirement-shell-cli-storage` already required. This pass rewrote the README, added Human-facing blocks to all 19 registered requirements, wired storage fields into domain `about`, and locked TP-CLI-11.

## Registry inventory

- Registered ∩ disk: **19** (match)
- Orphans: none
- Ghosts: none
- Foreign candidates: none (notes name bootstrap **selfmanaged** as A — intentional)
- Class: software-development; Active `requirement-class-software-dev.md`
- Domain SSOT: `requirement-domain-ruoyi.md` (Area `domain`)

## README human readability

| Gate | Before | After |
|------|--------|-------|
| H1 identity triad | `# ruoyi` only | `# ruoyi - One-command setup for the RuoYi admin framework` |
| Stars / project-repository | missing | `cloudgen/ruoyi` |
| Section order | Quick installation / Platform notes / nested Examples | Quick Installation → Usage → Examples → Platform Compatibility → Related Projects → Contributing → License → Last Update |
| Description voice | Led with Type O-S / Type 0 | Who / boxes / includes / practice |
| Integrity transparency | Outcomes table; no link/value/result sentence | Human mode shows companion **link**, **value**, **result** |

## Requirements human readability

All 19 registered `requirement-*.md` files now have **§1.1 Human-facing** (one sentence, three boxes, includes/excludes, surfaces, practice). Jargon is not the only lead. Coding-style Purpose now states the specialize-in intention (without it, portable lessons arrive raw).

## Ownership matrix (C-full-product)

| Surface | Class | Owner | Status |
|---------|-------|-------|--------|
| empty argv install-ensure | lifecycle | `requirement-shell-cli-zero-arguments` | ok |
| `install` / `version` / `help` / flags | lifecycle | `requirement-shell-cli-interface` | ok |
| `version-check` / `self-update` / `self-uninstall` / `about` | lifecycle | `requirement-shell-self-management` + CLI | ok |
| companion SHA-256 | lifecycle | `requirement-shell-automatic-checksum` | ok |
| `setup` / `mariadb`/`mysql`/`db` / `redis` / `run` / `db-extract` | domain | `requirement-domain-ruoyi` + CLI dual mention | ok |
| `PROJECT_DIR` | project | `requirement-project-folder` | ok |
| scratch resolve | lifecycle | `requirement-shell-cli-storage` | ok (was Gap: `about` omitted fields) |
| PATH / USER_BIN | lifecycle | `requirement-shell-path-and-shell-support` | ok (TP-INST-01) |
| coding style | class residual pointer | `requirement-shell-script-coding` | ok |
| dest approver / dest fences | residual none | class file | ok (considered — none) |

## Tests / checklist

| Item | Result |
|------|--------|
| TP-CLI-01..10 | have (pre-existing) |
| TP-CLI-11 about storage JSON | added this pass |
| TP-CLI-04 `mariadb\|mysql\|db` | tightened this pass |
| TP-INST-01..10 | have |
| TP-DOM-01..07 | have |
| TP-DOM-08 real MariaDB/`run` | optional (host elev) |
| TP-CURL-01 public channel pipe | todo (when published) |
| Checklists `docs/checklists/2026-08-11-*` | prior coverage Sufficient with optional residuals; Pattern A gitignore keeps new checklists local |

## Issues

### Issue 1 -- Severity: bug
- File: `ruoyi` `ruo_about`
- Description: Domain `about` JSON/human omitted `effective_storage` / `storage_dir` while storage law DoD required them (`app_about` still had the fields but dispatcher calls `ruo_about`).
- Suggestion: Merge storage fields into `ruo_about` (done in 2.3.2).
- Test: TP-CLI-11
- Status: closed

### Issue 2 -- Severity: suggestion
- File: `README.md`
- Description: Product README kit incomplete (H1, Stars, heading titles, Last Update, jargon-led pitch).
- Suggestion: Rewrite to write-readme order + human-intro voice (done).
- Status: closed

### Issue 3 -- Severity: suggestion
- File: `docs/requirements/*.md`
- Description: Missing §1.1 Human-facing on every registered requirement.
- Suggestion: Add voice pack after Purpose (done).
- Status: closed

## Residual (honest)

- TP-DOM-08 full `mariadb`/`run` on a dedicated host
- TP-CURL-01 public-channel `curl|bash` after publish
- Backup dated-file assert on second `setup` (TP-DOM-04 still only checks re-entry)
