# =============================================================================
# tests/test_install_lifecycle.sh — install / Type O-S empty-argv / version-check
# =============================================================================
# Local HTTP channel (no public network). Primary REQs: online-install,
# zero-arguments (O-S), self-management, automatic-checksum.
# =============================================================================

. "${TESTS_ROOT}/helpers.sh"

run_test_install_lifecycle() {
    t_header "Install lifecycle (local channel)"

    require_cmd curl
    require_cmd python3
    require_cmd sha256sum
    require_cmd bash

    ci_isolated_env
    if ! ci_start_channel; then
        ci_cleanup_env
        return 1
    fi

    _sm_bin="${CI_USER_BIN}/ruoyi"
    _errf="${CI_HOME}/lc-err.txt"

    # --- install ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" --json install 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-01 install --json exit 0" 0 "$_ec"
    assert_contains "TP-INST-01 install success type" "$_out" '"type":"out_success"'
    assert_contains "TP-INST-01 install path" "$_out" "${_sm_bin}"
    assert_file_exists "TP-INST-01 binary exists" "${_sm_bin}"

    # --- idempotent re-install ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" --json install 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-02 re-install exit 0" 0 "$_ec"
    assert_contains "TP-INST-02 already installed" "$_out" "already installed"

    # --- zero-arg Type O-S Case B (local) ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-03 zero-arg Case B exit 0" 0 "$_ec"
    assert_contains "TP-INST-03 Case B already installed" "$_out" "already installed"
    assert_not_contains "TP-INST-03 Case B not help dump" "$_out" "RuoYi domain commands"
    assert_not_contains "TP-INST-03 Case B not domain setup" "$_out" "SDKMAN"

    # --- zero-arg Case C (global path present) ---
    _global_bin="${CI_HOME}/global-bin"
    mkdir -p "${_global_bin}"
    cp "${SCRIPT}" "${_global_bin}/ruoyi"
    chmod +x "${_global_bin}/ruoyi"
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" GLOBAL_BIN="${_global_bin}" \
        SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-04 zero-arg Case C exit 0" 0 "$_ec"
    assert_contains "TP-INST-04 Case C already installed" "$_out" "already installed"
    assert_not_contains "TP-INST-04 Case C not help" "$_out" "RuoYi domain commands"
    rm -f "${_global_bin}/ruoyi"

    # --- about after install ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" --json about 2>/dev/null
    )
    _ec=$?
    assert_eq "TP-INST-05 about after install exit 0" 0 "$_ec"
    assert_contains "TP-INST-05 about installed true" "$_out" '"installed":"true"'

    # --- version-check ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json version-check 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-06 version-check --json exit 0" 0 "$_ec"
    assert_contains "TP-INST-06 ver_check type" "$_out" '"type":"ver_check"'
    assert_contains "TP-INST-06 local_version" "$_out" "\"local_version\":\"${PRODUCT_VERSION}\""
    assert_contains "TP-INST-06 remote_version" "$_out" "\"remote_version\":\"${PRODUCT_VERSION}\""
    assert_contains "TP-INST-06 is_latest" "$_out" '"is_latest":"true"'

    # --- self-update already-latest ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json self-update 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-07 self-update already-latest exit 0" 0 "$_ec"
    assert_contains "TP-INST-07 already latest message" "$_out" "Already running the latest version"

    # --- human --force install integrity transparency ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" --force install 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-08 human --force install exit 0" 0 "$_ec"
    assert_contains "TP-INST-08 companion link" "$_out" "Companion link:"
    assert_contains "TP-INST-08 expected digest" "$_out" "Expected SHA-256:"
    assert_contains "TP-INST-08 PASS" "$_out" "Automatic checksum result: PASS"

    # --- self-uninstall without force fail-closed ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    _err=$(cat "${_errf}" 2>/dev/null || true)
    assert_eq "TP-INST-09 self-uninstall no force exit 1" 1 "$_ec"
    assert_contains "TP-INST-09 confirm_required" "$_err" "confirm_required"
    assert_file_exists "TP-INST-09 binary remains" "${_sm_bin}"

    # --- self-uninstall --force ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        PATH="${CI_USER_BIN}:${PATH}" \
        bash "${_sm_bin}" --force --json self-uninstall 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-10 self-uninstall --force exit 0" 0 "$_ec"
    assert_file_missing "TP-INST-10 binary removed" "${_sm_bin}"

    # --- empty-argv Case A success (not installed + working channel) ---
    _out=$(
        HOME="${CI_HOME}" USER_BIN="${CI_USER_BIN}" SCRIPT_URL="${CI_SCRIPT_URL}" \
        bash "${SCRIPT}" </dev/null 2>"${_errf}"
    )
    _ec=$?
    assert_eq "TP-INST-11 zero-arg Case A exit 0" 0 "$_ec"
    assert_file_exists "TP-INST-11 Case A binary exists" "${_sm_bin}"
    assert_not_contains "TP-INST-11 Case A not help dump" "$_out" "RuoYi domain commands"

    ci_stop_channel
    ci_cleanup_env
}
