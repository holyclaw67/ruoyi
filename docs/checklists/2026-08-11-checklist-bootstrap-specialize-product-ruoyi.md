# Checklist: Bootstrap specialize product (A → B) — filled

**Date:** 2026-08-11  
**A:** `selfmanaged` (`./selfmanaged`, freeze archive under `.specialize-archive/`)  
**B:** `ruoyi` (`./ruoyi`)  
**Change type:** specialize / rebuild B from A + domain oracle  
**Verdict:** **Pass** with residual gaps noted (full portable harness H2 not applied this turn)

## 1. Direction gate
- [x] A and B named: selfmanaged → ruoyi  
- [x] Direction A → B only  
- [x] No reverse-copy plan  
- [x] A body still APP_NAME=selfmanaged  

## 2. Freeze / archive A
- [x] A frozen: `.specialize-archive/selfmanaged.A-frozen-20260811-071652`  
- [x] Old B domain oracle: `.specialize-archive/ruoyi.domain-oracle`  

## 3. Requirements gate
- [x] Live requirements created (class + domain + Type 0 shell peers from A law retargeted)  
- [x] Domain SSOT: `requirement-domain-ruoyi.md` (four pillars)  
- [x] Index registered  

## 4. Create B from A
- [x] B rebuilt from A body + identity retarget  
- [x] A not overwritten  

## 5. Identity / channel (B)
- [x] APP_NAME=ruoyi, VERSION=2.3.0, REPO_NAME=ruoyi, SCRIPT_URL cloudgen/ruoyi  
- [x] Companion `ruoyi.sha256` regenerated  

## 6. Architecture inheritance
- [x] out_*/inst_*/app_main retained  
- [x] Domain prefixes separate  
- [x] Type 0 help surface retained  

## 7. Domain
- [x] setup/mariadb/mysql/redis/run/db-extract wired  
- [x] help/about domain-aware  
- [ ] Full stack smoke (SDKMAN/Java/DB) not run this turn (environment lacks Java/SDKMAN) — residual  

## 8. Residual / follow-ups
- [ ] H2 full harness pull from genesis (skills/terms/templates) still pending user map confirm from prior turn  
- [ ] Shell REQs retargeted by name replace; deeper Implementation Notes audit recommended  
- [ ] CHANGELOG entry for 2.3.0 specialize optional  

**Owner:** agent council  
