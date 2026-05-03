<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->
## 8.2 File test operators

Single-operand tests on files. The full table:

- `-e file` — exists.
- `-f file` — regular file.
- `-d file` — directory.
- `-L file`, `-h file` — symbolic link.
- `-b file` — block device.
- `-c file` — character device.
- `-p file` — named pipe (FIFO).
- `-S file` — socket.
- `-r file` — readable by EUID.
- `-w file` — writable by EUID.
- `-x file` — executable by EUID.
- `-s file` — non-zero size.
- `-N file` — modified since last read.
- `-O file` — owned by EUID.
- `-G file` — group owned by EGID.
- `-k file` — sticky bit.
- `-u file` — SUID bit.
- `-g file` — SGID bit.
- `-t fd` — fd refers to a terminal.

#fin
