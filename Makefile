# Makefile - SEED-style for Buffer Overflow Set-UID lab
# Produces stack-L1 .. stack-L4 and debug versions, plus call-shellcode test binaries.

CC = gcc
# Flags used for 32-bit builds (Level 1 & 2)
CFLAGS32 = -m32 -z execstack -fno-stack-protector
CFLAGS32_DBG = $(CFLAGS32) -g

# Flags used for 64-bit builds (Level 3 & 4)
CFLAGS64 = -z execstack -fno-stack-protector
CFLAGS64_DBG = $(CFLAGS64) -g

# Buffer-size variables per the lab (L1..L4 can be overridden on make command line)
L1 ?= 100
L2 ?= 140
L3 ?= 120
L4 ?= 10

# Derived BUF_SIZE for each level
BUF1 = $(L1)
BUF2 = $(L2)
BUF3 = $(L3)
BUF4 = $(L4)

# default target
all: stack-L1 stack-L2 stack-L3 stack-L4 stack-L1-dbg stack-L2-dbg stack-L3-dbg stack-L4-dbg a32.out a64.out

# ---------- Level 1 (32-bit) ----------
stack-L1: stack.c
	$(CC) -DBUF_SIZE=$(BUF1) $(CFLAGS32) -o $@ stack.c

stack-L1-dbg: stack.c
	$(CC) -DBUF_SIZE=$(BUF1) $(CFLAGS32_DBG) -o $@ stack.c

# ---------- Level 2 (32-bit, unknown buffer size attack) ----------
stack-L2: stack.c
	$(CC) -DBUF_SIZE=$(BUF2) $(CFLAGS32) -o $@ stack.c

stack-L2-dbg: stack.c
	$(CC) -DBUF_SIZE=$(BUF2) $(CFLAGS32_DBG) -o $@ stack.c

# ---------- Level 3 (64-bit) ----------
stack-L3: stack.c
	$(CC) -DBUF_SIZE=$(BUF3) $(CFLAGS64) -o $@ stack.c

stack-L3-dbg: stack.c
	$(CC) -DBUF_SIZE=$(BUF3) $(CFLAGS64_DBG) -o $@ stack.c

# ---------- Level 4 (64-bit, very small buffer) ----------
stack-L4: stack.c
	$(CC) -DBUF_SIZE=$(BUF4) $(CFLAGS64) -o $@ stack.c

stack-L4-dbg: stack.c
	$(CC) -DBUF_SIZE=$(BUF4) $(CFLAGS64_DBG) -o $@ stack.c

# ---------- Shellcode test binaries (call_shellcode) ----------
call-shellcode.c:
	@printf '/* auto-generated call-shellcode.c */\n#include <stdlib.h>\n#include <stdio.h>\n#include <string.h>\n\nconst char shellcode[] = \"\\x48\\x31\\xd2\\x52\\x48\\xb8\\x2f\\x62\\x69\\x6e\\x2f\\x2f\\x73\\x68\\x50\\x48\\x89\\xe7\\x52\\x57\\x48\\x89\\xe6\\x48\\x31\\xc0\\xb0\\x3b\\x0f\\x05\";\nint main(int argc, char **argv) {\n    char code[500];\n    strcpy(code, shellcode);\n    int (*func)() = (int(*)())code;\n    func();\n    return 0;\n}\n' > call-shellcode.c

a32.out: call-shellcode.c
	$(CC) $(CFLAGS32_DBG) -o a32.out call-shellcode.c

a64.out: call-shellcode.c
	$(CC) -g -o a64.out call-shellcode.c

# ---------- create setuid version of a specified binary (use only in VM/container) ----------
# Usage: make setuid BIN=stack-L1
setuid:
ifndef BIN
	$(error "Please provide BIN target, e.g., make setuid BIN=stack-L1")
endif
	@echo "Setting owner to root and enabling setuid bit on $(BIN) (only do inside VM/container!)"
	sudo chown root:root $(BIN)
	sudo chmod 4755 $(BIN)
	@echo "Done."

# ---------- clean ----------
clean:
	rm -f stack-L1 stack-L2 stack-L3 stack-L4 \
	      stack-L1-dbg stack-L2-dbg stack-L3-dbg stack-L4-dbg \
	      a32.out a64.out call-shellcode.c badfile

.PHONY: all clean setuid
