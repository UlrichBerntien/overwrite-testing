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

    echo '[.] Create 2 short name test files in the root directory'
    echo 'content' > $FS/1FIRST1.TXT
    echo 'content' > $FS/SECOND.TXT
    ls -al "$FS"
    echo '[.] delete the first file only, NOT the second file'
    rm $FS/1FIRST1.TXT
    ls -al "$FS"

    echo '[.] run overwrite program'
    ./overwrite -meta:10 -path:$FS/

    echo '[.] unmount the test file system'
    umount "$FS"
    # extract strings in 16-bit little endian 
    strings -n 5 -e l $RAW > /tmp/strs

    echo '[.] check the metadata'
    if grep -qF FIRST $RAW; then
        echo '[X] file name rest found on test drive!'
        hexdump -C $RAW | grep -F FIRST
    elif grep -qF FIRST /tmp/strs; then
        echo '[X] file name rest (2 byte charset) found on test drive!'
        grep -F FIRST /tmp/strs
    else
        echo '[O] test case passed. No file name rest found'
    fi
    
    echo '[.] clean up'
    rm -rf "$FS"
    rm "$RAW"
done
