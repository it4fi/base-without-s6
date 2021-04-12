FROM --platform=${BUILDPLATFORM} ubuntu

# root filesystem {{{1
COPY rootfs /

# create *min files for apt* and dpkg* in order to avoid issues with locales {{{1
# and interactive interfaces
RUN ls /usr/bin/apt* /usr/bin/dpkg* |                                    \
    while read line; do                                                  \
      min=$line-min;                                                     \
      printf '#!/bin/sh\n/usr/bin/apt-dpkg-wrapper '$line' $@\n' > $min; \
      chmod +x $min;                                                     \
    done

# temporarily disable dpkg fsync to make building faster. {{{1
RUN if [ ! -e /etc/dpkg/dpkg.cfg.d/docker-apt-speedup ]; then         \
	    echo force-unsafe-io > /etc/dpkg/dpkg.cfg.d/docker-apt-speedup; \
    fi

# prevent initramfs updates from trying to run grub and lilo. {{{1
# https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
# http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=594189
ENV INITRD no

# enable Ubuntu Universe and Multiverse. {{{1
RUN sed -i 's/^#\s*\(deb.*universe\)$/\1/g' /etc/apt/sources.list   && \
    sed -i 's/^#\s*\(deb.*multiverse\)$/\1/g' /etc/apt/sources.list && \
    apt-get-min update

# fix some issues with APT packages. {{{1
# see https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert-min --local --rename --add /sbin/initctl && \
    ln -sf /bin/true /sbin/initctl

# replace the 'ischroot' tool to make it always return true. {{{1
# prevent initscripts updates from breaking /dev/shm.
# https://journal.paul.querna.org/articles/2013/10/15/docker-ubuntu-on-rackspace/
# https://bugs.launchpad.net/launchpad/+bug/974584
RUN dpkg-divert-min --local --rename --add /usr/bin/ischroot && \
    ln -sf /bin/true /usr/bin/ischroot

# install HTTPS support for APT. {{{1
RUN apt-get-install-min apt-transport-https ca-certificates

# install add-apt-repository {{{1
RUN apt-get-install-min software-properties-common

# upgrade all packages. {{{1
RUN apt-get-min dist-upgrade -y --no-install-recommends

# fix locale. {{{1
ENV LANG en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
RUN apt-get-install-min language-pack-en        && \
    locale-gen en_US                            && \
    update-locale LANG=$LANG LC_CTYPE=$LC_CTYPE

# Add test user - a sudoer. {{{1
ARG CURRENT_UID
ARG USERNAME=test_user
ARG USER_UID=${CURRENT_UID}
ARG USER_GID=$USER_UID
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && rm -f /home/$USERNAME/.bashrc \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME \
    && apt-get update && apt-get -y install make sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Install common compilation tools {{{1
RUN apt-get update && apt-get -y install git build-essential pkg-config \
    autoconf automake libtool \
    bison flex libpq-dev parallel libunwind-dev
