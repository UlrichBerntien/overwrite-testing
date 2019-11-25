# Overwrite Experiments

Experiments with the overwrite program.

## The overwrite program

The overwrite program is an open source program from [Ivo Gjorgjievski](https://github.com/ivoprogram).

The overwrite program is published on the [web page](https://ivoprogram.github.io/content/en/index.html).
The program description is published in the [web page](https://ivoprogram.github.io/content/en/index.html).
> Overwrite is a program that overwrites empty space on disk, metadata and data.

Overwrite is a written in standard C. The source code is published on a [github repository](https://github.com/ivoprogram/overwrite)

## Tests

The files ".sh" are bash shell scripts.
The files ".log" are output of the script files.


**00_test_same_directory**

The test script create 10 test files in the root directory and a 10 test files in a directory 'SUB'.
The test files are deleted.
The overwrite program is called to overwrite the meta data in the root directory and
in the directory 'SUB'. (The overwrite programm is called twice.)

The test is executed with different file systems.

Test results:

[X] test case '00_test_same_directory.sh' with file system 'exfat' passed
[X] test case '00_test_same_directory.sh' with file system 'ext2' passed
[ ] test case '00_test_same_directory.sh' with file system 'ext3' fail
[ ] test case '00_test_same_directory.sh' with file system 'ext4' fail
[X] test case '00_test_same_directory.sh' with file system 'f2fs' passed
[X] test case '00_test_same_directory.sh' with file system 'fat' passed
[X] test case '00_test_same_directory.sh' with file system 'ntfs' passed
[ ] test case '00_test_same_directory.sh' with file system 'xfs' fail


**01_test_short_names**

The test script creates 2 test files with short names and deletes the 2nd test file.
Test files are created in the root directory and in a directoty SUB.
The overwrite programm should overwrite the meta data of the 1st test file.
The overwrite programm is called for both directories.

Test results:

[X] test case '01_test_short_names.sh' with file system 'exfat' passed
[X] test case '01_test_short_names.sh' with file system 'ext2' passed
[ ] test case '01_test_short_names.sh' with file system 'ext3' fail
[ ] test case '01_test_short_names.sh' with file system 'ext4' fail
[X] test case '01_test_short_names.sh' with file system 'f2fs' passed
[X] test case '01_test_short_names.sh' with file system 'fat' passed
[X] test case '01_test_short_names.sh' with file system 'ntfs' passed
[X] test case '01_test_short_names.sh' with file system 'xfs' passed


**02_test_overflow**

The test script calls the overwrite program with a too long path name.
The overwrite program has to respond with an error message.

Test results:

[X] test case '02_test_overflow.sh' passed


**03_test_unix_names**

Overwrite version 1.4.1 2019-11-03 handles path names with ':' and
'\' at the end not correct. A workaround is possible: call overwrite
with '/' at the end of the path name.

Newer versions handles path names with ':' and '/' at the end.

Overwrite passes the test if absolute path names are used to prevent
a path name starting with a space.

Test results:

[X] test case '03_test_unix_names.sh' with file system 'ext2' passed
[ ] test case '03_test_unix_names.sh' with file system 'ext3' fail
[ ] test case '03_test_unix_names.sh' with file system 'ext4' fail
[X] test case '03_test_unix_names.sh' with file system 'f2fs' passed
[X] test case '03_test_unix_names.sh' with file system 'ntfs' passed
[ ] test case '03_test_unix_names.sh' with file system 'xfs' fail


**04_ext4_file_names**

The test uses an ext4 file system with out journal on a small volume.
The test creates 9 file, removes the files and calls overwrite.

Test results:

[X] test case '04_ext4_file_names.sh' with file system 'exfat' passed
[X] test case '04_ext4_file_names.sh' with file system 'ext2' passed
[ ] test case '04_ext4_file_names.sh' with file system 'ext3' fail
[ ] test case '04_ext4_file_names.sh' with file system 'ext4' fail
[ ] test case '04_ext4_file_names.sh' with file system 'f2fs' fail
[X] test case '04_ext4_file_names.sh' with file system 'fat' passed
[X] test case '04_ext4_file_names.sh' with file system 'ntfs' passed
[X] test case '04_ext4_file_names.sh' with file system 'xfs' passed


**05_random_names**

In this test case a directory is created. In the directory 140 files are created.
All file names are 10 character long.

From this 140 files 8 files are deleted. The names of the 8 files were prepared
with a string 'MA4RK' inside the 10 character long file name.

Test summary of Overwrite Version 1.6.1 2019-11-21:

[X] test case '05_random_names.sh' with file system 'exfat' passed
[X] test case '05_random_names.sh' with file system 'ext2' passed
[ ] test case '05_random_names.sh' with file system 'ext3' fail
[ ] test case '05_random_names.sh' with file system 'ext4' fail
[X] test case '05_random_names.sh' with file system 'f2fs' passed
[X] test case '05_random_names.sh' with file system 'fat' passed
[ ] test case '05_random_names.sh' with file system 'ntfs' fail
[ ] test case '05_random_names.sh' with file system 'xfs' fail


## Support files

**load_overwrite.sh**

Load overwrite source from Github and compile it.

**run_all.sh**

Load, compile overwrite program and run all test cases.
