# syntax=docker/dockerfile:1
ARG UBUNTU_VERSION=24.04
FROM ubuntu:${UBUNTU_VERSION}

ARG DEBIAN_FRONTEND=noninteractive
ARG CLUSTER_UID=1001

LABEL org.opencontainers.image.title="hpc-node" \
    org.opencontainers.image.description="Image tunggal untuk head node dan compute node"

# Editor + SSH server + SSH client
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    openssh-server openssh-client nano vim \
    && rm -rf /var/lib/apt/lists/*

# Tool diagnosa jaringan (ping, ip, nslookup, nc, ps)
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    iputils-ping iproute2 dnsutils netcat-openbsd procps less \
    && rm -rf /var/lib/apt/lists/*

# Compiler C + OpenMPI
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    build-essential openmpi-bin libopenmpi-dev \
    && rm -rf /var/lib/apt/lists/*

# User non-root untuk menjalankan job (least privilege)
RUN userdel -r ubuntu 2>/dev/null || true \
    && useradd --create-home --shell /bin/bash --uid ${CLUSTER_UID} hpcuser \
    && usermod -p '*' hpcuser

COPY config/sshd_config.d/10-hpc.conf /etc/ssh/sshd_config.d/10-hpc.conf
COPY config/ssh_config.d/10-hpc.conf  /etc/ssh/ssh_config.d/10-hpc.conf
COPY docker/entrypoint.sh             /usr/local/bin/entrypoint.sh

# Bersihkan CRLF (jika file dibuat di Windows) dan beri izin eksekusi
RUN sed -i 's/\r$//' /etc/ssh/sshd_config.d/10-hpc.conf \
    /etc/ssh/ssh_config.d/10-hpc.conf \
    /usr/local/bin/entrypoint.sh \
    && chmod 0755 /usr/local/bin/entrypoint.sh

ENV OMPI_MCA_btl_vader_single_copy_mechanism=none

WORKDIR /home/hpcuser
EXPOSE 22
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]