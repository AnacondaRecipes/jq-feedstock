#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./modules/oniguruma
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config

chmod +x configure

export CFLAGS="-O2 -pthread -fstack-protector-all ${CFLAGS}"

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
