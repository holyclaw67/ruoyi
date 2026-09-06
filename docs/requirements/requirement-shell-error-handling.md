**file**: docs/requirements/requirement-shell-error-handling.md  
**Status**: Active (Version 1.0.0 – specialized from `template-error-handling` / LM-ERROR-HANDLING)  
**Area**: shell  
**Key**: `requirement-shell-error-handling`  
**Philosophy**: CIAO / CIAO-Lite

## 1. Purpose

SSOT for **defensive error handling** on `ruoyi`: fail loud for critical faults, graceful degrade for non-critical, always actionable, safe under non-interactive/`--json`/`--quiet`.

**Complements** (does not replace): `requirement-shell-output-requirements.md` (channel catalog), interactive peer (prompt policy).

### 1.1 Human-facing

**In one sentence:** When ruoyi cannot continue, it prints a clear error and exits; it does not hang waiting for you in a script.

| Box | Meaning | Example |
|-----|---------|---------|
| You / this login | Operator or CI seeing a failure | Unknown command → pointer to `ruoyi help` |
| The other role | Output family (`out_die` / `out_json_error`) | Channel rules live on the output requirement |
| Not this file | Which commands exist | `requirement-shell-cli-interface` |

| Includes | Excludes |
|----------|----------|
| Fail-fast for checksum mismatch, missing binary place, dangerous delete | Silent ignore of hard errors |
| Actionable next step in the error | Raw `echo` of fatals |

| Surface | What you open | What for |
|---------|---------------|----------|
| `./ruoyi` | ship unit | `out_die` call sites |
| `ruoyi help` | command | recovery pointer |

| You do… | What it means | What you type |
|---------|---------------|---------------|
| Hit an unknown word | Non-zero exit; message names `help`. | `ruoyi no-such-command` |

## 2. Core error handling rules (mandatory)

### 2.1 Single source of error output

1. All errors **MUST** go through `out_error` / `out_die` / `out_json_error` (as applicable).  
2. **MUST NOT** use raw `echo`/`printf`/`cat` for error messages to the user.  
3. `out_die` **MUST**: print via central system; emit JSON error when `--json`; exit non-zero (usually 1).

### 2.2 Fail fast vs graceful degradation

| Class | Examples | Behavior |
|-------|----------|----------|
| **Critical — fail fast** | Checksum mismatch; cannot place binary; invalid dangerous `PROJECT_DIR` delete; DB ops that would destroy credentials policy; network hard-fail on required install download | `out_die` / non-zero |
| **Non-critical — warn + continue** | Optional backup warn; optional component missing when not required for command; PATH already present | `out_warn` |

Always provide **actionable recovery hints** (e.g. run `setup` first, check `SCRIPT_URL`, install bash).

### 2.3 Non-interactive safety

1. **MUST NEVER** hang waiting for input under non-TTY / `curl|bash` / CI / `--json` / `--quiet` automation.  
2. Use safe defaults and auto paths (`inst_maybe_install` / auto install when not installed).  
3. Errors remain clear under quiet/json (json error objects; quiet still surfaces fatals).

### 2.4 Domain-specific critical failures

| Situation | Required |
|-----------|----------|
| `PROJECT_DIR` missing when DB setup needs project | Fail with hint to run `setup` / clone |
| Java/Maven/SDKMAN missing for `run` | Fail after ensure attempt or clear missing-tool error |
| Credential reuse wrong password policy | Strong warn; **MUST NOT** silently overwrite passwords (domain SSOT) |

## 3. Recommended patterns (normative style)

```sh
command || out_die "Descriptive error with recovery hint"

if [ ! -d "${PROJECT_DIR}" ]; then
    out_die "Project directory '${PROJECT_DIR}' not found. Run: ${APP_NAME} setup"
fi
```

Graceful:

```sh
util_backup "${path}" "pre-op" || out_warn "Backup failed — continuing with caution"
```

## 4. Implementation Notes

| Item | Live |
|------|------|
| Fatal | `out_die` |
| Warn | `out_warn` |
| JSON errors | `out_json_error` |
| Domain alias | `msg` → plain only (not for fatals) |

## 5. Protection Rule (Sacred)

**MUST NOT**:

1. Swallow critical install/integrity failures as success.  
2. Hang non-interactive for prompts.  
3. Bypass `out_*` for errors.  
4. Silent overwrite of DB credentials against domain policy.

## 6. Acceptance criteria

1. Unknown command → `out_die` + pointer to help.  
2. Integrity fail → non-zero.  
3. Registry row present.
