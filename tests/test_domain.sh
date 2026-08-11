# =============================================================================
# tests/test_domain.sh — RuoYi domain surface (TP-DOM-*)
# =============================================================================
# Offline stubs for sdk/java/mvn/git. Primary REQ: requirement-domain-ruoyi.
# Type O-S: empty argv does NOT run domain (asserted in lifecycle).
# =============================================================================

. "${TESTS_ROOT}/helpers.sh"

run_test_domain() {
    t_header "Domain surface"

    require_cmd bash
    require_cmd grep

    # --- help domain pins / flags ---
    _out=$(bash "${SCRIPT}" help 2>/dev/null)
    assert_contains "TP-DOM-01 help Java pin surface" "$_out" "Java"
    assert_contains "TP-DOM-01 help setup" "$_out" "setup"
    assert_contains "TP-DOM-01 help --no-run" "$_out" "--no-run"
    assert_contains "TP-DOM-01 help --project-dir" "$_out" "--project-dir"
    assert_contains "TP-DOM-01 help mariadb" "$_out" "mariadb"
    assert_contains "TP-DOM-01 help mysql" "$_out" "mysql"
    assert_contains "TP-DOM-01 help redis" "$_out" "redis"
    assert_contains "TP-DOM-01 help run" "$_out" "run"
    assert_contains "TP-DOM-01 help db-extract" "$_out" "db-extract"

    # --- isolated setup --no-run with stubs ---
    require_cmd curl
    require_cmd python3

    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi
    ci_stub_domain_toolchain

    _errf="${CI_HOME}/dom-err.txt"
    _proj="${CI_HOME}/ruoyi-demo-proj"

    # Install CLI first so about/setup paths are stable
    HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" --json install >/dev/null 2>"${_errf}"
    assert_file_exists "TP-DOM-02 CLI installed for domain tests" "${CI_USER_BIN}/ruoyi"

    # setup --no-run --project-dir
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" setup --no-run --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-DOM-03 setup --no-run exit 0" 0 "$_ec"
    assert_file_exists "TP-DOM-03 project dir" "${_proj}"
    assert_file_exists "TP-DOM-03 pom from clone stub" "${_proj}/pom.xml"
    if printf '%s' "${_out}${_err}" | grep -qE "setup completed|Project location|ready at"; then
        t_pass "TP-DOM-03 setup completion signal"
    else
        t_fail "TP-DOM-03 missing setup success text: '$(_trunc "${_out}${_err}")'"
    fi

    # preserve: second setup should backup not wipe marker when project exists
    # (clone may force; we only check command still routes)
    printf 'KEEP\n' > "${_proj}/USER_MARK.txt"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" setup --no-run --project-dir "${_proj}" 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-DOM-04 second setup exit 0" 0 "$_ec"

    # run routes (stub java/mvn — may fail build; must not be unknown command)
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" PROJECT_DIR="${_proj}" \
        bash "${SCRIPT}" run 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if printf '%s' "${_out}${_err}" | grep -qi 'Unknown command'; then
        t_fail "TP-DOM-05 run unknown command (help↔dispatcher)"
    else
        t_pass "TP-DOM-05 run routed (exit=${_ec})"
    fi

    # db-extract routes
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" \
        PATH="${CI_STUB_BIN}:${PATH}" PROJECT_DIR="${_proj}" \
        bash "${SCRIPT}" db-extract 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    if printf '%s' "${_out}${_err}" | grep -qi 'Unknown command'; then
        t_fail "TP-DOM-06 db-extract unknown command"
    else
        t_pass "TP-DOM-06 db-extract routed (exit=${_ec})"
    fi

    # empty argv still Type O-S (CLI only) when installed — not domain
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_STUB_BIN}:${PATH}" \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-DOM-07 empty-argv not domain exit 0" 0 "$_ec"
    assert_contains "TP-DOM-07 empty-argv already installed" "$_out" "already installed"
    assert_not_contains "TP-DOM-07 empty-argv not clone" "$_out" "Cloning"

    ci_stop_channel
    ci_cleanup_env
}
