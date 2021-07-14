# Overview

Archive a source directory in a destination directory. However, only copy 'different' files from the source.

## Usage

```bash
./backup.sh <source> <dest>
```

This creates destination dirs that are time stamped. Each directory contains 'all' source files but it does not actually copy the file again, saving space. Only different files are copied. The rest of the files are hard links to the same inode.
