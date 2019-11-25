#!/usr/bin/env bash
set -o nounset

test_volume='/tmp/test_volumedata'
test_volume_root='/tmp/testfs'

# List of generated file names with pattern prepared in 8 names
test_names=(
RZP2Z9RZKC TyzCRI2fhw GU6jMIsHDs 0PqZPeM7nO kU5tkqjdyw M5ZWQ3OEIg 1FrKaGmkM4
vhKw01jQ4S GsFtI7Qetl 9Kip7Z7BY7 4JyDf3TlXp AeODb2XVjC lE9ExUTPXg SsOWqpyN5p
dwwjTyR4ka glZWG2uOct wWW36LOmFk 0vvDwdWx9N 74msnI0ZAt IJb7DIm96a aB5xRQJ0xo
OFIPWqh438 40AUHIHWtv 1tJKlTkly0 A72q8VME1M M4vxzPYnTm 0eyVuHnebJ 9JKtURjBm1
MRNIE6TtEE SUfrot5MnF p8c4LBRc6D pvyaIxqg2V hTeoALOr9w IeI6sNkKP8 mc76QjKZ7X
Uw1d2QVhLb En3rgYOAYr 6nJhAUxcQ5 MjBhMA4RKs lPkg9PorXc 8tSqzzu6li LukM9a3auf
I866MA4RKA M3OZjU6HZm 58JNLBoHv6 gVixG6e6jn j2tXwJU19e x53TBQk6Rf GqZtMA4RKi
yYykZ54tUW Mb4pV2CyAL cCsNL6JhdB DXRJ36wbLM EhYpXMA4RK pcRRtx9Bua sL9lmrKxgN
IMwKxELn8R Hci0j3W79R dQj57Z0i4F hkb3D2B3K8 Ha1OopXUuG KgAXv3dvdQ gD9Z8hIRcf
7j9PLugpMH 95nWsDoqiB 47oL0MA4RK TJ1eCqdLNI TwxNw7SSyp ITHMA4RK0u DAi3BWcmiL
66uZXLwaI1 s5EMuuXqMV vlEznHk879 VzYSNmSK3k RDFPLjo0Rm 0jrki44dXe uokVK5KT0C
7GegdKJxKx VQBIy0f9tU ZoC1CnJ1u9 eCsViw6QBF a9kzdOUOU5 so68lBokzg 3yFlimDRQp
wRW08PEt27 UnH48DqsmM L7pmmakbRZ xNpoYh41Ek 9k4ipu2tZS 205nxSzwQq 24PyvCG5VS
yucUYj7V0Z KAHKy8ZRnZ VpML5Qtyw6 97HrO0ly4Z bk7aO0c0Fb 0BhPNq12Y1 dxz8Av0J7j
aS43k6KnOk qG97Tku5AK ohth2yi1Bu eeGh6eijoh eeP6ahchei aa3ohyaeWu eiVae0jahd
ierah3fohD o331MA4RKo OhQu6shaez HieZaihae1 ooch6mooYe raeTh1ahse ieth1kaeF4
eeW3ein1os eos0OhRiez eip9eez8Re aeBee5begu ahz9Othat8 looc2ohN4r jieZa7oghu
TeiKooMei8 DaviuQu5ei aeChuph9ei ahQ2MA4RK9 rooG5Quaec chaif3eiCh shohquieW0
civ1Uiphee Aid5ooGh1z ceZovie2bu ogai6ku5eK li8eiXaeve Eedaz3teo0 FaN3too5su
eev1quoo1O Phae1xiesa wozuZ8heiN sealeiRi2a tahpish4Re eph3Phin4i eipoV7Bo0W)

# The part in 8 names of the test_names
test_name_part='MA4RK'

if [[ $EUID -ne 0 ]]; then
    echo '[!] mount/unmount operations needs root privilege'
    exit
fi
./load_overwrite.sh

for test_filesystem in 'exfat' 'ext2' 'ext3' 'ext4' 'f2fs' 'fat' 'ntfs' 'xfs'
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

    echo '[.] create test directory'
    mkdir "$test_volume_root/DIR1/"
    echo '[.] create test files'
    for i in "${test_names[@]}"
    do
        touch "$test_volume_root/DIR1/$i"
    done
    ls -C -w 100 "$test_volume_root/DIR1"
    echo '[.] Delete some test files'
    rm $test_volume_root/DIR1/*${test_name_part}*
    echo '[.] directory content after delete'
    ls -C -w 100 "$test_volume_root/DIR1"

    # 8 files are deleted. So call overwrite program with -meta:80 to overwrite 80 entries.
    OV_PARAMTERS=("-meta:80" "-path:$test_volume_root/DIR1")
    echo '[.] run overwrite' "${OV_PARAMTERS[@]}"
    ./overwrite "${OV_PARAMTERS[@]}"

    echo '[.] unmount the test file system'
    umount "$test_volume_root"
    # extract strings in 16-bit little endian
    strings -n ${#test_name_part} -e l $test_volume > /tmp/strs

    echo '[.] check the metadata'
    if grep -qF "$test_name_part" "$test_volume"; then
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
