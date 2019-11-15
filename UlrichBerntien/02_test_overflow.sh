#!/usr/bin/env bash

if [[ ! -x ./overwrite ]]; then
    ./load_overwrite.sh
fi
echo '[.] overwrite version'
./overwrite --version

echo '[.] Generate very long argument'
# current PATH_MAX is 4096 in Linux.
FLONG="x"
for i in $(seq 10); do
    FLONG=$FLONG$FLONG
done

echo "[.] path argument lenth is ${#FLONG}"
echo '[.] run overwrite program with very long argument'
# First run to see the output
./overwrite -meta:1 -path:$FLONG 2>&1
# Second run to analyse the output
MSG=$(./overwrite -meta:1 -path:$FLONG 2>&1)
if [[ "$MSG" =~ 'Error' ]]; then
    echo '[0] error message found, test passed'
else
    echo '[X] missing error message'
fi
