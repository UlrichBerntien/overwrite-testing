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
    dd bs=1M count=24 if=/dev/zero "of=$RAW"
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

    echo '[.] Create test files'
    for i in $(seq 9)
    do
    	testname="∼∼$i∼∼тестирање∼∼тестирање∼∼тестирање∼∼Moh5za∼∼"
    	echo "[.] test file name length: ${#testname}"
        echo "content" > "$FS/$testname"
    done
    ls -l "$FS"
    echo '[.] Delete all test files'
    rm $FS/*∼Moh5za∼∼
    ls -l "$FS"

    if [[ "$mkfs" == 'ext4' ]]; then
        # 9 files are deleted. So call overwrite program with -meta:900 to overwrite 900 entries.
        # with "-meta:5000" no file file name rests remain
        OV_PARAMTERS=("-meta:900" "-data:all" "-path:$FS")
    else
        # if "-meta:60" is used then file name rests remain
        OV_PARAMTERS=("-meta:70" "-data:all" "-path:$FS")
    fi
    echo '[.] run overwrite' "${OV_PARAMTERS[@]}"
    ./overwrite "${OV_PARAMTERS[@]}"

    echo '[.] unmount the test file system'
    umount "$FS"
    # extract strings in 16-bit little endian 
    strings -n 6 -e l $RAW > /tmp/strs

    echo '[.] check the metadata'
    if grep -qF Moh5za $RAW; then
        echo '[X] file name rest found on test drive!'
        hexdump -C $RAW | grep -F Moh5za
    elif grep -qF Moh5za /tmp/strs; then
        echo '[X] file name rest (2 byte charset) found on test drive!'
        grep -F Moh5za /tmp/strs
    else
        echo '[O] test case passed. No file name rest found'
    fi

    echo '[.] clean up'
    rm -rf "$FS"
    rm "$RAW"
done
