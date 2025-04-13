FROM mcr.microsoft.com/devcontainers/base:debian
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get -y install --no-install-recommends gnupg2 curl lsb-release qemu-system mkisofs && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" > /etc/apt/sources.list.d/hashicorp.list && \
    apt-get update && \
    apt-get -y install --no-install-recommends packer && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN rm -rf /home/vscode/.ssh && \
    ln -s /workspaces/homelab/packer/ssh /home/vscode/.ssh