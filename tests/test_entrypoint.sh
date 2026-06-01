#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ENTRYPOINT="${ROOT_DIR}/entrypoint.sh"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

PASS_COUNT=0
FAIL_COUNT=0

pass() {
  PASS_COUNT=$((PASS_COUNT + 1))
  printf '[PASS] %s\n' "$1"
}

fail() {
  FAIL_COUNT=$((FAIL_COUNT + 1))
  printf '[FAIL] %s\n' "$1"
}

assert_contains() {
  local needle="$1"
  local file="$2"
  grep -Fq -- "${needle}" "${file}"
}

run_case() {
  local name="$1"
  local expect_rc="$2"
  shift 2

  local case_dir="${TMP_DIR}/${name}"
  mkdir -p "${case_dir}/bin" "${case_dir}/workspace/terraform/module"

  cat > "${case_dir}/bin/tflint" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf '%s\n' "$*" >> "${FAKE_TFLINT_CALLS}"
if [[ "$*" == "--init" ]]; then
  exit 0
fi
exit 0
EOF

  cat > "${case_dir}/bin/terraform" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
printf 'terraform %s\n' "$*" >> "${FAKE_TERRAFORM_CALLS}"
exit 0
EOF

  chmod +x "${case_dir}/bin/tflint" "${case_dir}/bin/terraform"

  local calls_file="${case_dir}/tflint_calls.txt"
  local terraform_calls_file="${case_dir}/terraform_calls.txt"
  local stdout_file="${case_dir}/stdout.txt"
  local stderr_file="${case_dir}/stderr.txt"

  : > "${calls_file}"
  : > "${terraform_calls_file}"

  cat > "${case_dir}/workspace/terraform/module/main.tf" <<'EOF'
terraform {
  required_version = ">= 1.0.0"
}
EOF

  cat > "${case_dir}/workspace/.tflint.hcl" <<'EOF'
config {
  module = false
}
EOF

  set +e
  (
    export PATH="${case_dir}/bin:${PATH}"
    export WORK_DIR="${case_dir}/workspace"
    export FAKE_TFLINT_CALLS="${calls_file}"
    export FAKE_TERRAFORM_CALLS="${terraform_calls_file}"
    export INPUT_DIR_FILTER="terraform"
    export INPUT_RUN_INIT="false"
    export INPUT_FAIL_ON_CHANGES="false"
    export INPUT_TFLINT_CONFIG=".tflint.hcl"
    export INPUT_TFLINT_PARAMS=""
    cd "${case_dir}/workspace"
    "$@" "${ENTRYPOINT}"
  ) > "${stdout_file}" 2> "${stderr_file}"
  local rc=$?
  set -e

  if [[ "${rc}" -ne "${expect_rc}" ]]; then
    fail "${name} (expected rc=${expect_rc}, got ${rc})"
    return
  fi

  pass "${name}"
}

run_case with-config 0 env
run_case with-params 0 env INPUT_TFLINT_CONFIG="missing.hcl" INPUT_TFLINT_PARAMS="--minimum-failure-severity=error --no-color"

config_calls="${TMP_DIR}/with-config/tflint_calls.txt"
if assert_contains '--init' "${config_calls}" && assert_contains '-c ' "${config_calls}"; then
  pass 'config mode builds args correctly'
else
  fail 'config mode builds args correctly'
fi

params_calls="${TMP_DIR}/with-params/tflint_calls.txt"
if assert_contains '--minimum-failure-severity=error' "${params_calls}" && assert_contains '--no-color' "${params_calls}"; then
  pass 'params mode splits args correctly'
else
  fail 'params mode splits args correctly'
fi

if [[ "${FAIL_COUNT}" -gt 0 ]]; then
  printf '\nTests failed: %s, passed: %s\n' "${FAIL_COUNT}" "${PASS_COUNT}"
  exit 1
fi

printf '\nAll tests passed: %s\n' "${PASS_COUNT}"
