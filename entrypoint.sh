#!/usr/bin/env bash

set -Eeuo pipefail

# Return code
RET_CODE=0

WORK_DIR="${WORK_DIR:-/github/workspace}"

INPUT_FAIL_ON_CHANGES="${INPUT_FAIL_ON_CHANGES:-true}"
INPUT_DIR_FILTER="${INPUT_DIR_FILTER:-.}"
INPUT_TFLINT_CONFIG="${INPUT_TFLINT_CONFIG:-.tflint.hcl}"
INPUT_TFLINT_PARAMS="${INPUT_TFLINT_PARAMS:-}"
INPUT_RUN_INIT="${INPUT_RUN_INIT:-false}"

echo "Inputs:"
echo "  fail_on_changes: ${INPUT_FAIL_ON_CHANGES}"
echo "  dir_filter: ${INPUT_DIR_FILTER}"
echo "  tflint_config: ${INPUT_TFLINT_CONFIG}"
echo "  tflint_params: ${INPUT_TFLINT_PARAMS}"
echo "  run_init: ${INPUT_RUN_INIT}"

# Split dir_filter into array
IFS=',' read -r -a ARRAY <<< "${INPUT_DIR_FILTER}"

build_tflint_cmd() {
  local -a cmd

  if [[ -f "${WORK_DIR}/${INPUT_TFLINT_CONFIG}" ]]; then
    cmd=(tflint -c "${WORK_DIR}/${INPUT_TFLINT_CONFIG}")
  else
    cmd=(tflint)
    if [[ -n "${INPUT_TFLINT_PARAMS}" ]]; then
      # shellcheck disable=SC2206
      local extra_args=( ${INPUT_TFLINT_PARAMS} )
      cmd+=("${extra_args[@]}")
    fi
  fi

  printf '%s\n' "${cmd[@]}"
}

handle_tflint_failure() {
  local directory="$1"
  if [[ "${INPUT_FAIL_ON_CHANGES}" == "true" ]]; then
    RET_CODE=1
  else
    echo "[WARN] Ignoring TFLint findings in '${directory}' because fail_on_changes=false"
  fi
}

# Go through all dir prefixes
for PREFIX in "${ARRAY[@]}"; do
    # Go through all matching directories
    for DIRECTORY in "${PREFIX}"*; do
        [[ -d "${DIRECTORY}" ]] || break
        cd "${WORK_DIR}/${DIRECTORY}" || RET_CODE=1
        echo -e "\nDirectory: ${DIRECTORY}"
        if [[ "${INPUT_RUN_INIT}" == "true" ]]; then
          terraform init || RET_CODE=1
        fi

        mapfile -t tflint_cmd < <(build_tflint_cmd)

        set +e
        tflint --init
        init_rc=$?
        if [[ "${init_rc}" -eq 0 ]]; then
          "${tflint_cmd[@]}"
          lint_rc=$?
        else
          lint_rc=${init_rc}
        fi
        set -e

        if [[ "${lint_rc}" -ne 0 ]]; then
          handle_tflint_failure "${DIRECTORY}"
        fi

        cd "${WORK_DIR}" || RET_CODE=1
    done
done

# Finish
if [[ "${RET_CODE}" != "0" ]]; then
  echo -e "\n[ERROR] Check log for errors."
  exit 1
else
  # Pass in other cases
  echo -e "\n[INFO] No errors found."
  exit 0
fi
