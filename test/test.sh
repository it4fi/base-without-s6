#!/usr/bin/env bash

USER_UID=1001
USER_GID=$USER_UID

echo "Adding sudoer $1..."
groupadd --gid $USER_GID $1
useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $1
chown -R $1:$1 /home/$1
mkdir -p /etc/sudoers.d
echo $1 ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$1
chmod 0440 /etc/sudoers.d/$1
rm -f /home/$1/.bashrc
echo "  ... done"
