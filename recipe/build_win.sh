#!/bin/bash

chmod +x configure
HOST=--host=x86_64-w64-mingw32
UCRT_PREFIX="${UCRT_PREFIX:-$PREFIX}"

# MinGW links libwinpthread dynamically by default; conda-build then requires
# ucrt64-libwinpthread-git. Static-link winpthread so jq.exe/libjq do not NEEDED it.
export LDFLAGS="${LDFLAGS} -Wl,-Bstatic -lwinpthread -Wl,-Bdynamic"

pushd vendor/oniguruma
  autoreconf -vfi
popd

./configure --disable-maintainer-mode  \
            --prefix=$UCRT_PREFIX  \
            --with-oniguruma=$PREFIX/Library  \
            ${HOST}

make -j${CPU_COUNT}
make check
make install