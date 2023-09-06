#!/bin/bash

set -xeu

export PREFIX="$HOME/kfs_packages"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

mkdir $PREFIX
cd $PREFIX

wget https://ftp.gnu.org/gnu/grub/grub-2.06.tar.xz
tar -xvf grub-2.06.tar.xz

cd grub-2.06
./configure --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
make
make install
cd ..