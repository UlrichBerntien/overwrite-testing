
This tests demonstrate how the Overwrite program clean metadata on file systems FAT, EXT2, EXT3, EXT4

On Ext3 and Ext4 to clean metadata the journal has to be disabled clean and enabled as demonstrated in tests.
Also long file names are tested and cleaned.
The overwrite has to be done in the same directory of deleted files.


------------------------------
Tests in subfolder from UlrichBerntien
https://github.com/ivoprogram/overwrite-testing/tree/master/UlrichBerntien


This tests fail because the tests are not good, and not the overwrite program.

I have created test scripts with different file systems that demonstrate that the overwrite program clean also metadata, demonstration on FAT, EXT2, EXT3, EXT3 also with long file names.

01_test_short_names.sh
Fail because at line 28 only one file is deleted and not also the second file, overwrite program does not overwrite existing files, only deleted.

02_test_overflow.sh
Fail because the script pass more than 1000 chars in path as one file name not as path with separators,
Linux has limits file name 255, path 4096.

03_test_unix_names
I have answered to this in issues #2. 
I don't consider this as issue, in a case of space at first character in path the user can use another directory, anyway this is not common case.
The overwrite program is intended for common use 99% of cases, it not cover all the possible cases, otherwise the user can search other solutions than overwrite program.

04_ext4_file_names.log:
5 test files with long names and "overwrite -dirs:1000 -data:all" does not overwrite all parts of the file names.

This test fail because ext3 and ext4 have journal, so the script find remainig data in journal not in file system metadata structure.
The solution is to disable journaling overwrite and enable journaling, i have created test scripts that demonstrate this.




