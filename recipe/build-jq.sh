#!/bin/bash

cp -r ${BUILD_PREFIX}/share/libtool/build-aux/config.* ./config

chmod +x configure

if [[ $(uname) =~ M.* ]]; then
  HOST=--host=x86_64-w64-mingw32
  pushd modules/oniguruma
    autoreconf -vfi
  popd
  PREFIX=${PREFIX}/Library/mingw-w64
fi

./configure --disable-maintainer-mode  \
            --prefix=$PREFIX  \
            --with-oniguruma=$PREFIX  \
            ${HOST}
make -j${CPU_COUNT}
make check
make install
