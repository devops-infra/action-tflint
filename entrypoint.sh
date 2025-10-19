#!/usr/bin/env bash

set -Eeuo pipefail

# Return code
RET_CODE=0

WORK_DIR=/github/workspace

echo "Inputs:"
echo "  fail_on_changes: ${INPUT_FAIL_ON_CHANGES}"
echo "  dir_filter: ${INPUT_DIR_FILTER}"
echo "  tflint_config: ${INPUT_TFLINT_CONFIG}"
echo "  tflint_params: ${INPUT_TFLINT_PARAMS}"
echo "  run_init: ${INPUT_RUN_INIT}"

# Split dir_filter into array
IFS=',' read -r -a ARRAY <<< "${INPUT_DIR_FILTER}"

# Go through all dir prefixes
for PREFIX in "${ARRAY[@]}"; do
    # Go through all matching directories
    for DIRECTORY in "${PREFIX}"*; do
        [[ -d "${DIRECTORY}" ]] || break
        cd "${WORK_DIR}/${DIRECTORY}" || RET_CODE=1
        echo -e "\nDirectory: ${DIRECTORY}"
        if [[ -f "${WORK_DIR}/${INPUT_TFLINT_CONFIG}" ]]; then
          if [[ "${INPUT_RUN_INIT}" == "true" ]]; then
            terraform init
          fi
          tflint --init && tflint -c "${WORK_DIR}/${INPUT_TFLINT_CONFIG}" || RET_CODE=1
        else
          if [[ "${INPUT_RUN_INIT}" == "true" ]]; then
            terraform init
          fi
          tflint --init && tflint "${INPUT_TFLINT_PARAMS}" || RET_CODE=1
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
