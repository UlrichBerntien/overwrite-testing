
Overwrite Version 1.5.1 2019-11-14
- Fixed issue with metadata remanence on FAT, EXT.
- Metadata and data is written in destination dir not in subdir.
- Using small files instead of dirs for metadata and data cleaning.
- This changes were required to support different file systems and operating systems.


This tests demonstrate how the Overwrite program clean metadata on file systems 
FAT, EXT2, EXT3, EXT4

On Ext3 and Ext4 to clean metadata the journal has to be disabled clean and enabled as demonstrated in tests.
The overwrite has to be done in the same directory of deleted files.
Also long file names are tested and cleaned.
This version pass tests that failed in previous verson.
On Fat32 on Windows metadata can be cleaned in any folder.
