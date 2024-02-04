#


FROM debian:bookworm

ARG group_id
ARG group_name
ARG user_id
ARG user_name

RUN <<EOT
set -e
set -x
apt-get update
apt-get --assume-yes --no-install-recommends upgrade
apt-get --assume-yes --no-install-recommends install \
bash-completion \
curl \
git \
pipx \
python3-venv \
silversearcher-ag \
sudo \
tree \
vim \
xz-utils
# Do not clean *apt* cache
EOT

RUN <<EOT
set -e
set -x
echo "%sudo ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/group-sudo-nopasswd
echo "${user_name} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/user-${uname}-nopasswd
addgroup --gid ${group_id} ${group_name}
adduser --disabled-password --gid ${group_id} --uid ${user_id} ${user_name}
adduser ${user_name} sudo
EOT

USER ${user_id}:${group_id}

WORKDIR "/home/${user_name}"

RUN <<EOT
#!/usr/bin/env bash
mkdir --parent ~/.local/share/bash-completion/completions
pipx ensurepath
register-python-argcomplete pipx > .local/share/bash-completion/completions/pipx
"${SHELL}" <(curl -L micro.mamba.pm/install.sh)
EOT


# EOF
