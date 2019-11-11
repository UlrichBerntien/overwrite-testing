#!/bin/bash

# Variables
DIR=/tmp/test
DISK="$DIR"/disk
MNT="$DIR"/mnt
PREFIX=_

if [[ $EUID != 0 ]]; then
    echo "Run script as root"
    exit
fi

# Make test and mnt dirs
mkdir "$DIR" "$MNT"

# Create file system
dd bs=1M count=4 if=/dev/zero of="$DISK"
mkfs.fat  "$DISK"
mount "$DISK" "$MNT"

# Create directories on mounted file system
mkdir "$MNT"/dir1 "$MNT"/dir2

# Create temporary files
for a in {1..5}
do
   echo content"$a" > "$MNT"/dir1/"$PREFIX"File-$a.txt
done
sync -f "$MNT"

# Delete temporary files
for a in {1..5}
do
   rm "$MNT"/dir1/"$PREFIX"File-$a.txt
done
sync -f "$MNT"

echo ""
echo "# Before overwrite"
sync -f "$MNT"
hexdump -vC "$DISK" | grep -i "l\|x"

# Overwrite
overwrite -meta:2 -path:"$MNT"/dir1

echo ""
echo "# After overwrite"
sync -f "$MNT"
hexdump -vC "$DISK" | grep -i "l\|x"
echo ""

# Unmount
sync -f "$MNT"
umount "$MNT"

# Clean
rm -r "$DIR"


