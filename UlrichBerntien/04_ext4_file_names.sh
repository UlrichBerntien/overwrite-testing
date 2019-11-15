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
dd bs=1M count=1 if=/dev/zero "of=$RAW"
echo '[.] Create ext4 file system with out JOURNAL'
mkfs.ext4 -q "$RAW"
tune2fs -l "$RAW"
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

OV_PARAMTERS=("-meta:9000" "-data:all" "-path:$FS")
echo "[.] run overwrite with ${OV_PARAMTERS[@]}"
./overwrite "${OV_PARAMTERS[@]}"

echo '[.] unmount the test file system'
umount "$FS"

echo '[.] check the data on the test drive'
if grep -qF 'Moh5za' "$RAW"; then
    echo '[X] file name rest found on test drive!'
    hexdump -C -n 30000 "$RAW" 
else
    echo '[O] passed. No file name rest found'
fi

echo '[.] clean up'
rm -rf "$FS"
rm "$RAW"
