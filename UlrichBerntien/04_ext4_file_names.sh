#!/usr/bin/env bash

RAW='/tmp/RAWdata'
FS='/tmp/testfs'

if [[ $EUID != 0 ]]; then
    echo "[!] mount/unmount operations needs root privilege"
    exit
fi
if [[ ! -x ./overwrite ]]; then
    ./load_overwrite.sh
    echo '[.] overwrite version'
    ./overwrite --version
fi

echo '[.] Create a small test drive'
dd bs=1M count=1 if=/dev/zero "of=$RAW"
echo '[.] Create ext4 file system and mount'
mkfs.ext4 -j -q "$RAW"
mkdir "$FS"
mount "$RAW" "$FS"

echo '[.] Create test files'
for i in $(seq 5)
do
    echo "content" > "$FS/Testfiles_${i}_______________________________________________________________________________________________________________________________________________________________________________________________________RaeQu3ho__"
done
ls -l "$FS"
echo '[.] Delete all test files'
rm $FS/Testfiles_*
ls -l "$FS"

echo '[.] run overwrite to overwrite 1000 dir entries and all data'
./overwrite -dirs:1000 -data:all "-path:$FS"

echo '[.] unmount the test file system'
sync -f "$FS"
umount "$FS"

echo '[.] check the data on the test drive'
if grep 'RaeQu3ho' "$RAW"; then
    echo '[X] file name rest found on test drive!'
    hexdump -C "$RAW" 
else
    echo '[O] passed. No file name rest found'
fi

echo '[.] clean up'
rm -rf "$FS"
rm "$RAW"
