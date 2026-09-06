**file**: docs/requirements/requirement-bootstrap-chain.md  
**Status**: Active (Version 1.0.0 – specialized from mold `template-bootstrap-chain` / LM-BOOTSTRAP-CHAIN)  
**Area**: bootstrap  
**Key**: `requirement-bootstrap-chain`  
**Philosophy**: CIAO / CIAO-Lite

## 1. Purpose

Declare the **bootstrap specialization chain** for this product so agents preserve **A → B only** direction, architecture inheritance, and channel separation.

### 1.1 Human-facing

**In one sentence:** ruoyi grew from the selfmanaged command; keep that direction — do not copy ruoyi back onto selfmanaged.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | A maintainer changing the ruoyi script or its law | Edit `./ruoyi`, not `./selfmanaged`, for product B work |
| The other role | Bootstrap origin A (`selfmanaged`) — architecture source only | Shared output/install/dispatcher patterns |
| Not this file | Domain verbs (setup, mariadb, run) | Those live on `requirement-domain-ruoyi` |

| Includes | Excludes |
|----------|----------|
| Hop table selfmanaged → ruoyi | Reverse-copy of ruoyi onto the bootstrap binary |
| Channel owner `cloudgen/ruoyi` on the leaf | Treating selfmanaged’s GitHub URL as this product’s install channel |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./ruoyi` | product ship unit (B) | live specialized CLI |
| `./selfmanaged` | bootstrap reference (A), when present | architecture source — do not overwrite |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Specialize B | Change ruoyi. Leave the bootstrap copy as reference. | Edit `./ruoyi` |
| Restore direction | If A was overwritten by B, restore A then rebuild B. | Restore `./selfmanaged` from archive, then re-apply domain on `./ruoyi` |

## 2. Core rules

1. Every edge **MUST** be ancestor → descendant only.  
2. **MUST NOT** copy descendant ship unit onto ancestor path (reverse-copy pollution).  
3. Detected reverse-copy **MUST** restore ancestor then rebuild child.  
4. Shared architecture defects **SHOULD** fix at earliest responsible hop, then re-specialize down.  
5. Domain DNA **MUST** stay on leaf only unless explicitly multi-hop domain.

## 3. Implementation Notes — hop table (this project)

| # | Hop name | Position | Ship unit path | Channel owner | Domain? | Notes |
|---|----------|----------|----------------|---------------|---------|-------|
| 0 | `selfmanaged` | root / bootstrap A | `./selfmanaged` (also freeze archive under `.specialize-archive/`) | `cloudgen/selfmanaged` | no | Type 0 online shell CLI architecture source |
| 1 | `ruoyi` | leaf / product B | `./ruoyi` | `cloudgen/ruoyi` | **yes** | RuoYi stack domain; identity retargeted |

### Edges

| Edge | Inherit contracts | Retarget identity/channel | Domain extend |
|------|-------------------|---------------------------|---------------|
| selfmanaged → ruoyi | yes (`out_*`, `inst_*`, `app_main`, Type O-S empty argv, companion integrity, modular prefixes) | yes (`APP_NAME=ruoyi`, REPO/SCRIPT_URL, VERSION=2.3.2) | yes (`ruo_*`/`db_*`/`setup_*`) |

### Origin-review defaults

| Default | Value |
|---------|-------|
| Immediate origin of leaf | `selfmanaged` |
| Reverse-copy response | Restore A from archive; rebuild B from A + domain oracle |

### Forbidden reverse statements

- “Bootstrap was created by trimming ruoyi”  
- “Update selfmanaged by copying ruoyi then rename”  

## 4. Protection Rule

**MUST NOT** reverse-copy `./ruoyi` onto `./selfmanaged`, thin A’s Type 0 law to match domain-only shortcuts, or claim chain complete without this hop table.

## 5. Acceptance criteria

1. A still `APP_NAME=selfmanaged`.  
2. B still `APP_NAME=ruoyi` with distinct channel.  
3. Domain requirements live only on B (`requirement-domain-ruoyi.md`).  
4. Registry row present.
