#!/usr/bin/env bash

RETURN=0

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
            if [[ $? != 0 ]]; then
                RETURN=$?
            fi
        else
            tflint
            if [[ $? != 0 ]]; then
                RETURN=$?
            fi
        fi
        cd -
    done
done

exit ${RETURN}
