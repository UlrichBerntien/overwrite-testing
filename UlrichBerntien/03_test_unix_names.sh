#!/usr/bin/env bash
set -o nounset

test_volume='/tmp/test_volumedata'
test_volume_root='/tmp/testfs'

test_name_part='RaeQu3ho'

# Some directory to test
UNIX_DIR_test_names=('simple' 'colon:' 'backslash\\' 'unicode̷ ' 'space' 'spaceend ' 'space in')

if [[ $EUID -ne 0 ]]; then
    echo '[!] mount/unmount operations needs root privilege'
    exit
fi
./load_overwrite.sh

for test_filesystem in 'ext2' 'ext3' 'ext4' 'f2fs' 'ntfs' 'xfs'
do 
    if ! hash mkfs.$test_filesystem; then
        continue
    fi
    echo '[.] create empty test volume'
    dd bs=1G count=1 if=/dev/zero "of=$test_volume"
    echo "[.] create $test_filesystem file system and mount"
    if [[ "$test_filesystem" == 'ntfs' ]]; then
        # NTFS file system needs force switch to create inside a file
        mkfs.$test_filesystem -q -F "$test_volume"
    else
        mkfs.$test_filesystem "$test_volume"
    fi
    mkdir "$test_volume_root"
    mount "$test_volume" "$test_volume_root"

    echo '[.] create test directories'
    for name in "${UNIX_DIR_test_names[@]}"
    do
        mkdir "$test_volume_root/$name"
        touch "$test_volume_root/$name/___${test_name_part}__1__"
        touch "$test_volume_root/$name/___${test_name_part}__2__"
        rm "$test_volume_root/$name/___${test_name_part}__1__"
        rm "$test_volume_root/$name/___${test_name_part}__2__"
    done
    # Set base directory not writeable
    chmod -w "$test_volume_root"
    ls -RCa "$test_volume_root"

    echo '[.] run overwrite program'
    for name in "${UNIX_DIR_test_names[@]}"
    do
        # use absolute path name because overwrite does not handle path names
        # starting with a space. User meta data 20 to overwrite the 2 removed files.
        OV_ARGUMENTS=("-meta:20" "-path:$test_volume_root/$name")
        echo '[.] call overwrite' "${OV_ARGUMENTS[@]}"
        ./overwrite "${OV_ARGUMENTS[@]}"
    done

    echo '[.] unmount the test file system'
    umount "$test_volume_root"
    # extract strings in 16-bit little endian 
    strings -n ${#test_name_part} -e l $test_volume > /tmp/strs

    echo '[.] check the metadata'
    if grep -qF "$test_name_part" $test_volume; then
        echo '[E] file name rest found on test volume'
        echo "[ ] test case '$(basename $0)' with file system '$test_filesystem' fail"
        hexdump -C $test_volume | grep -F "$test_name_part"
    elif grep -qF "$test_name_part" /tmp/strs; then
        echo '[E] file name rest (2 byte charset) found on test volume'
        echo "[ ] test case '$(basename $0)' with file system '$test_filesystem' fail"
        grep -F "$test_name_part" /tmp/strs
    else
        echo '[.] No file name rest found'
        echo "[X] test case '$(basename $0)' with file system '$test_filesystem' passed"
    fi

    echo '[.] clean up'
    rmdir "$test_volume_root"
    rm "$test_volume"
done
