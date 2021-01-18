#!/bin/bash

trap "trap - SIGTERM && kill -- -$$" SIGINT SIGTERM EXIT

# Common parameters and variables
IQ_FOLDER=~/iq
PIPE=${IQ_FOLDER}/pipe
COMMAND_FOLDER=${IQ_FOLDER}/commandFolder
SCRIPT_PATH=$0

# Server Parameters and variables
SERVER_JOB_LIMIT=0
SERVER_LAUNCH_DELAY=5
CURRENT_COMMAND_QUEUE=''
unset SERVER_CURRENT_CMD SERVER_CURRENT_LINE_NO

# Client Parameters and variables
SERVER_LAUNCH_COMMAND="${SCRIPT_PATH} server|& tee ${IQ_FOLDER}/server.log"
SERVER_SCREEN_NAME="iqServer"

update() {
    CURRENT_COMMAND_QUEUE=$(cat "${PIPE}" | head -1)
    SERVER_JOB_LIMIT=$(cat "${PIPE}" | head -2 | tail -1)
    SERVER_LAUNCH_DELAY=$(cat "${PIPE}" | head -3 | tail -1)
}

command_handler() {
    local option cmd update file status OPTIND
    while getopts :u:s:f:g option; do
        case "${option}" in
        g)
            unset SERVER_CURRENT_CMD SERVER_CURRENT_LINE_NO
            SERVER_CURRENT_CMD=$(grep -v -e "^running:" -e"^completed:" ${CURRENT_COMMAND_QUEUE} | tail -1)
            if [ ! -z "${SERVER_CURRENT_CMD}" ]; then
                SERVER_CURRENT_LINE_NO=$(grep -n -v -e "^running:" -e"^completed:" ${CURRENT_COMMAND_QUEUE} | tail -1 | cut -f 1 -d ':')
            fi
            ;;
        p)
            cmd=${OPTARG}
            current_dir=$(pwd)
            echo "cd ${current_dir}; ${cmd}" >>"${CURRENT_COMMAND_QUEUE}"
            ;;
        u)
            update="${OPTARG}"
            ;;
        f)
            file="${OPTARG}"
            ;;
        s)
            status="${OPTARG}"
            ;;
        *) ;;
        esac
    done
    shift $((OPTIND - 1))
    if [ ! -z "${update}" ] && [ -f "${file}" ]; then
        case ${status} in
        running)
            sed -i "${update}s/\(.*\)/running:\1/" "${file}"
            ;;
        completed)
            sed -i "${update}s/\(running:\)\(.*\)/completed:\2/" "${file}"
            ;;
        esac
    fi
    return
}

server_check_for_exit() {
    if [[ ! -f "${PIPE}" ]]; then
        echo "Quitting"
        rm -rf "${COMMAND_FOLDER}/*"
        exit 0
    fi
}

server_launch_job() {
    local current_server_jobs=$(pgrep -P $$ | wc -l)
    current_server_jobs=$(expr ${current_server_jobs} - 1)
    if [ "${current_server_jobs}" -lt "${SERVER_JOB_LIMIT}" ] || [ "${SERVER_JOB_LIMIT}" -eq 0 ]; then
        if [ ! -z "${SERVER_CURRENT_CMD}" ]; then
            (
                eval "${SERVER_CURRENT_CMD}"
                command_handler -u "${SERVER_CURRENT_LINE_NO}" -s "completed" -f "${CURRENT_COMMAND_QUEUE}"
            ) &
            command_handler -u "${SERVER_CURRENT_LINE_NO}" -s "running" -f "${CURRENT_COMMAND_QUEUE}"
        fi
    fi
}

server() {
    while true; do
        server_check_for_exit
        update
        command_handler -g
        server_launch_job
        echo "Sleeping..."
        sleep "${SERVER_LAUNCH_DELAY}"
        date
    done
}

check_init() {
    [[ -d "${COMMAND_FOLDER}" ]] || mkdir -p "${COMMAND_FOLDER}"

    if [[ ! -f "${PIPE}" ]]; then
        rm -rf "${COMMAND_FOLDER}/*" || true
        echo "Starting ibuildServer"
        (screen -X -S ibuild quit) || true
        touch "${PIPE}"
        f=$(mktemp "${COMMAND_FOLDER}"/command.XXX)
        touch "${f}"
        echo "${f}" >"${PIPE}"
        echo "${SERVER_JOB_LIMIT}" >>"${PIPE}"
        echo "${SERVER_LAUNCH_DELAY}" >>"${PIPE}"
        screen -S ${SERVER_SCREEN_NAME} -dm bash -ic "${SERVER_LAUNCH_COMMAND};"
    fi
}

client() {
    check_init
    if [[ "$*" ]]; then
        case "$*" in
        "abort")
            rm ${PIPE}
            screen -X -S ${SERVER_SCREEN_NAME} quit
            ;;
        "server")
            server
            ;;
        "quit")
            rm ${PIPE}
            ;;
        "update_delay")
            update
            echo "${CURRENT_COMMAND_QUEUE}" >"${PIPE}"
            echo "${SERVER_JOB_LIMIT}" >>"${PIPE}"
            echo "$2" >>"${PIPE}"
            ;;
        "update_job_limit")
            update
            echo "${CURRENT_COMMAND_QUEUE}" >"${PIPE}"
            echo "$2" >>"${PIPE}"
            echo "${SERVER_LAUNCH_DELAY}" >>"${PIPE}"
            ;;
        "flush")
            f=$(mktemp "${commandFolder}"/command.XXX)
            cat /dev/null >${IQ_FOLDER}/server.log
            touch "${f}"
            echo "${f}" >"${PIPE}"
            echo "${SERVER_JOB_LIMIT}" >>"${PIPE}"
            echo "${SERVER_LAUNCH_DELAY}" >>"${PIPE}"
            ;;
        *)
            f=$(cat "${PIPE}" | head -1)
            current_dir=$(pwd)
            echo "${current_dir}"
            echo "Command: $*"
            echo "cd ${current_dir}; $*" >>$f
            ;;
        esac
    else
        f=$(cat "${PIPE}" | head -1)
        cat ${PIPE}
        cat "${f}"
    fi
}

client $*
exit 0