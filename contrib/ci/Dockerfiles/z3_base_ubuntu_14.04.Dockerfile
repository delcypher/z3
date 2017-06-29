FROM ubuntu:14.04

RUN apt-get update && \
    apt-get -y --no-install-recommends install \
        binutils \
        clang-3.9 \
        cmake \
        doxygen \
        default-jdk \
        gcc-multilib \
        gcc-4.8-multilib \
        git \
        g++-multilib \
        g++-4.8-multilib \
        libasan0 \
        lib32asan0 \
        libgmp-dev \
        libgomp1 \
        lib32gomp1 \
        make \
        mono-devel \
        ninja-build \
        python3 \
        python3-setuptools \
        python2.7 \
        python-setuptools

# Create `user` user for container with password `user`.  and give it
# password-less sudo access
RUN useradd -m user && \
    echo user:user | chpasswd && \
    cp /etc/sudoers /etc/sudoers.bak && \
    echo 'user  ALL=(root) NOPASSWD: ALL' >> /etc/sudoers
USER user
WORKDIR /home/user

