#!/bin/bash

set -ex


# unset the SUBDIR variable since it changes the behavior of make here
unset SUBDIR

declare -a _CONFIG_OPTS=()

if [[ ${target_platform} == win-64 ]]
then
  # the target-os and toolchain picked up by default is mingw, so we have to configure
  # these flags ourselves to get it to build properly
  _CONFIG_OPTS+=("--ld=${LD}")
  _CONFIG_OPTS+=("--target-os=win64")
  _CONFIG_OPTS+=("--toolchain=msvc")
  _CONFIG_OPTS+=("--host-cc=${CC}")
  _CONFIG_OPTS+=("--enable-cross-compile")
  # pthreads doesn't exist on windows (without relying on msys2, etc)
  _CONFIG_OPTS+=("--disable-pthreads")
  _CONFIG_OPTS+=("--enable-w32threads")
  # manually include the runtime libs
  _CONFIG_OPTS+=("--extra-libs=ucrt.lib vcruntime.lib oldnames.lib")
  _CONFIG_OPTS+=("--disable-stripping")
  export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}
  # unistd.h is included in ${PREFIX}/include/zconf.h
  if [[ ! -f "${PREFIX}/include/unistd.h" ]]; then
      UNISTD_CREATED=1
      touch "${PREFIX}/include/unistd.h"
  fi

else
  export CFLAGS="-O2 -pthread -fstack-protector-all ${CFLAGS}"

fi
# Get an updated config.sub and config.guess
cp $BUILD_PREFIX/share/gnuconfig/config.* ./modules/oniguruma
cp $BUILD_PREFIX/share/gnuconfig/config.* ./config

chmod +x configure


./configure \
	--prefix=$PREFIX \
	--with-oniguruma=$PREFIX \
	--enable-shared \
	--disable-docs \
	--disable-valgrind

make -j${CPU_COUNT} ${VERBOSE_AT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check ${VERBOSE_AT}
fi

make install -j${CPU_COUNT} ${VERBOSE_AT}

if [[ "${target_platform}" == win-* ]]; then
  if [[ "${UNISTD_CREATED}" == "1" ]]; then
      rm -f "${PREFIX}/include/unistd.h"
  fi
fi
