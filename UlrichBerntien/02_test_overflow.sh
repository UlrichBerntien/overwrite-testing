#!/usr/bin/env bash
set -o nounset

./load_overwrite.sh

echo '[.] Generate very long argument'
# current PATH_MAX is 4096 in Linux.
FLONG="x"
for _ in $(seq 13); do
    FLONG=$FLONG$FLONG
done

echo "[.] path argument lenth is ${#FLONG}"
echo '[.] run overwrite program with very long argument'
# First run to see the output
./overwrite -meta:1 -path:$FLONG 2>&1
# Second run to analyse the output
MSG=$(./overwrite -meta:1 -path:$FLONG 2>&1)
if [[ "$MSG" =~ 'too long' ]]; then
    echo '[.] error message found'
    echo "[X] test case '$(basename $0)' passed"

else
    echo '[E] missing error message'
    echo "[ ] test case '$(basename $0)' fail"
fi
