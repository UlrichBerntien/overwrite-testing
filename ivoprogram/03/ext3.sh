#!/bin/bash

# Variables
DIR=/tmp/test
DISK="$DIR"/disk
MNT="$DIR"/mnt
PREFIX=#

if [[ $EUID != 0 ]]; then
    echo "Run script as root, for mount / umount."
    exit
fi

# Make test and mnt dirs
mkdir "$DIR" "$MNT"

# Create file system
dd bs=1M count=4 if=/dev/zero of="$DISK"
mkfs.ext3  "$DISK"

# Disable journal
# dumpe2fs "$DISK" | grep 'Filesystem features'
tune2fs -O ^has_journal "$DISK"
e2fsck -f  "$DISK"

mount "$DISK" "$MNT"

./overwrite --version

# Create directories on mounted file system
mkdir "$MNT"/dir1 "$MNT"/dir2

# Create temporary files
for a in {1..5}
do
   echo "$PREFIX"Content"$a"# > "$MNT"/dir1/"$PREFIX"File$a#
done
sync -f "$MNT"

# Delete temporary files
for a in {1..5}
do
   rm "$MNT"/dir1/"$PREFIX"File$a#
done
sync -f "$MNT"

echo ""
echo "# Disk type"
file "$DISK"

echo ""
echo "# Before overwrite"
hexdump -vC "$DISK" | grep -i "#"

# Overwrite
./overwrite -meta:5 -data:all -path:"$MNT"/dir1

echo ""
echo "# After overwrite"
sync -f "$MNT"
hexdump -vC "$DISK" | grep -i "#"
echo ""

# Unmount
sync -f "$MNT"
umount "$MNT"

# Enable journal
tune2fs -O has_journal "$DISK"
e2fsck -f  "$DISK"
# dumpe2fs "$DISK" | grep 'Filesystem features'

# Clean
rm -r "$DIR"



