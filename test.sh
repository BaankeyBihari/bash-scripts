#!/bin/bash

f () {
    whoami
    hostname
    pwd
}

# screen -dm -S test bash -c f
# ps afx
k=$(f)
echo $k
test=ro
(sleep 5 && echo $test)&
sleep 1
test=so
(sleep 5 && echo $test)&
# echo $$
echo ";;"
pgrep -P $$
pgrep -P $$ | wc -l
wait

pgrep -P $$ | wc -l
