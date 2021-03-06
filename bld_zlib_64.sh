#!/bin/bash
if [ $MSYSTEM != "MINGW64" ]; then
echo "You MUST launch MSYS2 using mingw64_shell.bat"
echo "OR set the PROCESS environment variable: MSYSTEM , to 'MINGW64', prior launching mintty.exe"
exit
fi
if [ ! -d zlib_64 ]; then
    mkdir zlib_64
fi
cd ~/zlib_64
if [ ! -f zlib-1.2.11.tar.gz ]; then
    wget http://zlib.net/zlib-1.2.11.tar.gz -O zlib-1.2.11.tar.gz
    tar zxvf zlib-1.2.11.tar.gz --strip-components=1
	cd contrib
	rm -r -d minizip
	mkdir minizip
fi
cd ~/zlib_64/contrib/minizip
if [ ! -d .git ]; then
    git clone -v --progress --config core.autocrlf=false git://github.com/nmoinvaz/minizip.git ./
	if [ "$?" != "0" ]; then
	  git clone -v --progress --config core.autocrlf=false https://github.com/nmoinvaz/minizip.git ./
	fi
fi
if [ "7914ff3cb785778b3ba540ecb92334f8b4b8e6e5" != $(git log -n 1 --format=%H) ]; then
	if [ "for_lsw_build2" != $(git rev-parse --abbrev-ref HEAD) ]; then
		git fetch -v --progress
	fi
	git checkout -b for_lsw_build2 7914ff3c
fi
cd ../../
cp ~/patches/mingw-w64-zlib/*.patch ./
patch -p1 -t -N < 01-zlib-1.2.11-1-buildsys.mingw.patch
patch -p2 -t -N < 03-dont-put-sodir-into-L.mingw.patch
patch -p1 -t -N < 04-fix-largefile-support.patch
cd contrib/minizip
git apply ../../010-unzip-add-function-unzOpenBuffer.patch
git apply ../../011-Add-no-undefined-to-link-to-enable-build-shared-vers.patch
git apply ../../012-Add-bzip2-library-to-pkg-config-file.patch

cd ../../
CFLAGS="-static" ./configure --prefix="/mingw64" --static
THREAD=$(nproc)
THREAD=$((THREAD<2?1:THREAD-1))
make -j$THREAD all
pushd contrib/minizip > /dev/null
autoreconf -fi

CFLAGS+=" -DHAVE_BZIP2"
./configure --prefix="/mingw64" --disable-shared --enable-static LIBS="-lbz2"
make -j$THREAD
popd > /dev/null
cd ~/zlib_64
make install
pushd ~/zlib/contrib/minizip > /dev/null
make install
popd > /dev/null

