# =============================================================================
# tests/test_cli.sh — Type 0 CLI surface + domain help (TP-CLI-*)
# =============================================================================
# Covers: bash -n, companion digest, version/help/about (human+JSON),
# domain verbs in help, CHECKSUM absent, unknown command, quiet, env -u HOME,
# zero-arg install failure exit, self-uninstall fail-closed JSON,
# about storage JSON (TP-CLI-11).
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
