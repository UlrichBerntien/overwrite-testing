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

# Make test and mnt dirs
mkdir "$DIR" "$MNT"

# Create file system
dd bs=1M count=4 if=/dev/zero of="$DISK"
mdconfig -u md9 "$DISK"
newfs  /dev/md9   > /dev/null 2>&1
mount /dev/md9 "$MNT"

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
hexdump -vC /dev/md9 | grep -i "\-\-"

# Overwrite
./overwrite -meta:4 -path:"$MNT"/dir1

echo ""
echo "# After overwrite"
sync -f "$MNT"
hexdump -vC /dev/md9 | grep -i "\-\-"
echo ""

# Unmount
sync -f "$MNT"
umount "$MNT"
mdconfig -du md9

# Clean
rm -r "$DIR"



