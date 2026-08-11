# Revision + tests review — filled

**Date:** 2026-08-11  
**Version:** 2.3.1  
**Verdict:** **Pass**

## Revision
- [x] VERSION bumped 2.3.0 → **2.3.1** in ship unit + companion digest  
- [x] README badge  
- [x] CHANGELOG [2.3.1] entry  
- [x] Requirement Implementation Notes version strings aligned  

## Tests
- [x] `tests/run.sh` entrypoint  
- [x] `test_cli.sh` TP-CLI-01..10  
- [x] `test_install_lifecycle.sh` TP-INST-01..10  
- [x] `test_domain.sh` TP-DOM-01..07  
- [x] `docs/reviews/test-plan.md` + `requirement-test-matrix.md`  
- [x] Suite green: **PASS=103 FAIL=0**

## Review fixes during suite
- [x] Git clone stub used last argv as DEST (not `--depth`)  
- [x] Prior set -u / SDKMAN fixes retained  

## Residual optional
- TP-DOM-08 real mariadb/run host elev  
- TP-CURL-01 public channel one-liner after publish  
