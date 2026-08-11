# Requirement → test matrix (ruoyi)

| Requirement | TP families | Suite files |
|-------------|-------------|-------------|
| requirement-class-software-dev | (gate only) | — |
| requirement-bootstrap-chain | (process) | specialize checklists |
| requirement-domain-ruoyi | TP-DOM-*, TP-CLI-04/05 | test_domain.sh, test_cli.sh |
| requirement-project-folder | TP-DOM-03 | test_domain.sh |
| requirement-shell-online-install | TP-INST-01, TP-CLI-09 | test_install_lifecycle.sh, test_cli.sh |
| requirement-shell-cli-zero-arguments | TP-INST-03/04, TP-DOM-07, TP-CLI-09 | test_install_lifecycle.sh, test_domain.sh |
| requirement-shell-cli-interface | TP-CLI-* | test_cli.sh |
| requirement-shell-self-management | TP-INST-06/07/09/10, TP-CLI-10 | test_install_lifecycle.sh, test_cli.sh |
| requirement-shell-automatic-checksum | TP-CLI-02, TP-INST-08 | test_cli.sh, test_install_lifecycle.sh |
| requirement-shell-idempotency | TP-INST-02 | test_install_lifecycle.sh |
| requirement-shell-output-requirements | TP-CLI-07 | test_cli.sh |
| requirement-shell-error-handling | TP-CLI-06 | test_cli.sh |
| requirement-shell-script-coding | TP-CLI-01, TP-CLI-08 | test_cli.sh |
| requirement-shell-least-privilege | (docs + elev path) | optional TP-DOM-08 |
| requirement-shell-path-and-shell-support | (install path side effect) | install lifecycle |
| requirement-shell-backup-strategy | (clone path) | TP-DOM-03/04 |
| requirement-shell-cli-storage | (about/storage) | optional expand |
| requirement-shell-interactive-vs-noninteractive | TP-CLI-09, lifecycle | test_cli.sh |
| requirement-shell-modular-function-design | (structure) | bash -n / suite |
