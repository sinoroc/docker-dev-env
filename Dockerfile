#


FROM debian:bookworm


# Install Debian packages
# =======================

RUN <<EOT
set -e
set -u
set -x
DEBIAN_FRONTEND=noninteractive apt-get update
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --no-install-recommends dist-upgrade
DEBIAN_FRONTEND=noninteractive apt-get --assume-yes --no-install-recommends install \
bash-completion \
curl \
git \
iproute2 \
pipx \
python3-venv \
silversearcher-ag \
sudo \
tree \
vim \
wget \
xz-utils
# Do not clean *apt*'s cache
EOT


# Install micromamba
# ==================

ARG micromamba_version='1.5.8-0'

RUN <<EOT
set -e
set -u
set -x
curl --fail --location \
--output /usr/local/bin/micromamba \
"https://github.com/mamba-org/micromamba-releases/releases/download/${micromamba_version}/micromamba-linux-64"
chmod +x /usr/local/bin/micromamba
echo 'export MAMBA_ROOT_PREFIX="${HOME}/.local/share/mamba"' >> /etc/bash.bashrc
EOT


# Install pixi
# ============

ARG pixi_version='v0.23.0'

RUN <<EOT
set -e
set -u
set -x
curl --fail --location \
--output /usr/local/bin/pixi \
"https://github.com/prefix-dev/pixi/releases/download/${pixi_version}/pixi-x86_64-unknown-linux-musl"
chmod +x /usr/local/bin/pixi
echo 'export PATH="${HOME}/.pixi/bin:${PATH}"' >> /etc/bash.bashrc
/usr/local/bin/pixi completion --shell=bash > /usr/share/bash-completion/completions/pixi
EOT


# Set up user
# ===========

ARG group_id
ARG group_name
ARG user_id
ARG user_name

RUN <<EOT
set -e
set -u
set -x
addgroup --gid "${group_id}" "${group_name}"
adduser --disabled-password --gid "${group_id}" --uid "${user_id}" "${user_name}"
adduser "${user_name}" sudo
echo '%sudo ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/group-sudo-nopasswd
EOT

# Do not set group ID, otherwise user has this one group only
USER ${user_id}

WORKDIR "/home/${user_name}"


# Set up pipx
# ===========

RUN <<EOT
set -e
set -u
set -x
mkdir --parent ~/.local/share/bash-completion/completions
pipx ensurepath
register-python-argcomplete pipx > .local/share/bash-completion/completions/pipx
EOT


# EOF
