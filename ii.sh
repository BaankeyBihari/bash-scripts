#!/bin/bash

# Sourced from https://tldp.org/LDP/abs/html/sample-bashrc.html

function mydf() { # Pretty-print of 'df' output.
    # Inspired by 'dfc' utility.
    for fs; do

        if [ ! -d $fs ]; then
            echo -e $fs" :No such file or directory"
            continue
        fi

        local info=($(command df -P $fs | awk 'END{ print $2,$3,$5 }'))
        local free=($(command df -Pkh $fs | awk 'END{ print $4 }'))
        local nbstars=$((20 * ${info[1]} / ${info[0]}))
        local out="["
        for ((j = 0; j < 20; j++)); do
            if [ ${j} -lt ${nbstars} ]; then
                out=$out"*"
            else
                out=$out"-"
            fi
        done
        out=${info[2]}" "$out"] ("$free" free on "$fs")"
        echo -e $out
    done
}

function my_ip() { # Get IP adresses
    local ipaddr link MY_LINKS MY_IP
    MY_LINKS=$(ip link show up | awk '/^[0-9]/ {print substr($2, 1, length($2)-1)}')
    for link in ${MY_LINKS}; do
        ipaddr=$(ip addr show dev ${link} | awk '/inet/ { print $2 } ' |
            sed -e s/addr://)
        if [ ! -z "${ipaddr}" ]; then
            ipaddr=$(echo ${ipaddr})
            MY_IP+=("${link}: ${ipaddr}")
        fi
    done
    if [ ${#MY_IP[@]} -eq 0 ]; then
        echo "Not connected"
    else
        for ipaddr in "${MY_IP[@]}"; do
            echo "${ipaddr}"
        done
    fi
}

function ii() { # Get current host related info.
    echo -e "\nYou are logged on ${BRed}$HOST"
    echo -e "\n${BRed}Additionnal information:$NC "
    uname -a
    echo -e "\n${BRed}Users logged on:$NC "
    w -hs |
        cut -d " " -f1 | sort | uniq
    echo -e "\n${BRed}Current date :$NC "
    date
    echo -e "\n${BRed}Machine stats :$NC "
    uptime
    echo -e "\n${BRed}Memory stats :$NC "
    free
    echo -e "\n${BRed}Diskspace :$NC "
    mydf / $HOME
    echo -e "\n${BRed}Local IP Address :$NC"
    my_ip
    echo -e "\n${BRed}Open connections :$NC "
    netstat -pan --inet
    echo
}

ii
