#!/usr/bin/env bash

# Return code
RET_CODE=0

WORK_DIR=/github/workspace

# Split dir_filter into array
IFS=',' read -r -a ARRAY <<< "${INPUT_DIR_FILTER}"

# Go through all dir prefixes
for PREFIX in "${ARRAY[@]}"; do
    # Go through all matching directories
    for DIRECTORY in $(ls -d ${PREFIX}*/); do
        cd ${DIRECTORY}
        echo -e "\nDirectory: ${DIRECTORY}"
        if [[ -f "${WORK_DIR}/${INPUT_TFLINT_CONFIG}" ]]; then
            tflint -c "${WORK_DIR}/${INPUT_TFLINT_CONFIG}" || RET_CODE=1
        else
            tflint ${INPUT_TFLINT_PARAMS} || RET_CODE=1
        fi
        cd ${WORK_DIR}
    done
done

exit ${RET_CODE}
