#!/bin/bash

# Variables
DIR=/tmp/test
DISK="$DIR"/disk
MNT="$DIR"/mnt

if [[ $EUID != 0 ]]; then
    echo "Run script as root, for mount / umount."
    exit
fi

./overwrite --version
echo ""

# Make test and mnt dirs
mkdir "$DIR" "$MNT"

# Create file system
dd bs=1M count=4 if=/dev/zero of="$DISK"
mkfs.ext2  "$DISK"
mount "$DISK" "$MNT"

echo ""
echo "# Disk type"
file "$DISK"
echo ""

# Create directories on mounted file system
mkdir "$MNT"/dir1 "$MNT"/dir2

# Create temporary files
for a in {1..5}
do
   echo Content"$a"-- > "$MNT"/dir1/File$a--
done
sync -f "$MNT"

# Delete temporary files
for a in {1..5}
do
   rm "$MNT"/dir1/File$a--
done
sync -f "$MNT"

echo ""
echo "# Before overwrite"
hexdump -vC "$DISK" | grep -i "\-\-"

# Overwrite
./overwrite -meta:5 -data:5 -path:"$MNT"/dir1

echo ""
echo "# After overwrite"
sync -f "$MNT"
hexdump -vC "$DISK" | grep -i "\-\-"
echo ""

# Unmount
sync -f "$MNT"
umount "$MNT"

# Clean
rm -r "$DIR"



