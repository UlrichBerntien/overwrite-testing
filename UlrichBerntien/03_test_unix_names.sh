#!/usr/bin/env bash

RAW='/tmp/RAWdata'
FS='/tmp/testfs'

# Some directory to test
# (The character ̷ is not character /)
UNIX_DIR_NAMES=( simple colon: backslash\\ unicode̷ ' space' 'spaceend ' 'space in')

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
dd bs=1M count=2 if=/dev/zero "of=$RAW"
echo '[.] Create ext4 file system and mount'
mkfs.ext4 -q "$RAW"
mkdir "$FS"
mount "$RAW" "$FS"

overwrite=$(readlink -f overwrite)
cd "$FS"

echo '[.] Create test directories'
for name in "${UNIX_DIR_NAMES[@]}"
do
    mkdir "$name"
    touch "$name/___RaeQu3ho___"
    rm "$name/___RaeQu3ho___"
done
# Base directory not writeable
chmod -w "$FS"
ls -al "$FS"

echo '[.] run overwrite program'
for name in "${UNIX_DIR_NAMES[@]}"
do
    echo "[.] call: ./overwrite -meta:10 -path:$name"
    $overwrite -meta:10 "-path:$name"
done

cd

echo '[.] unmount the test file system'
sync -f "$FS"
umount "$FS"

echo '[.] check the data on the test drive'
if grep '_RaeQu3ho_' $RAW; then
    echo '[X] file name rest found on test drive!'
    #hexdump -C $RAW 
else
    echo '[O] passed. No file name rest found'
fi

echo '[.] clean up'
rmdir "$FS"
rm "$RAW"
