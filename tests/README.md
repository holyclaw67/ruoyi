# Tests (ruoyi)

POSIX `/bin/sh` CI harness for the bash ship unit `./ruoyi` (Type O-S online CLI + RuoYi domain).

## Run

```sh
./tests/run.sh
```

Requires: `bash`, `curl`, `python3` (local HTTP channel), `sha256sum`, `grep`.

## Suites

| Suite | File | Focus |
|-------|------|--------|
| CLI surface | `test_cli.sh` | `bash -n`, companion digest, version/help/about, domain verbs in help (including `mariadb|mysql|db`), CHECKSUM absent, unknown command, quiet, `env -u HOME`, zero-arg fail, uninstall fail-closed, about storage JSON (TP-CLI-11) |
| Install lifecycle | `test_install_lifecycle.sh` | Isolated install via local channel, Type O-S empty-argv Case B/C, version-check, self-update, integrity transparency, uninstall |
| Domain | `test_domain.sh` | Help domain catalog, offline `setup --no-run` with stubs, run/db-extract routing, empty-argv is not domain |

**Version:** suites read `PRODUCT_VERSION` from `grep '^VERSION="' ./ruoyi`. After a bump, regenerate `ruoyi.sha256` and re-run `./tests/run.sh`.

## Maps

- Product TP map: `docs/reviews/test-plan.md`
- RTM: `docs/reviews/requirement-test-matrix.md`
