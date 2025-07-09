#!/bin/bash

set -ex

autoreconf -i

export CFLAGS="-O2 -pthread -fPIC -fstack-protector-all ${CFLAGS} "

# Add JQ_VERSION definition
export CFLAGS="${CFLAGS} -DJQ_VERSION='\"${PKG_VERSION}\"'"

./configure \
	--prefix=$PREFIX \
	--with-oniguruma=$PREFIX \
	--enable-shared \
	--disable-docs \
	--disable-valgrind

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check VERBOSE=yes
fi

make install
