# =============================================================================
# tests/test_cli.sh — Type 0 CLI surface + domain help (TP-CLI-*)
# =============================================================================
# Covers: bash -n, companion digest, version/help/about (human+JSON),
# domain verbs in help, CHECKSUM absent, unknown command, quiet, env -u HOME,
# zero-arg install failure exit, self-uninstall fail-closed JSON,
# about cache folder + persistence (TP-CLI-11).
# Primary REQs: requirement-shell-cli-interface, online-install, zero-arguments,
# output-requirements, domain-ruoyi (help pillars), cli-storage
# =============================================================================

. "${TESTS_ROOT}/helpers.sh"

run_test_cli() {
    t_header "CLI surface"

    require_cmd bash
    require_cmd sha256sum
    require_cmd grep

    # --- syntax (bash ship unit) ---
    bash -n "${SCRIPT}"
    assert_eq "TP-CLI-01 bash -n ruoyi (syntax)" 0 "$?"

    # --- companion digest matches ship unit ---
    if [ -f "${REPO_ROOT}/ruoyi.sha256" ]; then
        _expected=$(ci_digest_hex "${REPO_ROOT}/ruoyi.sha256")
        _actual=$(sha256sum "${SCRIPT}" | awk '{print $1}')
        assert_eq "TP-CLI-02 ruoyi.sha256 matches ./ruoyi" "$_expected" "$_actual"
    else
        t_fail "TP-CLI-02 ruoyi.sha256 missing at repo root"
    fi

    # --- version (human) ---
    _out=$(bash "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 version human version" "$_out" "${PRODUCT_VERSION}"
    assert_contains "TP-CLI-03 version human app" "$_out" "ruoyi"

    # --- version (json) ---
    _out=$(bash "${SCRIPT}" --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-03 version --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-03 version --json type" "$_out" '"type":"version"'
    assert_contains "TP-CLI-03 version --json app" "$_out" '"app":"ruoyi"'
    assert_contains "TP-CLI-03 version --json version field" "$_out" "\"version\":\"${PRODUCT_VERSION}\""

    # --- help (human): Type 0 + domain ---
    _out=$(bash "${SCRIPT}" help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help install" "$_out" "install"
    assert_contains "TP-CLI-04 help version-check" "$_out" "version-check"
    assert_contains "TP-CLI-04 help self-update" "$_out" "self-update"
    assert_contains "TP-CLI-04 help self-uninstall" "$_out" "self-uninstall"
    assert_contains "TP-CLI-04 help about" "$_out" "about"
    assert_contains "TP-CLI-04 help setup" "$_out" "setup"
    assert_contains "TP-CLI-04 help mariadb" "$_out" "mariadb"
    assert_contains "TP-CLI-04 help mysql" "$_out" "mysql"
    assert_contains "TP-CLI-04 help db alias" "$_out" "mariadb|mysql|db"
    assert_contains "TP-CLI-04 help redis" "$_out" "redis"
    assert_contains "TP-CLI-04 help run" "$_out" "run"
    assert_contains "TP-CLI-04 help db-extract" "$_out" "db-extract"
    assert_contains "TP-CLI-04 help --json" "$_out" "--json"
    assert_contains "TP-CLI-04 help --force" "$_out" "--force"
    assert_contains "TP-CLI-04 help --project-dir" "$_out" "--project-dir"
    assert_contains "TP-CLI-04 help --project alias" "$_out" "--project PATH"
    assert_contains "TP-CLI-04 help --no-run" "$_out" "--no-run"
    assert_contains "TP-CLI-04 help REPO_USER" "$_out" "REPO_USER"
    assert_contains "TP-CLI-04 help SCRIPT_URL" "$_out" "SCRIPT_URL"
    assert_not_contains "TP-CLI-04 help must not list CHECKSUM" "$_out" "CHECKSUM"

    # --- help (json) ---
    _out=$(bash "${SCRIPT}" --json help 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-04 help --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-04 help --json type help" "$_out" '"type":"help"'
    assert_contains "TP-CLI-04 help --json commands field" "$_out" "setup"
    assert_contains "TP-CLI-04 help --json app" "$_out" '"app":"ruoyi"'
    assert_contains "TP-CLI-04 help --json commands include db" "$_out" "mysql,db,redis"

    # --- about (json): domain diagnostics; no CHECKSUM ---
    _out=$(bash "${SCRIPT}" --json about 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-05 about --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-05 about --json type" "$_out" '"type":"about"'
    assert_contains "TP-CLI-05 about --json app" "$_out" '"app":"ruoyi"'
    assert_contains "TP-CLI-05 about --json version" "$_out" "\"version\":\"${PRODUCT_VERSION}\""
    assert_contains "TP-CLI-05 about --json installed" "$_out" '"installed"'
    assert_contains "TP-CLI-05 about --json project_dir" "$_out" '"project_dir"'
    assert_contains "TP-CLI-05 about --json sdkman" "$_out" '"sdkman"'
    assert_contains "TP-CLI-05 about --json java" "$_out" '"java"'
    assert_contains "TP-CLI-05 about --json maven" "$_out" '"maven"'
    assert_contains "TP-CLI-05 about --json port" "$_out" '"port"'
    assert_not_contains "TP-CLI-05 about --json no CHECKSUM" "$_out" "CHECKSUM"
    assert_contains "TP-CLI-11 about --json effective_storage" "$_out" '"effective_storage"'
    assert_contains "TP-CLI-11 about --json storage_dir" "$_out" '"storage_dir"'
    assert_contains "TP-CLI-11 about --json cache_used" "$_out" '"cache_used"'
    assert_contains "TP-CLI-11 about --json cache_preferred" "$_out" '"cache_preferred"'
    assert_contains "TP-CLI-11 about --json cache_fallback" "$_out" '"cache_fallback"'
    assert_contains "TP-CLI-11 about --json cache_fallback_2" "$_out" '"cache_fallback_2"'
    assert_contains "TP-CLI-11 about --json persistence_storage" "$_out" '"persistence_storage"'
    assert_not_contains "TP-CLI-11 about --json no CHECKSUM" "$_out" "CHECKSUM"

    # TP-CLI-11 cache leaves: per login, per process, host chains, silent skip
    ci_isolated_env
    _login=$(id -un 2>/dev/null || echo "unknown")
    _out=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" bash "${SCRIPT}" --json about 2>/dev/null)
    assert_contains "TP-CLI-11 isolated about has app in cache" "$_out" "${APP_NAME}"
    _pref=$(printf '%s' "$_out" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _pid="${_pref##*-}"
    case "${_pref}" in
        /dev/shm/cache/cache-"${APP_NAME}"-"${_login}"-[0-9]*)
            t_pass "TP-CLI-11 cache_preferred is shm login process leaf"
            ;;
        *) t_fail "TP-CLI-11 cache_preferred unexpected: '${_pref:-empty}'" ;;
    esac
    _fb=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 cache_fallback 1st" "/tmp/cache/cache-${APP_NAME}-${_login}-${_pid}" "${_fb}"
    _fb2=$(printf '%s' "$_out" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 cache_fallback 2nd" "${CI_HOME}/.cache/cache-${APP_NAME}-${_pid}" "${_fb2}"
    _used=$(printf '%s' "$_out" | sed -n 's/.*"cache_used":"\([^"]*\)".*/\1/p' | head -n1)
    _eff=$(printf '%s' "$_out" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 cache_used matches effective" "${_eff}" "${_used}"
    assert_eq "TP-CLI-11 used matches preferred when preferred works" "${_pref}" "${_used}"
    if [ -n "$_eff" ] && [ -d "$_eff" ]; then
        t_pass "TP-CLI-11 effective cache directory exists"
    else
        t_fail "TP-CLI-11 effective cache missing: '${_eff:-empty}'"
    fi
    case "${_eff}" in
        /dev/shm/"${APP_NAME}"|/dev/shm/"${APP_NAME}"-*)
            t_fail "TP-CLI-11 effective cache must not be ram-drive project shape: '${_eff}'"
            ;;
        *) t_pass "TP-CLI-11 effective cache is not a ram-drive project shape" ;;
    esac
    _mode=$(stat -c %a "${_eff}" 2>/dev/null || echo "")
    assert_eq "TP-CLI-11 effective cache mode 0700" "700" "${_mode}"
    _err=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" RUOYI_CACHE_SKIP=preferred \
        bash "${SCRIPT}" about 2>&1 >/dev/null)
    assert_not_contains "TP-CLI-11 silent cache fallback" "${_err}" "fallback"
    assert_not_contains "TP-CLI-11 silent cache fallback error" "${_err}" "Cannot create cache"
    _skip=$(HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" RUOYI_CACHE_SKIP=preferred \
        bash "${SCRIPT}" --json about 2>/dev/null)
    _skip_eff=$(printf '%s' "$_skip" | sed -n 's/.*"effective_storage":"\([^"]*\)".*/\1/p' | head -n1)
    _skip_fb=$(printf '%s' "$_skip" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    _skip_pref=$(printf '%s' "$_skip" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 skipped preferred uses 1st fallback" "${_skip_fb}" "${_skip_eff}"
    case "${_skip_pref}" in
        /dev/shm/cache/cache-"${APP_NAME}"-"${_login}"-[0-9]*)
            t_pass "TP-CLI-11 skipped run still reports preferred shm path"
            ;;
        *) t_fail "TP-CLI-11 skipped preferred path unexpected: '${_skip_pref:-empty}'" ;;
    esac
    _gb=$(HOME="${CI_HOME}" RUOYI_CACHE_HOST=gitbash bash "${SCRIPT}" --json about 2>/dev/null)
    _gb_pref=$(printf '%s' "$_gb" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _gb_pid="${_gb_pref##*-}"
    assert_eq "TP-CLI-11 gitbash preferred" "/tmp/cache/cache-${APP_NAME}-${_login}-${_gb_pid}" "${_gb_pref}"
    _gb_fb=$(printf '%s' "$_gb" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 gitbash 1st fallback" "${CI_HOME}/AppData/Local/Temp/cache-${APP_NAME}-${_gb_pid}" "${_gb_fb}"
    assert_contains "TP-CLI-11 gitbash json has cache_fallback_2" "${_gb}" '"cache_fallback_2":""'
    _gb_fb2=$(printf '%s' "$_gb" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 gitbash no 2nd fallback" "" "${_gb_fb2}"
    _mac=$(HOME="${CI_HOME}" RUOYI_CACHE_HOST=mac bash "${SCRIPT}" --json about 2>/dev/null)
    _mac_pref=$(printf '%s' "$_mac" | sed -n 's/.*"cache_preferred":"\([^"]*\)".*/\1/p' | head -n1)
    _mac_pid="${_mac_pref##*-}"
    assert_eq "TP-CLI-11 mac preferred" "/tmp/cache/cache-${APP_NAME}-${_login}-${_mac_pid}" "${_mac_pref}"
    _mac_fb=$(printf '%s' "$_mac" | sed -n 's/.*"cache_fallback":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 mac 1st fallback" "${CI_HOME}/Library/Caches/cache-${APP_NAME}-${_mac_pid}" "${_mac_fb}"
    _mac_fb2=$(printf '%s' "$_mac" | sed -n 's/.*"cache_fallback_2":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 mac 2nd fallback" "${CI_HOME}/cache/cache-${APP_NAME}-${_mac_pid}" "${_mac_fb2}"
    _hum_l=$(HOME="${CI_HOME}" bash "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-11 linux about used" "${_hum_l}" "Cache folder used:"
    assert_contains "TP-CLI-11 linux about preferred" "${_hum_l}" "Cache folder (preferred):"
    assert_contains "TP-CLI-11 linux about 1st" "${_hum_l}" "Cache folder (1st fallback):"
    assert_contains "TP-CLI-11 linux about 2nd" "${_hum_l}" "Cache folder (2nd fallback):"
    assert_contains "TP-CLI-11 linux about preferred path" "${_hum_l}" "/dev/shm/cache/cache-${APP_NAME}-${_login}-"
    assert_contains "TP-CLI-11 linux about 2nd path" "${_hum_l}" "/.cache/cache-${APP_NAME}-"
    assert_contains "TP-CLI-11 linux about persistence" "${_hum_l}" "Persistence storage:"
    assert_not_contains "TP-CLI-11 no Storage (effective) label" "${_hum_l}" "Storage (effective)"
    assert_not_contains "TP-CLI-11 no Storage (fallback) label" "${_hum_l}" "Storage (fallback)"
    _hum_gb=$(HOME="${CI_HOME}" RUOYI_CACHE_HOST=gitbash bash "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-11 gitbash about 1st" "${_hum_gb}" "AppData/Local/Temp/cache-${APP_NAME}-"
    assert_not_contains "TP-CLI-11 gitbash about omits 2nd" "${_hum_gb}" "Cache folder (2nd fallback)"
    _hum_mac=$(HOME="${CI_HOME}" RUOYI_CACHE_HOST=mac bash "${SCRIPT}" about 2>/dev/null)
    assert_contains "TP-CLI-11 mac about 1st" "${_hum_mac}" "Library/Caches/cache-${APP_NAME}-"
    assert_contains "TP-CLI-11 mac about 2nd path" "${_hum_mac}" "Cache folder (2nd fallback): ${CI_HOME}/cache/cache-${APP_NAME}-"
    _persist=$(printf '%s' "$_out" | sed -n 's/.*"persistence_storage":"\([^"]*\)".*/\1/p' | head -n1)
    assert_eq "TP-CLI-11 persistence_storage path" "${CI_HOME}/.local/${APP_NAME}" "$_persist"
    if [ -n "$_persist" ] && [ -d "$_persist" ]; then
        t_pass "TP-CLI-11 persistence storage directory exists"
    else
        t_fail "TP-CLI-11 persistence storage missing: '${_persist:-empty}'"
    fi
    case "${_persist}" in
        */.local/bin|*/.local/bin/) t_fail "TP-CLI-11 persistence must not be USER_BIN: '${_persist}'" ;;
        *) t_pass "TP-CLI-11 persistence is not the install bin directory" ;;
    esac
    rm -rf "${_eff}" "${_skip_eff}" "${_gb_pref}" "${_mac_pref}" 2>/dev/null || true
    ci_cleanup_env

    # --- unknown command ---
    _err=$(bash "${SCRIPT}" no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 unknown command exit 1" 1 "$_ec"
    assert_contains "TP-CLI-06 unknown command text" "$_err" "Unknown command"

    _err=$(bash "${SCRIPT}" --json no-such-command 2>&1 >/dev/null)
    _ec=$?
    assert_eq "TP-CLI-06 unknown --json exit 1" 1 "$_ec"
    assert_contains "TP-CLI-06 unknown --json error type" "$_err" '"type":"out_error"'

    # --- quiet version ---
    _out=$(bash "${SCRIPT}" --quiet version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-07 version --quiet exit 0" 0 "$_ec"
    _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
    if [ -z "$_trim" ]; then
        t_pass "TP-CLI-07 version --quiet suppresses human info"
    else
        t_fail "TP-CLI-07 version --quiet expected empty stdout, got '$(_trunc "$_out")'"
    fi

    _out=$(bash "${SCRIPT}" -q version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-12 version -q exit 0" 0 "$_ec"
    _trim=$(printf '%s' "$_out" | tr -d ' \t\n\r')
    if [ -z "$_trim" ]; then
        t_pass "TP-CLI-12 version -q suppresses human info"
    else
        t_fail "TP-CLI-12 version -q expected empty stdout, got '$(_trunc "$_out")'"
    fi

    _out=$(bash "${SCRIPT}" --debug --json version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-13 --debug --json version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-13 --debug --json version type" "$_out" '"type":"version"'

    _out=$(bash "${SCRIPT}" --json about --project-dir /tmp/ruoyi-about-proj 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-14 about --project-dir --json exit 0" 0 "$_ec"
    assert_contains "TP-CLI-14 about project_dir override" "$_out" "/tmp/ruoyi-about-proj"

    # --- HOME unset under set -u ---
    _out=$(env -u HOME bash "${SCRIPT}" version 2>/dev/null)
    _ec=$?
    assert_eq "TP-CLI-08 env -u HOME version exit 0" 0 "$_ec"
    assert_contains "TP-CLI-08 env -u HOME still reports version" "$_out" "${PRODUCT_VERSION}"

    # --- zero-arg auto-install propagates failure ---
    ci_isolated_env
    _errf="${CI_HOME}/zero-arg-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        SCRIPT_URL="http://127.0.0.1:1/ruoyi-unreachable" \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    if [ "$_ec" -ne 0 ]; then
        t_pass "TP-CLI-09 zero-arg failed install exits non-zero"
    else
        t_fail "TP-CLI-09 zero-arg failed install expected non-zero, got 0"
    fi
    assert_file_missing "TP-CLI-09 zero-arg failed left no binary" "${CI_USER_BIN}/ruoyi"
    ci_cleanup_env

    # --- self-uninstall --json without force fail-closed ---
    ci_isolated_env
    mkdir -p "${CI_USER_BIN}"
    cp "${SCRIPT}" "${CI_USER_BIN}/ruoyi"
    chmod +x "${CI_USER_BIN}/ruoyi"
    _errf="${CI_HOME}/un-err.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        bash "${SCRIPT}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-CLI-10 self-uninstall --json no force exit 1" 1 "$_ec"
    assert_contains "TP-CLI-10 confirm_required" "$_err" "confirm_required"
    assert_contains "TP-CLI-10 out_error type" "$_err" '"type":"out_error"'
    assert_file_exists "TP-CLI-10 binary remains" "${CI_USER_BIN}/ruoyi"
    ci_cleanup_env
}
