<!-- SPDX-License-Identifier: GPL-3.0-or-later -->
### Simple Commands

A simple command is a sequence of optional variable assignments followed by blank-separated words and redirections, terminated by a control operator. The first word specifies the command to be executed and is passed as argument zero. The remaining words are passed as arguments to the invoked command.

The return value of a simple command is its exit status, or 128+n if the command is terminated by signal n.
