# Official Ubuntu 24.04 LTS minimal base image
FROM ubuntu:24.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Restore man page support in Ubuntu minimal:
# 1. Remove Ubuntu minimal's dpkg exclude rule that prevents /usr/share/man/* from being unpacked.
# 2. Remove the diverted placeholder script so the real /usr/bin/man binary is restored.
RUN if [ -f /etc/dpkg/dpkg.cfg.d/excludes ]; then \
        sed -i '/path-exclude=\/usr\/share\/man\/*/d' /etc/dpkg/dpkg.cfg.d/excludes; \
    fi \
    && if [ "$(dpkg-divert --truename /usr/bin/man)" = "/usr/bin/man.REAL" ]; then \
        rm -f /usr/bin/man \
        && dpkg-divert --quiet --remove --rename /usr/bin/man; \
    fi

# Install essential OS lab packages with --no-install-recommends to keep total image size minimal.
# Includes:
#  - build-essential: gcc, g++, make, libc6-dev (standard C/C++ build toolchain)
#  - gdb: GNU debugger
#  - strace: system call tracer (critical for OS labs)
#  - valgrind: memory leak and pointer error detector
#  - procps: process utilities (ps, top, kill, free, pkill)
#  - less: interactive pager required by man
#  - man-db, manpages, manpages-dev, manpages-posix, manpages-posix-dev:
#    complete Linux & POSIX manuals (e.g., man 2 fork, man 2 pipe, man 3 pthread_create, man 1 ls)
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
    less \
    git \
    curl \
    iproute2 \
    man-db \
    manpages \
    manpages-dev \
    manpages-posix \
    manpages-posix-dev \
    ca-certificates \
    && dpkg -S /usr/share/man/ | sed 's|, |\n|g;s|: [^:]*$||' | xargs apt-get install --reinstall --no-install-recommends -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    && rm -rf /usr/share/doc/* /usr/share/man/?? /usr/share/man/??_* \
    && mandb -c

# Configure nice color prompt for bash
RUN echo 'PS1="\[\033[01;32m\]os-lab@ubuntu\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ "' >> /root/.bashrc

# Set working directory to the mounted workspace folder
WORKDIR /workspace

# Default command starts an interactive bash shell
CMD ["/bin/bash"]
