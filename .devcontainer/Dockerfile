FROM registry.access.redhat.com/ubi9:9.2-755@sha256:351ed8b24d440c348486efd99587046e88bb966890a9207a5851d3a34a4dd346

ARG HOME=/root

COPY requirements.txt .tool-versions $HOME

ENV ASDF_VERSION=v0.11.3

RUN dnf install -y \
    git openssh-clients python3-pip make unzip \
    openssl-devel-1:3.0.7-6.el9_2.x86_64 \
    perl-4:5.32.1-480.el9.x86_64 \
    zlib-devel-1.2.11-39.el9.x86_64 && \
    dnf clean all -y && \
    git clone https://github.com/asdf-vm/asdf.git $HOME/.asdf --branch "${ASDF_VERSION}" --depth 1 && \
    . $HOME/.asdf/asdf.sh && \
    echo . "$HOME/.asdf/asdf.sh" > $HOME/.bash_profile && \
    asdf plugin-add awscli && \
    asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git && \
    asdf plugin-add pulumi && \
    asdf plugin-add terragrunt && \
    asdf install && \
    pip3 install -r $HOME/requirements.txt
