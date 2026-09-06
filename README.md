# ruoyi - One-command setup for the RuoYi admin framework

[![Version](https://img.shields.io/badge/Version-2.3.2-blue?style=flat-square)](https://github.com/cloudgen/ruoyi)
[![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE.md)
[![CIAO](https://img.shields.io/badge/Philosophy-CIAO%20(Caution%20%E2%80%A2%20Intentional%20%E2%80%A2%20Anti--fragile%20%E2%80%A2%20Over--engineered)-purple.svg)](https://github.com/cloudgen/ciao)
[![Stars](https://img.shields.io/github/stars/cloudgen/ruoyi?style=flat-square)](https://github.com/cloudgen/ruoyi)
<img src="https://img.shields.io/badge/Java-21-orange?style=flat-square&logo=openjdk" alt="Java 21">
<img src="https://img.shields.io/badge/Maven-3.9.14-red?style=flat-square&logo=apachemaven" alt="Maven 3.9.14">
<img src="https://img.shields.io/badge/RuoYi-admin-blue?style=flat-square" alt="RuoYi Framework">

You install a small command named `ruoyi` on your own login, then use it to clone and run a RuoYi admin demo on this machine.

| Box | Meaning | Example |
|-----|---------|---------|
| **You** | Your own login. Install the command, clone the demo, start the app. | `ruoyi setup --no-run` then `ruoyi run` |
| **The other role** | Package and database work may call `sudo` for MariaDB/MySQL/Redis only. You do not need to prefix the whole CLI with `sudo` for daily use. | `ruoyi mariadb` |
| **Not this** | Not a general Java installer, not the RuoYi Java source itself, and not a dedicated long-running system account. | The Java project lives under `~/ruoyi-demo` by default |

| Includes | Excludes |
|----------|----------|
| Install the `ruoyi` command for yourself or system-wide | Installing the full RuoYi stack when you only paste `curl \| bash` with no command |
| SDKMAN, Java 21, Maven, clone, database, Redis, build/run | Pretending a missing checksum sidecar is a signed release |
| `--quiet` / `--json` for scripts | Hanging on prompts inside CI or a pipe |

| Step | What it means | What you type |
|------|---------------|---------------|
| Install the command | Places `ruoyi` on your PATH. Does **not** clone RuoYi yet. | See Quick Installation |
| Prepare the stack | SDKMAN + Java 21 + Maven + clone into the project folder. | `ruoyi setup --no-run` |
| Database (optional) | May use internal `sudo` for packages/services. | `ruoyi mariadb` |
| Start the app | Build and run `ruoyi-admin`. | `ruoyi run` |

Officially reviewed copy: [RECOMMENDATION.md](RECOMMENDATION.md).

## Features

- Copy-paste online install (`curl | bash` for your login, or `sudo bash` for everyone on the machine)
- Command lifecycle: `install`, `version`, `version-check`, `self-update`, `self-uninstall`, `about`, `help`
- RuoYi stack: `setup`, `mariadb` / `mysql` / `db`, `redis`, `run`, `db-extract`
- Pinned **SDKMAN!** + **Java 21 (Temurin)** + **Maven 3.9.14**
- Clones RuoYi, writes the app port, keeps existing database credentials when it is safe
- Custom project folder: `--project-dir`
- Script-friendly: `--quiet`, `--json`, no hanging prompts in pipes
- Install integrity: the program downloads `${SCRIPT_URL}.sha256` itself (SHA-256); optional `CHECKSUM` pin is secondary

## Quick Installation

**User install** (recommended — your login only):

```bash
curl -fsSL https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi | bash
```

**System-wide:**

```bash
curl -fsSL https://raw.githubusercontent.com/cloudgen/ruoyi/main/ruoyi | sudo bash
```

Typical first run after the command is installed:

```bash
ruoyi setup --no-run          # SDKMAN + Java + Maven + clone project
ruoyi mariadb                 # recommended DB setup (may use internal sudo)
ruoyi run                     # build and start ruoyi-admin
```

Running `curl | bash` with **no extra command** only installs or re-checks the `ruoyi` command. It does **not** clone RuoYi or start the admin app — use `setup` / `run` for that.

### Install integrity

Online install and `self-update` verify the downloaded script with **SHA-256**. In normal (human) mode the program shows the companion **link**, the expected **value**, and the **result**.

| Mode | When | Outcome |
|------|------|---------|
| **Automatic companion** (default) | No `CHECKSUM` env pin | Fetch `${SCRIPT_URL}.sha256`. **Match** → install. **Mismatch** → abort. **Missing sidecar** → warn and continue (best-effort). |
| **Strict pin** (secondary) | `CHECKSUM` set in the process environment | Compare to that digest; mismatch aborts. Not a `help`/`about` flag. |

Same-channel companion digest proves **byte consistency** with the published sidecar, not independent signing. Repo companion file: `ruoyi.sha256`.

## Usage

### Commands

| Command | Description |
|---------|-------------|
| *(no arguments)* | Install or re-check the `ruoyi` command only |
| `install` | Install CLI (user → `~/.local/bin`, root → `/usr/local/bin`) |
| `setup` | SDKMAN + Java + Maven + clone RuoYi |
| `mariadb` / `mysql` / `db` | Database setup |
| `redis` | Redis for RuoYi |
| `run` | Build and run `ruoyi-admin` |
| `db-extract` | Extract DB credentials from `application-druid.yml` |
| `version` / `version-check` / `self-update` / `self-uninstall` | Check, update, or remove the `ruoyi` command |
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

## Examples

```bash
ruoyi setup --no-run --project-dir /opt/ruoyi-demo
ruoyi mariadb
ruoyi run
ruoyi db-extract --json
ruoyi about --json
```

## Platform Compatibility

- **Bash required** for the Java/SDKMAN stack (`curl | bash`, not bare `sh` for the one-liner)
- **POSIX Linux** (and compatible UNIX where `/bin/sh` plus `sha256sum` / `mktemp` exist)
- **Alpine**: install `bash` first
- **MariaDB** recommended; existing config credentials are left alone when that is safe
- Full live MariaDB/`run` on a dedicated host is optional (CI uses stubs)

## Related Projects

- Bootstrap architecture: **[selfmanaged](https://github.com/cloudgen/selfmanaged)** (A → B only; do not copy ruoyi back onto that tree)
- Defensive practice: **[CIAO](https://github.com/cloudgen/ciao)** / [CIAO-Lite](https://github.com/cloudgen/ciao-lite)
- Upstream admin framework: [RuoYi](https://gitee.com/y_project/RuoYi)

## Contributing

Issues and pull requests are welcome. Keep install truth, checksum outcomes, and command tables aligned with `ruoyi help` / `ruoyi about`. After editing `./ruoyi`, regenerate the companion digest and run the suite:

```bash
sha256sum ruoyi | awk '{print $1"  ruoyi"}' > ruoyi.sha256
./tests/run.sh
```

Requires: `bash`, `curl`, `python3`, `sha256sum`, `grep`.

Product law: [docs/requirements/index.md](docs/requirements/index.md). Test map: [docs/reviews/test-plan.md](docs/reviews/test-plan.md). Requirement → test matrix: [docs/reviews/requirement-test-matrix.md](docs/reviews/requirement-test-matrix.md).

## License

[MIT](LICENSE.md) · See [CHANGELOG.md](CHANGELOG.md) for release history.

## Last Update

2026-09-06 (2.3.2 — README human-readable kit, requirement Human-facing sections, `about` storage diagnostics).
