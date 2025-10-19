# Dockerfile: Ubuntu 20.04 image for the SEED buffer overflow lab

FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    gcc-multilib g++-multilib libc6-dev-i386 \
    gdb \
    make \
    python3 \
    zsh \
    vim nano file \
  && rm -rf /var/lib/apt/lists/*

# Optional: create an unprivileged user to test setuid behavior
RUN useradd -m -s /bin/bash student

WORKDIR /lab
