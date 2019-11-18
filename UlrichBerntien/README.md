# Overwrite Experiments

Experiments with the overwrite program.

## The overwrite program

The overwrite program is an open source program from [Ivo Gjorgjievski](https://github.com/ivoprogram).

The overwrite program is published on the [web page](https://ivoprogram.github.io/content/en/index.html).
The program description is publiched in the [web page](https://ivoprogram.github.io/content/en/index.html).
> Overwrite is a program that overwrites empty space on disk, metadata and data.

Overwrite is a written in standard C. The source code is published on a [github repository](https://github.com/ivoprogram/overwrite)

## Tests

The files ".sh" are bash shell scripts.
The files ".log" are output of the script files.

**00_test_same_directory**

Overwrite version 1.0 2019-10-04 creates the file in a subdirectory.
So only one directory entry in the given path was overwritten.

Newer versins passes the test. All directory entries are overwritten.

Overwrite version 1.5.2 passes this test case.

**01_test_short_names**

The test script creates 2 test files with short names and deletes the 2nd test file.
The overwrite call should overwrite the metadata of the 1st test file.

Overwrite ver1.2-2019-10-28 create files with long names.
So the directory entry with short name inside the directory
list was not overwritten.

Overwrite version 1.3.1 2019-10-30 uses short directory names to
overwrite entries. This works well.

The Test failed with overwrite version 1.5 2019-11-09 and 1.5.1 2019-11-14.
The first directory entry is not overwritten.

Overwrite version 1.5.2 passes this test case.

**02_test_overflow**

Overwrite version 1.3.1 2019-10-30 uses strcpy and strcat without
checking the string length. So a very long path name argument
causes a buffer overflow.

Overwrite version 1.4.1 2019-11-03 handles also very long path names.
An error message reports invalid names given as parameter.

Overwrite version 1.5.1 2019-11-14 raises a memory segmentation fault.

Overwrite version 1.5.2 passes this test case.

**03_test_unix_names**

Overwrite version 1.4.1 2019-11-03 handles path names with ':' and
'\' at the end not correct. A workaround is possible: call overwrite
with '/' at the end of the path name.

Newer versions handels path names with ':' and '/' at the end.

Overwrite passes the test if absolute path names are used to prevent
a path name starting with a space.

Overwrite version 1.5.2 passes this test case.

**04_ext4_file_names**

The test uses an ext4 file system with out journal on a small volume.
The test creates 9 file, removes the files and calls overwrite.

The ext4 file system with journal is not tested.
See the overwrite documentation to handle ext with journal.

The overwrite version 1.5.1 2019-11-14 does not remove all parts of the
file names from the volume.

Overwrite version 1.5.2 passes this test case.
On the ext4 file system without journal overwrite must call with -meta:5000
to overwrite the 9 test file names. (A call with parameter -meta:4000 is not
sufficient to overwrite all test file names.)

## Support files

**load_overwrite.sh**

Load overwrite source from Github and compile it.

**run_all.sh**

Load, compile overwrite program and run all test cases.
