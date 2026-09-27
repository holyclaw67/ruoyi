# =============================================================================
# tests/helpers.sh — shared assertions for ruoyi CI tests
# =============================================================================
# Source from test scripts (POSIX /bin/sh). Does not modify product code.
# Ship unit is bash (SDKMAN domain); invoke with bash.
# =============================================================================

# shellcheck disable=SC2034
: "${TESTS_ROOT:=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)}"
: "${REPO_ROOT:=$(CDPATH= cd -- "${TESTS_ROOT}/.." && pwd)}"
: "${APP_NAME:=ruoyi}"
: "${SCRIPT:=${REPO_ROOT}/src/${APP_NAME}}"
: "${PASS:=0}"
: "${FAIL:=0}"
: "${SKIP:=0}"
PRODUCT_VERSION=$(grep '^VERSION="' "${SCRIPT}" 2>/dev/null | head -n1 | cut -d'"' -f2)
: "${PRODUCT_VERSION:=unknown}"
PRODUCT_APP=$(grep '^APP_NAME="' "${SCRIPT}" 2>/dev/null | head -n1 | cut -d'"' -f2)
: "${PRODUCT_APP:=${APP_NAME}}"
JAVA_VERSION=$(grep '^: "${JAVA_VERSION:=' "${SCRIPT}" 2>/dev/null | head -n1 | sed 's/.*JAVA_VERSION:=//;s/}".*//')
: "${JAVA_VERSION:=21}"
MAVEN_VER=$(grep '^: "${MAVEN_VER:=' "${SCRIPT}" 2>/dev/null | head -n1 | sed 's/.*MAVEN_VER:=//;s/}".*//')
: "${MAVEN_VER:=3.9.14}"

t_info()  { printf '  · %s\n' "$*"; }
t_pass()  { PASS=$((PASS + 1)); printf '  PASS  %s\n' "$*"; }
t_fail()  { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$*" >&2; }
t_skip()  { SKIP=$((SKIP + 1)); printf '  SKIP  %s\n' "$*"; }
t_header() { printf '\n== %s ==\n' "$*"; }

assert_eq() {
    _lab="$1"; _exp="$2"; _act="$3"
    if [ "$_exp" = "$_act" ]; then t_pass "$_lab"
    else t_fail "$_lab (expected='$(_trunc "$_exp")' actual='$(_trunc "$_act")')"
    fi
}

assert_contains() {
    _lab="$1"; _hay="$2"; _ndl="$3"
    case "$_hay" in
        *"$_ndl"*) t_pass "$_lab" ;;
        *) t_fail "$_lab (missing '$(_trunc "$_ndl")' in '$(_trunc "$_hay")')" ;;
    esac
}

assert_not_contains() {
    _lab="$1"; _hay="$2"; _ndl="$3"
    case "$_hay" in
        *"$_ndl"*) t_fail "$_lab (unexpected '$(_trunc "$_ndl")')" ;;
        *) t_pass "$_lab" ;;
    esac
}

assert_file_exists() {
    _lab="$1"; _path="$2"
    if [ -e "$_path" ]; then t_pass "$_lab"
    else t_fail "$_lab (missing $_path)"
    fi
}

assert_file_missing() {
    _lab="$1"; _path="$2"
    if [ -e "$_path" ]; then t_fail "$_lab (still exists: $_path)"
    else t_pass "$_lab"
    fi
}

assert_nonzero() {
    _lab="$1"; _act="$2"
    if [ "$_act" -ne 0 ]; then t_pass "$_lab"
    else t_fail "$_lab (expected non-zero exit, got 0)"
    fi
}

_trunc() {
    printf '%s' "$1" | tr '\n' ' ' | cut -c1-160
}

ci_start_channel() {
    CI_CHANNEL_DIR=$(mktemp -d "${TMPDIR:-/tmp}/ry-channel.XXXXXX")
    cp "${SCRIPT}" "${CI_CHANNEL_DIR}/${APP_NAME}"
    sha256sum "${CI_CHANNEL_DIR}/${APP_NAME}" | awk '{print $1}' > "${CI_CHANNEL_DIR}/${APP_NAME}.sha256"

    CI_PORT=$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()')
    (
        cd "${CI_CHANNEL_DIR}" || exit 1
        exec python3 -m http.server "${CI_PORT}" --bind 127.0.0.1
    ) >/dev/null 2>&1 &
    CI_HTTP_PID=$!
    CI_SCRIPT_URL="http://127.0.0.1:${CI_PORT}/${APP_NAME}"

    _i=0
    while [ "$_i" -lt 50 ]; do
        if curl -fsS "${CI_SCRIPT_URL}" >/dev/null 2>&1; then
            return 0
        fi
        sleep 0.1
        _i=$((_i + 1))
    done
    t_fail "local channel failed to start on port ${CI_PORT}"
    return 1
}

