#!/usr/bin/env bash

RAW='/tmp/RAWdata'
FS='/tmp/testfs'

# Some directory to test
UNIX_DIR_NAMES=('simple' 'colon:' 'backslash\\' 'unicode̷ ' 'space' 'spaceend ' 'space in')

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
dd bs=512k count=1 if=/dev/zero "of=$RAW"
echo '[.] Create ext4 file system and mount'
mkfs.ext4 -q "$RAW"
mkdir "$FS"
mount "$RAW" "$FS"

echo '[.] Create test directories'
for name in "${UNIX_DIR_NAMES[@]}"
do
    mkdir "$FS/$name"
    touch "$FS/$name/___RaeQu3ho___"
    rm "$FS/$name/___RaeQu3ho___"
done
# Set base directory not writeable
chmod -w "$FS"
ls -al "$FS"

echo '[.] run overwrite program'
for name in "${UNIX_DIR_NAMES[@]}"
do
    # use absolute path name because overwrite does not handle path names
    # starting with a space.
    OV_ARGUMENTS=("-meta:10" "-path:$FS/$name")
    echo "[.] call: ${OV_ARGUMENTS[@]}"
    ./overwrite "${OV_ARGUMENTS[@]}"
done

echo '[.] unmount the test file system'
sync -f "$FS"
umount "$FS"

echo '[.] check the data on the test drive'
if grep -qF 'RaeQu3ho' "$RAW"; then
    echo '[X] file name rest found on test drive!'
    hexdump -C "$RAW" 
else
    echo '[O] passed. No file name rest found'
fi

echo '[.] clean up'
rmdir "$FS"
rm "$RAW"
