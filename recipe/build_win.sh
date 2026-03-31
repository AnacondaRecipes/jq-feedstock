#!/bin/bash

cp -r ${BUILD_PREFIX}/share/libtool/build-aux/config.* ./config

chmod +x configure
HOST=--host=x86_64-w64-mingw32
pushd vendor/oniguruma
  autoreconf -vfi
popd
PREFIX=${PREFIX}
./configure --disable-maintainer-mode  \
            --prefix=$PREFIX  \
            --with-oniguruma=$PREFIX  \
            ${HOST}
make -j${CPU_COUNT}
make check
make install