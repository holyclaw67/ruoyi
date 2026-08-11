**file**: docs/requirements/requirement-domain-ruoyi.md  
**Status**: Active (Version 1.0.0 – specialized from selfmanaged A + domain oracle)  
**Area**: domain  
**Key**: `requirement-domain-ruoyi`  
**Philosophy**: CIAO / CIAO-Lite (Caution • Intentional • Anti-fragile • Over-engineered / Over-protect)

## 1. Purpose

This requirement is the **Domain SSOT** for product **ruoyi** (B): one-command setup of the **RuoYi admin framework** stack (SDKMAN / Java 21 / Maven, project clone, MariaDB/MySQL, Redis, build/run, credential extract) — **beyond** Type 0 CLI self-management inherited from bootstrap **selfmanaged** (A).

**Direction:** A (`selfmanaged`) → B (`ruoyi`) only. Domain law lives **only** on B. Do not reverse-copy domain onto A.

**Out of scope (peer shell REQs own):** ship-unit install/self-update/self-uninstall detail; empty-argv Type O install-ensure for the CLI binary; automatic companion checksum; `out_*` catalog; modular Type 0 prefixes.

### Identity SSOT (this product — live ship unit `./ruoyi`)

| Field | Live value |
|-------|------------|
| **APP_NAME** | `ruoyi` |
| **VERSION** | `2.3.1` |
| **REPO_USER** / **REPO_NAME** | `cloudgen` / `ruoyi` |
| **SCRIPT_URL** | `https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi` |
| **Shebang / runtime** | `#!/bin/bash` (SDKMAN/Java domain requires bash; re-exec when needed) |
| **Dispatcher** | `app_main` |
| **Output SSOT** | `out_*` family (domain may use `msg` as plain alias) |
| **Install SSOT** | `inst_*` (Type 0 ship unit) |
| **Domain prefixes** | `ruo_*`, `db_*`, `setup_*`, `env_*`, `debconf_*` |

---

## 2. Four pillars (domain requirements)

### 2.1 Specialized CLI subcommands

| Verb | Handler / pipeline | Notes |
|------|--------------------|-------|
| `setup` | `setup_sdkman` → `setup_java_21` → `setup_maven_3_9` → `ruo_clone` → optional `ruo_build_run` | Stack ensure + project |
| `mariadb` / `mysql` / `db` | `db_setup` → engine-specific `db_setup_*` | May escalate with internal `sudo` for package/DB ops; **MUST NOT** require user to prefix whole CLI with sudo |
| `redis` | `setup_redis_for_ruoyi` | Install/start Redis for RuoYi |
| `run` | `ruo_build_run` | Build and run `ruoyi-admin` |
| `db-extract` | `db_extract_credentials` | Read credentials from `application-druid.yml` |
| Type 0 retained | `install`, `version`, `about`, `help`, `version-check`, `self-update`, `self-uninstall` | From A; `about`/`help` domain-aware (`ruo_about` / `ruo_help`) |

**Flags (domain-related):** `--project-dir PATH`, `--no-run`, plus global Type 0 `--quiet`/`--json`/`--force`/`--debug`.

**Empty argv:** Type O install-ensure for the **CLI ship unit** only (peer `requirement-shell-cli-zero-arguments.md`). Domain stack ensure is **explicit** `setup` / `run` (not silent payload of empty argv unless a future Type O-P decision is recorded).

### 2.2 Specialized features

| Feature | Contract |
|---------|----------|
| **Java pin** | `JAVA_ID=21.0.10-tem`, `JAVA_VERSION=21` (Temurin) via SDKMAN |
| **Maven pin** | `MAVEN_VER=3.9.14` |
| **Project** | Default `PROJECT_DIR=${HOME}/ruoyi-demo`; overridable |
| **Git clone** | Official RuoYi tree via `RUOYI_GIT_REPO` (default Gitee RuoYi) |
| **Port** | `PORT=8080` written/used for admin app |
| **DB** | MariaDB preferred; MySQL path supported; check existing user/password in yml **before** create; backup yml before mutation |
| **Credentials extract** | Parse `application-druid.yml` without printing secrets in non-JSON human noise unless commanded |
| **Non-goals** | Not a general Java installer; not reverse-copy into selfmanaged; not inventing alternate admin frameworks |

