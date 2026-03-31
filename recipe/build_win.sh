#!/bin/bash

chmod +x configure
HOST=--host=x86_64-w64-mingw32
pushd vendor/oniguruma
  autoreconf -vfi
popd

./configure --disable-maintainer-mode  \
            --prefix=$UCRT_PREFIX  \
            --with-oniguruma=$PREFIX/Library  \
            ${HOST}
make LDFLAGS=-all-static -j${CPU_COUNT}
make check
make install