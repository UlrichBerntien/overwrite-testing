#!/usr/bin/env bash
set -o nounset

RAW='/tmp/RAWdata'
FS='/tmp/testfs'

if [[ $EUID -ne 0 ]]; then
    echo '[!] mount/unmount operations needs root privilege'
    exit
fi
./load_overwrite.sh

for mkfs in 'fat' 'exfat' 'vfat' 'ext2' 'ext4' 'ntfs'
do
    echo '[.] Create a small test drive'
    dd bs=1M count=4 if=/dev/zero "of=$RAW"
    echo "[.] Create $mkfs file system and mount"
    if [[ "$mkfs" =~ 'ext' ]]; then
        mkfs.$mkfs -q -O ^has_journal "$RAW"
        tune2fs -l "$RAW" | grep -iE '(features|journal)'
    elif [[ "$mkfs" == 'ntfs' ]]; then
        mkfs.$mkfs -q -F "$RAW"
    else
        mkfs.$mkfs "$RAW"
    fi
    mkdir "$FS"
    mount "$RAW" "$FS"

    echo '[.] Create 10 test files in the root directory'
    for i in $(seq 10)
    do
        echo 'content' > "$FS/FRGNTHI$i.txt"
    done
    ls -al $FS
    echo '[.] delete the 10 test files'
    rm $FS/FRGNTHI*.txt
    ls -al "$FS"

    echo '[.] run overwrite program with -meta:20 to overwrite 10 entries'
    # Differences between number in -meta and number of overwrites is
    # in the documentation.
    ./overwrite -meta:20 -path:$FS/

    echo '[.] unmount the test file system'
    umount "$FS"
    # extract strings in 16-bit little endian 
    strings -n 6 -e l $RAW > /tmp/strs

    echo '[.] check the metadata'
    if grep -qF RGNTHI $RAW; then
        echo '[X] file name rest found on test drive!'
        hexdump -C $RAW | grep -F RGNTHI
    elif grep -qF RGNTHI /tmp/strs; then
        echo '[X] file name rest (2 byte charset) found on test drive!'
        grep -F RGNTHI /tmp/strs
    else
        echo '[O] test case passed. No file name rest found'
    fi

    echo '[.] clean up'
    rmdir "$FS"
    rm "$RAW"
done
