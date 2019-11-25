#!/usr/bin/env bash
set -o nounset

# load and compile the overwrite program
echo '[.] load and compile overwrite'
./load_overwrite.sh > system.log 2>&1

# run all test cases
for test_script in ./??_*.sh
do
    echo "[.] run test script $test_script"
    if [[ -x "$test_script" ]]; then
        "./$test_script" > "${test_script/\.sh/.log}" 2>&1
        if [[ -a /tmp/testfs ]]; then
            echo '[!] /tmp/testfs exists, no clean script exit'
        fi
    fi
done
echo "[.] Summary of the test results"
grep -h "^\[.\] test case '.._" *.log
