**file**: docs/requirements/requirement-shell-backup-strategy.md  
**Status**: Active (Version 1.1.0 – P1 mold-depth from `template-backup-strategy`)  
**Area**: shell  
**Key**: `requirement-shell-backup-strategy`  
**Philosophy**: CIAO / CIAO-Lite

## 1. Purpose

SSOT for **dated backup before destructive mutation** of project trees and config files touched by domain ops (clone replace, yml rewrite). Complements install staging (temp download) which is owned by online-install / self-management.

## 2. Classify data before mutate (mandatory)

| Data class | Examples | Backup required before destructive mutate? |
|------------|----------|-----------------------------------------------|
| **Missing target** | empty `PROJECT_DIR` | N/A — create |
| **User-edited project tree** | existing RuoYi clone under `PROJECT_DIR` | **Yes** before `rm -rf` / force re-clone |
| **Config with credentials** | `application-druid.yml` | **Yes** before rewrite |
| **CLI binary replace** | `inst_perform_install` staging | Install orchestrator owns temp stage (not this file’s tree backup) |
| **Ephemeral scratch** | `/dev/shm/ruoyi-*` | No durable backup requirement |

## 3. When dated file/folder backup is required

### 3.1 File naming

Prefer co-located or cache-side dated suffixes via `util_backup` (or equivalent).  
**MUST NOT** use a single fixed backup name that loses history on second run without a date/unique component.

### 3.2 Folder naming (project data)

When backing up a whole `PROJECT_DIR`, use dated folder or archive name; refuse backup destination that is `/`, `$HOME`, or empty.

### 3.3 Mandatory practices (when backup applies)

1. Backup **before** mutate.  
2. Fail loud **or** warn per helper contract — document which destructive paths require hard fail vs warn-and-continue.  
3. Live domain yml rewrite: backup first (domain SSOT).  
4. Force re-clone: backup existing tree first when present.  
5. Never log secrets from credential files into backup names.

## 4. What this principle is not

- Not a full disaster-recovery product  
- Not git history replacement  
- Not install-channel companion digest (that is automatic-checksum)  

## 5. Implementation Notes

| Item | Live |
|------|------|
| Helper | `util_backup` |
| Call sites | `ruo_clone` pre-remove; DB setup yml mutation path |
| Domain ownership of when rewrite allowed | `requirement-domain-ruoyi.md` |
| Path safety on delete | refuse `/`, `$HOME`, empty `PROJECT_DIR` |

## 6. CIAO alignment

Caution (backup first), Anti-fragile (recoverable mistakes), Over-protect (path refuse list).

## 7. Protection Rule (Sacred)

**MUST NOT** delete existing project trees without backup-or-confirm policy, invent “backup” that overwrites the only recovery copy, or store credentials in world-readable shared paths by design.

## 8. Acceptance criteria

1. Destructive project replace path calls backup helper.  
2. Yml credential rewrite path backs up first when designed.  
3. Registry row present.