### 2.3 Specialized project help items

`ruo_help` **MUST** list:

1. Domain verbs: `setup`, `mariadb`/`mysql`/`db`, `redis`, `run`, `db-extract`  
2. Type 0 verbs retained from A  
3. `--project-dir`, `--no-run`, global flags  
4. Channel env: `REPO_*` / `SCRIPT_URL`  
5. Examples for curl\|bash install and domain ops  

Help ↔ dispatcher alignment is mandatory (no advertised-but-unrouted domain verb).

### 2.4 Specialized project about items

`ruo_about` **MUST** report:

1. Install state of CLI  
2. SDKMAN / Java / Maven presence  
3. `PROJECT_DIR` existence  
4. App listening status on `PORT`  
5. Version string `VERSION`  

JSON mode when `--json` follows shell output SSOT.

---

### 2.5 Privilege and backup (mold-aligned)

| Concern | Rule | Peer / mold source |
|---------|------|--------------------|
| **CLI default** | Type 0 self-management without root | least-privilege posture |
| **Domain package/DB** | Internal `sudo` **only** for apt/service/mysql client ops; user **MUST NOT** be forced to run entire CLI as root | `template-least-privilege-user` specialized notes |
| **PROJECT_DIR ownership** | Prefer creating/keeping project under invoking user’s home when not overridden | `requirement-project-folder.md` |
| **Before mutating yml / project tree** | Dated backup via `util_backup` (or equivalent) when replace/clone/yml rewrite applies | `requirement-shell-backup-strategy.md` |
| **Secrets** | DB passwords never committed; not printed in human `help`; JSON extract only when requested | secret-management posture in domain ops |

### 2.6 Peer mold coverage (this domain)

| Peer requirement | Owns |
|------------------|------|
| `requirement-shell-online-install.md` | One-liner channel, pipe bootstrap, atomic place of **CLI** |
| `requirement-shell-cli-zero-arguments.md` | Empty argv = Type O-S CLI ensure |
| `requirement-shell-path-and-shell-support.md` | `path_*` / USER_BIN PATH integration |
| `requirement-project-folder.md` | CLI storage vs `PROJECT_DIR` Type 2 folder |
| `requirement-shell-backup-strategy.md` | Pre-mutate backup for project/yml |
| `requirement-bootstrap-chain.md` | A→B hop declaration |
| `requirement-shell-least-privilege.md` | Type 0/1 map + internal sudo for DB/Redis |
| `requirement-shell-error-handling.md` | Fail-fast / out_die policy |
| `requirement-shell-script-coding.md` | Prefixes + coding style |

## 3. Architecture inheritance (from A)

B **MUST** retain from selfmanaged:

- `out_*` output SSOT  
- `inst_*` install lifecycle  
- `app_main` single entry under pipe (no `$0` basename gate)  
- Type O empty-argv install-ensure for CLI  
- Automatic companion `.sha256` pattern when publishing  

Domain uses **separate prefixes** (`ruo_`, `db_`, `setup_`) and **MUST NOT** strip Type 0 routes.

---

## 4. Acceptance criteria

1. `./selfmanaged` remains APP_NAME=selfmanaged (A not polluted).  
2. `./ruoyi version` prints product version for B.  
3. `./ruoyi help` lists domain + Type 0.  
4. `./ruoyi about` runs without unbound-variable under `set -u`.  
5. Domain handlers exist for all help verbs.  
6. This file is the sole Active domain SSOT (`requirement-domain-ruoyi.md`).  
7. Class file Active: `requirement-class-software-dev.md`.

---

## 5. Status history

| Version | Date | Note |
|---------|------|------|
| 1.0.0 | 2026-08-11 | Initial domain law after bootstrap specialize selfmanaged → ruoyi |

## Design-time verification

| TP family | Suite | Notes |
|-----------|-------|-------|
| TP-DOM-* | `tests/test_domain.sh` | setup --no-run, routing, empty-argv ≠ domain |
| TP-CLI-04/05 | `tests/test_cli.sh` | help domain catalog + about JSON |
