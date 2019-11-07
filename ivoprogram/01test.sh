#!/bin/sh

# Version 1.4.2 2019-11-07 overwrite.c
# Test for special characters in Unix directory path
# As reported in https://github.com/ivoprogram/overwrite-testing/issues/2


DIR='/tmp/01test'

echo
uname -a

echo
echo "Creating directories"
mkdir $DIR/
mkdir $DIR/dir1\\
mkdir $DIR/dir2\"
mkdir $DIR/dir3:

echo "Overwriting in directories"
overwrite -test -dirs:1 -data:1mb -path:$DIR/dir1\\
overwrite -test -dirs:1 -data:1mb -path:$DIR/dir2\"
overwrite -test -dirs:1 -data:1mb -path:$DIR/dir3:

echo
echo "Result in $DIR/dir1\\"
ls -lh $DIR/dir1\\

echo
echo "Result in $DIR/dir2\" "
ls -lh $DIR/dir2\"

echo
echo "Result in $DIR/dir3:"
ls -lh $DIR/dir3:

echo
echo "Cleaning"
rm -r $DIR

echo "Done."
