#!/bin/bash
BINUTILS_VER=$(qatom -F '%{PV}' $(qfile -v $(realpath /usr/bin/ld) | cut -d' ' -f1))
GCC_VER=$(qatom -F '%{PV}' $(qfile -v $(realpath /usr/bin/gcc) | cut -d' ' -f1))
KERNEL_VER=$(qatom -F '%{PV}' $(qlist -Ive sys-kernel/linux-headers))
LIBC_VER=$(qatom -F '%{PV}' $(qlist -Ive sys-libs/glibc))

cat << EOM
ARG BINUTIL_VER='~${BINUTILS_VER}'
ARG GCC_VER='~${GCC_VER}'
ARG KERNEL_VER='~${KERNEL_VER}'
ARG LIBC_VER='~${LIBC_VER}'
ARG TARGET='$(portageq envvar CHOST)"
EOM

echo "crossdev --b '~${BINUTILS_VER}' --g '~${GCC_VER}' --k '~${KERNEL_VER}' --l '~${LIBC_VER}' -t $(portageq envvar CHOST)"


