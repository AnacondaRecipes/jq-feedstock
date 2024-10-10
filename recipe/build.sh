#!/bin/bash

set -ex

# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./modules/oniguruma
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config

chmod +x configure

./configure \
    --prefix=$PREFIX \
	--with-oniguruma=$PREFIX \
	--enable-shared \
    --disable-docs

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi

make install
