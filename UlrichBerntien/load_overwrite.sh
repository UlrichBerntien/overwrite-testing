#!/usr/bin/env bash
set -o nounset
set -o errexit

if [[ ! -x ./overwrite ]]; then
    echo '[.] Get overwrite program'
    curl -s -o overwrite.c https://raw.githubusercontent.com/ivoprogram/overwrite/master/c/overwrite.c
    echo '[.] Head of the source file'
    head overwrite.c
    echo '[.] Compile overwrite program'
    gcc overwrite.c -o overwrite
    echo '[.] SHA-1 hashes for version compare'
    sha1sum overwrite*
    echo '[.] used test system'
    uname -a
    if [[ -r /etc/os-release ]]; then
        grep PRETTY /etc/os-release
    fi
fi

echo -n '[.] overwrite version'
./overwrite --version
