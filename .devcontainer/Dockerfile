FROM registry.access.redhat.com/ubi9:9.1.0-1782

ARG USERNAME=someuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

COPY requirements.txt .tool-versions /root/

ENV ASDF_VERSION=v0.11.3

RUN dnf install -y \
    git openssh-clients python3-pip make unzip && \
    dnf clean all -y

USER $USERNAME
WORKDIR /home/$USERNAME

COPY requirements.txt .tool-versions ./

RUN git clone https://github.com/asdf-vm/asdf.git .asdf --branch "${ASDF_VERSION}" --depth 1 && \
    . $HOME/.asdf/asdf.sh && \
    echo . "$HOME/.asdf/asdf.sh" > $HOME/.bash_profile && \
    asdf plugin-add awscli && \
    asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git && \
    asdf plugin-add pulumi && \
    asdf plugin-add terragrunt && \
    asdf install && \
    pip3 install -r requirements.txt
