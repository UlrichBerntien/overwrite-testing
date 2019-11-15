#!/usr/bin/env bash

RAW='/tmp/RAWdata'
FS='/tmp/testfs'

if [[ $EUID != 0 ]]; then
    echo "[!] mount/unmount operations needs root privilege"
    exit
fi
if [[ ! -x ./overwrite ]]; then
    ./load_overwrite.sh
fi
echo '[.] overwrite version'
./overwrite --version

echo '[.] Create a small test drive'
dd bs=1k count=256 if=/dev/zero "of=$RAW"
echo '[.] Create FAT file system and mount'
mkfs.fat "$RAW"
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
./overwrite -block:512 -meta:10 -data:10mb -path:$FS/

echo '[.] unmount the test file system'
umount "$FS"

echo '[.] check the metadata, read the directory block'
if grep -qF 'FIRST' $RAW; then
    echo '[X] file name rest of FIRST file found on test drive!'
    hexdump -C $RAW 
else
    echo '[O] passed. No file name rest found'
fi
echo '[.] clean up'
rm -rf "$FS"
rm "$RAW"
