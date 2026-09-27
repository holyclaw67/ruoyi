**file**: docs/requirements/requirement-shell-least-privilege.md  
**Status**: Active (Version 1.0.0 – specialized from `template-least-privilege-user` / LM-LEAST-PRIVILEGE-USER)  
**Area**: shell  
**Key**: `requirement-shell-least-privilege`  
**Philosophy**: CIAO / CIAO-Lite

## 1. Purpose

SSOT for **command privilege classification** and **internal elevation** for product **ruoyi**. Protects operators from running the entire CLI as root for routine work, while allowing scoped elevation for host package/DB/Redis ops.

**Not:** dedicated long-running system-user service model — **not required** for this product.

### 1.1 Human-facing

**In one sentence:** You run ruoyi as yourself; only MariaDB/MySQL/Redis setup may call `sudo` for packages and services, and you should not prefix the whole command with `sudo` for daily work.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Daily install, setup, run, about | `ruoyi setup --no-run` as yourself |
| The other role | Host package/DB/Redis steps | `ruoyi mariadb` may use internal `sudo` |
| Not this file | A dedicated long-running system account | Not on this product’s surface |

| Includes | Excludes |
|----------|----------|
| Classify every dispatcher command: you / host-elev / dedicated account | Collapsing host-elev into “always `sudo ruoyi`” |
| Internal `sudo` only for apt/service/mysql client ops | Inventing a dest-approver account |

| Surface | What you open | What for |
|---------|---------------|----------|
| `src/ruoyi` | ship unit | internal `sudo` call sites |
| `ruoyi help` | command | which verbs may elevate |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Daily work | Your own login; no whole-CLI sudo. | `ruoyi setup --no-run` |
| Database packages | Tool may ask sudo for that step only. | `ruoyi mariadb` |

## 2. Core rules

### 2.1 Command type classification (mandatory)

Every dispatcher command **MUST** be classified into exactly one type:

| Type | Privilege | Execution | ruoyi commands |
|------|-----------|-----------|----------------|
| **Type 0** | Any user; no special privilege | Direct as invoker | `install`, `version`, `about`, `help`, `version-check`, `self-update`, `self-uninstall`, `setup` (SDKMAN/Java/Maven under user home), `run`, `db-extract`, empty-argv CLI ensure |
| **Type 1** | Elevated for **host** prep | User may invoke; tool uses **internal `sudo`** for privileged sub-steps only | `mariadb`, `mysql`, `db`, `redis` (apt/service/mysql client package ops as designed) |
| **Type 2** | Dedicated system user | Context-switch to app user | **None** on current surface |

**MUST NOT** collapse Type 1 into “always run whole CLI as root.”  
**MUST NOT** treat Type 2 as root.

### 2.2 Internal sudo escalation (sacred for Type 1)

1. Type 1 commands **MUST** attempt internal escalation for privileged sub-steps when invoker is non-root.  
2. Preferred: targeted `sudo` for package/service/mysql ops — not “please re-run entire CLI with sudo” as first UX.  
3. **MUST NOT** cache or log sudo passwords.  
4. **MUST NOT** require external `sudo ruoyi mariadb` as the only supported UX when internal sudo is designed.  
5. Administrator sudoers policy remains host responsibility.

### 2.3 Elev allowlist posture (when OS tools elevated)

When elevating apt/systemctl/mysql:

| Table | Content |
|-------|---------|
| **A — Allowed** | Install MariaDB/MySQL/Redis packages; start/enable service; mysql client create/grant/import as implemented |
| **B — Forbidden** | Arbitrary shell via elevated path; write SSH keys; modify unrelated system users; broad `sudo -i` |
| **C — Ship-unit binding** | Only Table A rows from domain helpers (`db_setup_*`, `setup_redis_for_ruoyi`, …) |

Broaden Table A only via law update + review — not silent script creep.

### 2.4 Dedicated system user

**Not required** for Type 0 CLI self-management or current domain surface. Do not invent `ruoyi` system user as mandatory.

### 2.5 LLM escape / local-default

Agents and product law **MUST NOT** require freestyle external hosts beyond documented channel (`SCRIPT_URL` / RuoYi git clone URL). Prefer local-default operations.

## 3. Implementation Notes (live)

| Item | Value |
|------|--------|
| Type 0 handlers | `inst_*`, `app_*`/`ruo_help`/`ruo_about`, `setup_*` user toolchain, `ruo_build_run`, `db_extract_*` |
| Type 1 handlers | `db_setup`, `db_setup_mariadb`, `db_setup_mysql`, `setup_redis_for_ruoyi` |
| Type 2 | none |
| Peer domain SSOT | `requirement-domain-ruoyi.md` |
| Peer CLI routing | `requirement-shell-cli-interface.md` |

## 4. Protection Rule (Sacred)

**MUST NOT**:

1. Force root for all commands.  
2. Drop internal sudo in favor of “always sudo the binary” without redesign.  
3. Log credentials.  
4. Expand elevation beyond Table A without law change.  
5. Invent mandatory system user without architecture requirement.

## 5. Acceptance criteria

1. Help/about/docs classify privilege for domain elevate commands.  
2. Type 0 lifecycle works as non-root.  
3. Registry row present.
