#!/bin/bash

chmod +x configure

if [[ $(uname) =~ M.* ]]; then
  HOST=--host=x86_64-w64-mingw32
  pushd modules/oniguruma
    autoreconf -vfi
  popd
  PREFIX=${PREFIX}/mingw64
fi

./configure --disable-maintainer-mode  \
            --prefix=$PREFIX  \
            --with-oniguruma=$PREFIX  \
            ${HOST}
make -j${CPU_COUNT}
make check
make install
