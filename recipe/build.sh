#!/bin/bash

set -exuo pipefail


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
	
	sed -i.bak "s/export_symbols_cmds=/export_symbols_cmds2=/g" libtool
    sed "s/archive_expsym_cmds=/archive_expsym_cmds2=/g" libtool > libtool2
    echo "#!/bin/bash" > libtool
    echo "export_symbols_cmds=\"$SRC_DIR/create_def.sh \\\$export_symbols \\\$libobjs \\\$convenience \"" >> libtool
    echo "archive_expsym_cmds=\"\\\$CC -o \\\$tool_output_objdir\\\$soname \\\$libobjs \\\$compiler_flags \\\$deplibs -Wl,-DEF:\\\\\\\"\\\$export_symbols\\\\\\\" -Wl,-DLL,-IMPLIB:\\\\\\\"\\\$tool_output_objdir\\\$libname.dll.lib\\\\\\\"; echo \"" >> libtool
    cat libtool2 >> libtool
    sed -i.bak "s@|-fuse@|-fuse-ld=*|-nostdlib|-fuse@g" libtool
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
