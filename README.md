# ruoyi

[![Version](https://img.shields.io/badge/Version-2.3.1-blue?style=flat-square)](https://github.com/cloudgen/ruoyi)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE.md)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
<img src="https://img.shields.io/badge/Java-21-orange?style=flat-square&logo=openjdk" alt="Java 21">
<img src="https://img.shields.io/badge/Maven-3.9.14-red?style=flat-square&logo=apachemaven" alt="Maven 3.9.14">
<img src="https://img.shields.io/badge/RuoYi-admin-blue?style=flat-square" alt="RuoYi Framework">

**One-command setup for the RuoYi admin framework** — Type O-S online install CLI plus domain stack (SDKMAN / Java 21 / Maven, clone, MariaDB/MySQL, Redis, run).

Specialized from bootstrap **[selfmanaged](https://github.com/cloudgen/selfmanaged)** architecture (A→B only). Built for **CIAO** defensive shell practice and automation (`--json` / `--quiet`).

Officially reviewed copy: [RECOMMENDATION.md](RECOMMENDATION.md).

---

## Features

- One-liner install: `curl | bash` (user or `sudo bash` for global)
- Type 0 self-management: `install`, `version`, `version-check`, `self-update`, `self-uninstall`, `about`, `help`
- Domain: `setup`, `mariadb` / `mysql` / `db`, `redis`, `run`, `db-extract`
- Pinned **SDKMAN!** + **Java 21 (Temurin)** + **Maven 3.9.14**
- Clones RuoYi, configures port, intelligent DB credential handling
- Custom project path: `--project-dir`
- Automation-friendly: `--quiet`, `--json`, non-interactive safe defaults
- Companion integrity: `ruoyi.sha256` on the install channel when published

---

## Quick installation

**User install:**

```bash
curl -fsSL https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi | bash
```

**System-wide:**

```bash
curl -fsSL https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi | sudo bash
```

Typical first run after CLI install:

```bash
ruoyi setup --no-run          # SDKMAN + Java + Maven + clone project
ruoyi mariadb                 # recommended DB setup (may use internal sudo)
ruoyi run                     # build and start ruoyi-admin
```

Empty argv (`curl | bash` with no command) only **ensures the CLI ship unit** is installed (Type O-S). It does **not** run the full domain stack — use `setup` / `run` explicitly.

---

## Usage

### Commands

| Command | Description |
|---------|-------------|
| *(empty argv)* | Type O-S: install-ensure CLI only |
| `install` | Install CLI (user → `~/.local/bin`, root → `/usr/local/bin`) |
| `setup` | SDKMAN + Java + Maven + clone RuoYi |
| `mariadb` / `mysql` / `db` | Database setup |
| `redis` | Redis for RuoYi |
| `run` | Build and run `ruoyi-admin` |
| `db-extract` | Extract DB credentials from `application-druid.yml` |
| `version` / `version-check` / `self-update` / `self-uninstall` | Type 0 lifecycle |
| `about` / `help` | Diagnostics and usage |

### Flags

| Flag | Meaning |
|------|---------|
| `--project-dir PATH` | Override project directory (default `$HOME/ruoyi-demo`) |
| `--no-run` | With `setup`: skip build/run after clone |
| `--quiet` / `-q` | Suppress non-error chatter |
| `--json` | Machine-readable JSON (implies quiet) |
| `--force` | Force reinstall / skip uninstall confirm / allow downgrade |
| `--debug` | Debug diagnostics on stderr |

### Examples

```bash
ruoyi setup --no-run --project-dir /opt/ruoyi-demo
ruoyi mariadb
ruoyi run
ruoyi db-extract --json
ruoyi about --json
```

---

## Development & tests

```bash
# CLI + install lifecycle + domain (offline stubs for domain setup)
./tests/run.sh
```

Requires: `bash`, `curl`, `python3`, `sha256sum`, `grep`.

TP map: [docs/reviews/test-plan.md](docs/reviews/test-plan.md) · RTM: [docs/reviews/requirement-test-matrix.md](docs/reviews/requirement-test-matrix.md).

Product law (requirements): [docs/requirements/index.md](docs/requirements/index.md).

Ship unit version is the hard-assign line `VERSION="…"` in `./ruoyi`. After changing the ship unit, regenerate:

```bash
sha256sum ruoyi | awk '{print $1"  ruoyi"}' > ruoyi.sha256
./tests/run.sh
```

---

## Platform notes

- **Bash required** for SDKMAN/Java domain (`curl | bash`, not bare `sh` for one-liner)
- **Alpine**: ensure `bash` is installed
- **MariaDB** recommended; respects existing config credentials when safe

---

## Philosophy

`ruoyi` follows **CIAO** (Caution · Intentional · Anti-fragile · Over-protect). Type 0 architecture is inherited from **selfmanaged**; domain law lives in `requirement-domain-ruoyi.md`. Do not reverse-copy domain onto the bootstrap product.

---

## License

[MIT](LICENSE.md) · See [CHANGELOG.md](CHANGELOG.md) for release history.
