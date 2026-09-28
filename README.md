# OS Lab Linux Environment (Minimal Ubuntu)

A lightweight Docker environment mirroring Ubuntu 24.04 LTS designed specifically for Operating Systems lab exercises, system call analysis, process management, and POSIX C/C++ programming.

---

## ⚡ Quick Start

From this directory on your host Mac, run:

```bash
python3 start.py
```
*(or `./start.py`)*

This script automatically:
1. Verifies Docker Desktop is running.
2. Ensures the container is built and started in the background.
3. Attaches an interactive bash shell in the Linux environment at `/workspace`.

When you type `exit`, you return to macOS, while the container remains running in the background for quick re-entry.

---

## 📊 Image Size & Specs

| Metric | Measured Value | Notes |
| :--- | :--- | :--- |
| **Download / Content Size** | **192 MB** | Compressed layers transferred over the network |
| **Uncompressed Linux Filesystem** | **~595 MB** | Ubuntu OS rootfs + toolchains, debuggers & manuals |
| **Total Disk Footprint in Docker** | **777 MB** | Complete image on disk including container layer |
| **Host Project Directory (`/Linux`)** | **~32 KB** | Local launcher scripts and source files |

### Why not Alpine Linux (~5 MB)?
Alpine uses `musl` libc instead of GNU `glibc`. University OS labs rely heavily on GNU glibc behavior, process memory layouts, `strace`, `valgrind`, `gettid`, `clone()`, and POSIX thread semantics. Running lab code on Alpine frequently causes subtle compilation or runtime incompatibilities. This image uses official **Ubuntu 24.04 minimal** with restored man pages and stripped non-English caches to deliver **100% Ubuntu parity at minimal size**.

---

## 📂 Project Structure & Syncing

```text
.
├── Dockerfile            # Minimal Ubuntu 24.04 image with OS toolchains
├── docker-compose.yml    # Service config with SYS_PTRACE capability & seccomp
├── .dockerignore        # Excludes local files from image build context
├── start.py              # One-command launcher & CLI helper
├── README.md             # This documentation
└── src/                  # Mounted to /workspace inside the container
    ├── Makefile          # Starter build & test scripts
    └── hello_os.c        # Sample OS lab program (fork, waitpid, mem layout)
```

### Automatic File Synchronization:
- The local `./src/` folder on your Mac is directly mounted to `/workspace` inside the container.
- **Edit on Mac:** Open files in `./src/` with VS Code, Cursor, Xcode, or any editor of choice.
- **Run in Linux:** Run `make`, `gcc`, `gdb`, or `strace` inside the container shell.
- **Persistence:** All binaries, object files, and logs created in `/workspace` persist on your Mac inside `./src/`.

---

## 🛠️ Toolchain Included

| Tool | Purpose | Example OS Lab Command |
| :--- | :--- | :--- |
| **`gcc` / `g++`** | C/C++ Compiler | `gcc -Wall -Wextra -g hello_os.c -o hello_os` |
| **`make`** | Automated build tool | `make run` |
| **`strace`** | System call tracer | `strace -e trace=process,memory ./hello_os` |
| **`gdb`** | GNU Debugger | `gdb ./hello_os` |
| **`valgrind`** | Memory leak detector | `valgrind --leak-check=full ./hello_os` |
| **`procps`** | Process inspection | `ps aux`, `top`, `kill`, `free -m` |
| **`man-db` & `less`** | Manual pager & database | `man 2 fork`, `man 1 ls`, `man -k socket` |
| **`manpages-*`** | Linux syscalls, POSIX & C libc manuals | `man 2 waitpid`, `man 3 pthread_create`, `man 7 signal` |
| **`nano` / `vim-tiny`** | In-terminal text editors | `nano hello_os.c` |

> [!NOTE]
> **SYS_PTRACE & Seccomp:** `docker-compose.yml` includes `cap_add: [SYS_PTRACE]` and `security_opt: [seccomp:unconfined]`. These allow `strace`, `gdb`, and process inspection syscalls (`ptrace`, `clone`) to operate without "Operation not permitted" permission errors inside the container.

> [!TIP]
> **Complete Manual Pages in Minimal Ubuntu:** Ubuntu minimal images suppress manual pages by default via dpkg exclusions and divert `/usr/bin/man` to a stub script. This image removes those restrictions, installs complete Linux system call (`manpages-dev`), POSIX standard (`manpages-posix`, `manpages-posix-dev`), and user command manuals, installs `less` as the interactive pager, and indexes the manual database with `mandb -c` while stripping non-English translations to preserve the lightweight footprint.

---

## 🧪 Testing the Environment

Inside the container terminal:

```bash
# Verify you are in the workspace
pwd
# Output: /workspace

# Compile and run the sample OS demo program
make run

# Trace process creation (clone, fork) and memory system calls
make trace

# Run with Valgrind to check for memory leaks
make check-mem

# Read Linux system call manuals (Section 2)
man 2 fork
man 2 waitpid
man 2 pipe

# Read C library and POSIX threads documentation (Section 3)
man 3 malloc
man 3 pthread_create

# Read command & system overview manuals (Sections 1 & 7)
man 1 ls
man 1 gcc
man 7 signal
```

---

## 🕹️ CLI Controls

### Using `start.py`:
```bash
python3 start.py            # Start container and attach interactive bash shell
python3 start.py --stop     # Pause/stop the running container
python3 start.py --down     # Stop and remove the container
python3 start.py --rebuild  # Rebuild the Docker image
```

### Using standard Docker commands:
```bash
docker compose up -d              # Start container in background
docker compose exec os-lab bash   # Enter interactive shell
docker compose stop               # Stop container
docker compose down               # Stop and remove container
```
