#!/bin/bash

usage() {
    echo "Usage: $0 "
    echo "          [-s sleeps for S>0 seconds between calls]"
    echo "          [-n repeats for n times, infinitely if not provided or is 0]"
    echo "          [-d displays date before executing command]"
    echo "          [-c commandlets to be executed eg -c \"ls <some_path>\" -c \"ls <some_other_path>\"]"
    exit 1
}

SLEEP=0
N=0
CMD=()
DISPLAY_DATE=NO

while getopts ":s:p:c:d" option; do
    case "${option}" in
    s)
        SLEEP=${OPTARG}
        [[ "${SLEEP}" -gt 0 ]] || usage
        ;;
    p)
        N=${OPTARG}
        [[ ${N} -ge 0 ]] || usage
        ;;
    c)
        CMD+=("${OPTARG}")
        ;;
    d)
        DISPLAY_DATE=YES
        ;;
    *)
        usage
        ;;
    esac
done
shift $((OPTIND - 1))

CMD=$(printf " && %s" "${CMD[@]}")
if [ "${DISPLAY_DATE}" == "YES" ]; then
    CMD="date${CMD}"
else
    CMD=${CMD:4}
fi

COUNT=0
while [ "${N}" -eq 0 ] || [ "${COUNT}" -lt "${N}" ]; do
    eval "${CMD[@]}"
    sleep ${SLEEP}
done
