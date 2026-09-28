CC = gcc
CFLAGS = -Wall -Wextra -g

all: hello_os

hello_os: hello_os.c
	$(CC) $(CFLAGS) -o hello_os hello_os.c

run: hello_os
	./hello_os

trace: hello_os
	strace -e trace=process,memory ./hello_os

check-mem: hello_os
	valgrind --leak-check=full ./hello_os

clean:
	rm -f hello_os

.PHONY: all run trace check-mem clean
