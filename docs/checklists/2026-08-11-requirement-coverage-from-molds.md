# Requirement coverage review + mold update — filled

**Date:** 2026-08-11  
**Claim:** C-full-product (Type O-S CLI + RuoYi domain)  
**Verdict:** **Sufficient with Gaps** (stack smoke not executed on this host)

## Registry inventory
- Registered ∩ disk: 16 files (match after update)
- Orphans: none
- Ghosts: none

## Mold mapping (applied)

| Mold | Result |
|------|--------|
| template-requirement-class-software-dev | Updated residual/version |
| template-cli-interface | Domain command table + VERSION 2.3.0 |
| template-shell-cli-zero-arguments | Type O-S addendum |
| template-online-install | **NEW** requirement-shell-online-install |
| template-bootstrap-chain | **NEW** requirement-bootstrap-chain |
| template-path-and-shell-support | **NEW** requirement-shell-path-and-shell-support |
| template-backup-strategy | **NEW** requirement-shell-backup-strategy |
| template-project-folder | **NEW** requirement-project-folder |
| template-self-management / automatic-checksum / output / etc. | Kept; identity retarget checked |
| template-payload-online-install | **N/A** — product is Type O-S not O-P |
| template-least-privilege-user | Notes in domain §2.5 (no separate file; residual) |

## P0 closed this turn
- Domain surface owned in CLI interface + domain SSOT  
- VERSION drift 1.2.1 → 2.3.0 in key REQs  
- Online-install + bootstrap-chain + path/backup/project-folder law  
- Genesis-stale requirements README fixed  

## Residual Gaps
- Full Java/SDKMAN/DB smoke not run here  
- Optional deeper re-sync of every shell REQ section heading vs mold (bulk A copy still thinner than molds in places)  
- Optional dedicated least-privilege REQ if domain sudo matrix needs more formality  
