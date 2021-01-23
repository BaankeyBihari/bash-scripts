#!/bin/bash

SCRIPTSPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
unset COMMIT PUSH MESSAGE AMEND

usage() {
    echo "Usage: $0 "
    echo "          [-l gets latest from git repo]"
    echo "          [-s saves all config to scripts folder]"
    echo "          [-a saves all config to scripts folder and amends last commit]"
    echo "          [-c saves all config to scripts folder and creates a commit]"
    echo "          [-p saves all config to scripts folder and creates a commit and then pushes to git repo]"
    echo "          [-m commit message, if not provided then uses date in UTC]"
    exit 1
}

saves () {
    (cp ~/.bashrc ${SCRIPTSPATH}/bash && cp ~/.bash_aliases ${SCRIPTSPATH}/bash)
}

while getopts ":lsacpm:" option; do
    case "${option}" in
    l)
        # get latest from repository
        files=$(cd ${SCRIPTSPATH} && ls .[^.]*)
        [ ! -z "${files}" ] && (cd ${SCRIPTSPATH} && git pull --rebase && cp -rf bash/.[^.]* ~/)
        files=$(cd ${SCRIPTSPATH} && ls bash/)
        [ ! -z "${files}" ] && (cd ${SCRIPTSPATH} && git pull --rebase && cp -rf bash/* ~/)
        ;;
    s)
        # saves current config to scripts folder
        saves
        ;;
    a)
        # saves current config to scripts folder
        saves
        AMEND=YES
        ;;
    c)
        # saves current config to scripts folder and commits it
        saves
        COMMIT=YES
        ;;
    p)
        # saves current config to scripts folder, commits it and pushes it
        saves
        COMMIT=YES
        PUSH=YES
        ;;
    m)
        MESSAGE+=("${OPTARG}")
        ;;
    *)
        usage
        ;;
    esac
done
shift $((OPTIND - 1))

if [ ! -z ${AMEND} ]; then
    (cd ${SCRIPTSPATH} && git add . && git status && git commit --amend --no-edit)
fi

if [ ! -z ${COMMIT} ]; then
    if [ ${#MESSAGE[@]} -gt 0 ]; then
        MESSAGE=$(printf "\n%s" "${MESSAGE[@]}")
    fi
    MESSAGE="${MESSAGE}"
    (cd ${SCRIPTSPATH} && git add . && git status && git commit -m "${MESSAGE}")
fi

if [ ! -z ${PUSH} ]
then
    (cd ${SCRIPTSPATH} && git pull --rebase && git push)
fi
