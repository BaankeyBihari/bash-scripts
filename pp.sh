#!/bin/bash

# Sourced from https://tldp.org/LDP/abs/html/sample-bashrc.html

function my_ps() {
    ps $@ -u $USER -o pid,%cpu,%mem,bsdtime,command
}
function pp() {
    my_ps f | awk '!/awk/ && $0~var' var=${1:-".*"}
}

pp
