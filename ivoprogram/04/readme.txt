
Overwrite Version 1.5.2 2019-11-16
- Fixed issue with metadata remanence on FAT, EXT.
- Also upper case, and long file names are cleaned.

This tests demonstrate how the Overwrite Program clean metadata on file systems 
FAT, EXT2, EXT3, EXT4, UFS

On Ext3 and Ext4 to clean metadata the journal has to be disabled clean and enabled as demonstrated in tests.
The overwrite has to be done in the same directory of deleted files.

