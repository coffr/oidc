FROM registry.access.redhat.com/ubi9:9.1.0-1782

ARG HOME=/root

COPY requirements.txt .tool-versions $HOME

ENV ASDF_VERSION=v0.11.3

RUN dnf install -y \
    git openssh-clients python3-pip make unzip && \
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