ci_stop_channel() {
    if [ -n "${CI_HTTP_PID:-}" ]; then
        kill "${CI_HTTP_PID}" 2>/dev/null || true
        wait "${CI_HTTP_PID}" 2>/dev/null || true
        CI_HTTP_PID=
    fi
    if [ -n "${CI_CHANNEL_DIR:-}" ] && [ -d "${CI_CHANNEL_DIR}" ]; then
        rm -rf "${CI_CHANNEL_DIR}"
        CI_CHANNEL_DIR=
    fi
}

ci_isolated_env() {
    CI_HOME=$(mktemp -d "${TMPDIR:-/tmp}/ry-home.XXXXXX")
    CI_USER_BIN="${CI_HOME}/.local/bin"
    mkdir -p "${CI_USER_BIN}"
    export HOME="${CI_HOME}"
    export USER_BIN="${CI_USER_BIN}"
    unset CHECKSUM 2>/dev/null || true
}

ci_cleanup_env() {
    if [ -n "${CI_HOME:-}" ] && [ -d "${CI_HOME}" ]; then
        rm -rf "${CI_HOME}"
        CI_HOME=
        CI_USER_BIN=
    fi
}

# Offline domain stubs: sdk/java/mvn/git so setup --no-run can run without network.
ci_stub_domain_toolchain() {
    CI_STUB_BIN="${CI_HOME}/stub-bin"
    mkdir -p "${CI_STUB_BIN}" "${CI_HOME}/.sdkman/bin"
    # sdkman-init no-op so setup_sdkman can source it under set +u
    printf '%s\n' '#!/bin/sh' 'return 0 2>/dev/null || true' > "${CI_HOME}/.sdkman/bin/sdkman-init.sh"
    cat > "${CI_STUB_BIN}/sdk" <<'STUB'
#!/bin/sh
# Accept install/default/use; succeed offline
exit 0
STUB
    cat > "${CI_STUB_BIN}/java" <<'STUB'
#!/bin/sh
if [ "${1-}" = "-version" ]; then
    echo 'openjdk version "21.0.0" 2024-01-01' >&2
    exit 0
fi
exit 0
STUB
    cat > "${CI_STUB_BIN}/mvn" <<'STUB'
#!/bin/sh
if [ "${1-}" = "-version" ] || [ "${1-}" = "--version" ]; then
    echo 'Apache Maven 3.9.14'
    exit 0
fi
exit 0
STUB
    cat > "${CI_STUB_BIN}/git" <<'STUB'
#!/bin/sh
# Create dest directory = last argument (git clone --depth 1 URL DEST)
dest=""
for a in "$@"; do
    dest="$a"
done
case "$dest" in
    ""|clone|--depth|--branch|-b|http*|git@*|*github*|*gitee*)
        # Prefer last path-like arg
        dest=""
        for a in "$@"; do
            case "$a" in
                /*|[a-zA-Z0-9_.-]*) dest="$a" ;;
            esac
        done
        ;;
esac
# Final: always take last argv token for clone DEST
dest=""
for a in "$@"; do dest="$a"; done
if [ -n "$dest" ]; then
    mkdir -p "$dest/ruoyi-admin/src/main/resources" || exit 1
    printf '%s
' '<project><modelVersion>4.0.0</modelVersion></project>' > "$dest/pom.xml"
    printf '%s
' 'server:
  port: 80' > "$dest/ruoyi-admin/src/main/resources/application.yml"
    exit 0
fi
exit 1
STUB
    chmod +x "${CI_STUB_BIN}/sdk" "${CI_STUB_BIN}/java" "${CI_STUB_BIN}/mvn" "${CI_STUB_BIN}/git"
    export PATH="${CI_STUB_BIN}:${PATH}"
}

ci_run() {
    bash "${SCRIPT}" "$@"
}

require_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        t_fail "required command missing: $1"
        return 1
    fi
    return 0
}

# First token of companion file (supports "hash" or "hash  filename")
ci_digest_hex() {
    # ci_digest_hex <file>
    tr -d '\r' < "$1" | awk '{print $1; exit}'
}
