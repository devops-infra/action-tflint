#!/usr/bin/env bash

set -e

# Split dir_filter into array
IFS=',' read -r -a ARRAY <<< "${INPUT_DIR_FILTER}"

# Go through all dir prefixes
for PREFIX in "${ARRAY[@]}"
do
    # Go through all matching directories
    for DIRECTORY in $(ls -d ${PREFIX}*/); do
        cd ${DIRECTORY}
        echo -e "\nDirectory: ${DIRECTORY}"
        if [[ -f "/github/workspace/${TFLINT_CONFIG}" ]]; then
            tflint -c "/github/workspace/${TFLINT_CONFIG}"
        else
            tflint
        fi
        cd -
    done
done
