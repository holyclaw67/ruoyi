# Product test plan map (ruoyi)

**Updated:** 2026-09-06 · **Ship unit version:** read from `./ruoyi` (`VERSION=`)  
**Runner:** `./tests/run.sh`

| TP-ID | Status | Suite | Primary requirement |
|-------|--------|-------|---------------------|
| TP-CLI-01 | have | test_cli.sh | requirement-shell-script-coding |
| TP-CLI-02 | have | test_cli.sh | requirement-shell-automatic-checksum |
| TP-CLI-03 | have | test_cli.sh | requirement-shell-cli-interface |
| TP-CLI-04 | have | test_cli.sh | requirement-shell-cli-interface + requirement-domain-ruoyi |
| TP-CLI-05 | have | test_cli.sh | requirement-domain-ruoyi (about) |
| TP-CLI-06 | have | test_cli.sh | requirement-shell-cli-interface + requirement-shell-error-handling |
| TP-CLI-07 | have | test_cli.sh | requirement-shell-output-requirements |
| TP-CLI-08 | have | test_cli.sh | requirement-shell-script-coding (set -u HOME) |
| TP-CLI-09 | have | test_cli.sh | requirement-shell-cli-zero-arguments |
| TP-CLI-10 | have | test_cli.sh | requirement-shell-self-management |
| TP-CLI-11 | have | test_cli.sh | requirement-shell-cli-storage |
| TP-CLI-12 | have | test_cli.sh | requirement-shell-cli-interface (`-q`) |
| TP-CLI-13 | have | test_cli.sh | requirement-shell-output-requirements (`--debug` JSON) |
| TP-CLI-14 | have | test_cli.sh | requirement-project-folder (`--project-dir` about) |
| TP-INST-01 | have | test_install_lifecycle.sh | requirement-shell-online-install |
| TP-INST-02 | have | test_install_lifecycle.sh | requirement-shell-idempotency |
| TP-INST-03 | have | test_install_lifecycle.sh | requirement-shell-cli-zero-arguments (O-S Case B) |
| TP-INST-04 | have | test_install_lifecycle.sh | requirement-shell-cli-zero-arguments (O-S Case C) |
| TP-INST-05 | have | test_install_lifecycle.sh | requirement-domain-ruoyi / CLI about |
| TP-INST-06 | have | test_install_lifecycle.sh | requirement-shell-self-management |
| TP-INST-07 | have | test_install_lifecycle.sh | requirement-shell-self-management |
| TP-INST-08 | have | test_install_lifecycle.sh | requirement-shell-automatic-checksum |
| TP-INST-09 | have | test_install_lifecycle.sh | requirement-shell-self-management |
| TP-INST-10 | have | test_install_lifecycle.sh | requirement-shell-self-management |
| TP-INST-11 | have | test_install_lifecycle.sh | requirement-shell-cli-zero-arguments (O-S Case A success) |
| TP-DOM-01 | have | test_domain.sh | requirement-domain-ruoyi |
| TP-DOM-02 | have | test_domain.sh | requirement-shell-online-install |
| TP-DOM-03 | have | test_domain.sh | requirement-domain-ruoyi (setup --no-run) |
| TP-DOM-04 | have | test_domain.sh | requirement-shell-backup-strategy + domain |
| TP-DOM-05 | have | test_domain.sh | requirement-domain-ruoyi (run route) |
| TP-DOM-06 | have | test_domain.sh | requirement-domain-ruoyi (db-extract) |
| TP-DOM-07 | have | test_domain.sh | requirement-shell-cli-zero-arguments (empty-argv ≠ domain) |
| TP-DOM-09 | have | test_domain.sh | requirement-domain-ruoyi (`mysql`/`db`/`redis` route) |
| TP-DOM-08 | optional | — | Full `mariadb`/`run` with real DB (host elev) |
| TP-CURL-01 | todo | — | Public-channel curl\|bash (when published) |

Status: `have` = implemented green expected · `todo` = planned · `optional` = host-dependent
