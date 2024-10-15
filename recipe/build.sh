#!/bin/bash

set -ex


# unset the SUBDIR variable since it changes the behavior of make here
unset SUBDIR

declare -a _CONFIG_OPTS=()

if [[ ${target_platform} == win-64 ]]
then
	export PKG_CONFIG_PATH=${PREFIX}/lib/pkgconfig:${PKG_CONFIG_PATH}
	# unistd.h is included in ${PREFIX}/include/zconf.h
	if [[ ! -f "${PREFIX}/include/unistd.h" ]]; then
		UNISTD_CREATED=1
		touch "${PREFIX}/include/unistd.h"
	fi
	
	autoreconf -iv

	./configure \
		--prefix=$PREFIX \
		--with-oniguruma=$PREFIX \
		--enable-shared \
		--disable-docs \
		--disable-valgrind \
		"${_CONFIG_OPTS[@]}" || (cat config.log && false)

else
    export CFLAGS="-O2 -pthread -fstack-protector-all ${CFLAGS}"
    # Get an updated config.sub and config.guess
	cp $BUILD_PREFIX/share/libtool/build-aux/config.* ./modules/oniguruma
	cp $BUILD_PREFIX/share/libtool/build-aux/config.* .

	chmod +x configure
	./configure \
		--prefix=$PREFIX \
		--with-oniguruma=$PREFIX \
		--enable-shared \
		-disable-docs \
		--disable-valgrind \
		"${_CONFIG_OPTS[@]}"
fi

make -j${CPU_COUNT} ${VERBOSE_AT}

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check ${VERBOSE_AT}
fi

make install -j${CPU_COUNT} ${VERBOSE_AT}
