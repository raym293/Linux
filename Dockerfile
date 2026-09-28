# Official Ubuntu 24.04 LTS minimal base image
FROM ubuntu:24.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install essential OS lab packages with --no-install-recommends to keep total image size minimal.
# Includes:
#  - build-essential: gcc, g++, make, libc6-dev (standard C/C++ build toolchain)
#  - gdb: GNU debugger
#  - strace: system call tracer (critical for OS labs)
#  - valgrind: memory leak and pointer error detector
#  - procps: process utilities (ps, top, kill, free, pkill)
#  - man-db & manpages-dev: POSIX / Linux syscall man pages (e.g., man 2 fork, man 2 pipe)
#  - nano & vim-tiny: terminal text editors
#  - git, curl: useful for pulling lab repos and tests
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    gdb \
    strace \
    valgrind \
    procps \
    nano \
    vim-tiny \
    git \
    curl \
    iproute2 \
    man-db \
    manpages-dev \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /usr/share/doc/* /usr/share/man/?? /usr/share/man/??_*

# Configure nice color prompt for bash
RUN echo 'PS1="\[\033[01;32m\]os-lab@ubuntu\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /root/.bashrc

# Set working directory to the mounted workspace folder
WORKDIR /workspace

# Default command starts an interactive bash shell
CMD ["/bin/bash"]
