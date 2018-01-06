#! /bin/sh
#
# Script to build lua, iup, cd, im libraries for chdkptp gui
# Also prefer to have freetype2 as well
#

builddir=$HOME/CHDK
osdir=`sw_vers -productVersion | awk '{printf("%s%s\n",substr($1,1,2),substr($1,4,2))}'`

if false ; then
# Get archives
mkdir -p $builddir/archives
cd $builddir/archives
wget https://sourceforge.net/projects/iup/files/3.21/Docs%20and%20Sources/freetype-2.6.3_Sources.zip
wget https://sourceforge.net/projects/iup/files/3.21/Docs%20and%20Sources/iup-3.21_Sources.zip
wget https://sourceforge.net/projects/imtoolkit/files/3.12/Docs%20and%20Sources/im-3.12_Sources.zip
wget https://sourceforge.net/projects/canvasdraw/files/5.11/Docs%20and%20Sources/cd-5.11_Sources.zip
wget http://www.lua.org/ftp/lua-5.2.4.tar.gz
fi

# Create teclibs dir
cd $builddir
mkdir -p teclibs
cd teclibs


# Build Lua
cd $builddir/teclibs
\rm -fr lua-5.2.4
tar -xvzf $builddir/archives/lua-5.2.4.tar.gz
cd lua-5.2.4/
make macosx
make install INSTALL_TOP=../../lua52
cd ..

# Create Lua dynamic library
\rm -fr lua52/lib/MacOS$osdir
mkdir -p lua52/lib/MacOS$osdir
cd lua52/lib/MacOS$osdir
g++ -fpic -shared -Wl,-all_load ../liblua.a -Wl,-noall_load -o liblua.dylib
ln -s liblua.dylib liblua52.dylib

# Unpack the 4 zip files
cd $builddir/teclibs
\rm -fr iup cd freetype im
unzip ../archives/iup-3.21_Sources.zip
unzip ../archives/cd-5.11_Sources.zip
unzip ../archives/freetype-2.6.3_Sources.zip
unzip ../archives/im-3.12_Sources.zip

# patch the above files for tecmake
patch -p1 < ../patchfile-teclibs-macports

# Need unixprint from macports 
export CPATH=/opt/local/include/gtk-3.0/unix-print

# Build freetype
cd $builddir/teclibs/freetype
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes

# Build im
cd $builddir/teclibs/im
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes

# Build cd
cd $builddir/teclibs/cd
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes

# Build iup libs
cd $builddir/teclibs/iup
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes iup
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes iupcd
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes iupcontrols

cd $builddir/teclibs/iup/srclua5
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes iuplua
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes iupluacd
make BUILD_DYLIB=Yes USE_GTK3=Yes USE_LUA52=Yes iupluacontrols

# Copy the libs into archive
\rm -fr $builddir/teclibs/macosxiupcdlualibs
mkdir -p $builddir/teclibs/macosxiupcdlualibs
cd $builddir/teclibs/macosxiupcdlualibs

iuplibdir=$builddir/teclibs/iup/lib/MacOS$osdir
cdlibdir=$builddir/teclibs/cd/lib/MacOS$osdir
lualibdir=$builddir/teclibs/lua52/lib/MacOS$osdir

cp $iuplibdir/libiup.dylib .
cp $iuplibdir/libiupcd.dylib .
cp $iuplibdir/Lua52/libiuplua52.dylib .
cp $iuplibdir/Lua52/libiupluacd52.dylib .
cp $cdlibdir/libcd.dylib .
cp $cdlibdir/Lua52/libcdlua52.dylib .
cp $lualibdir/liblua.dylib .
cp $lualibdir/liblua52.dylib .

cd $builddir/teclibs/
tar -cvzf $builddir/macosxiupcdlualibs.tgz macosxiupcdlualibs

# Get and build chdkptpgui
cd $builddir
\rm -fr chdkptp
svn co https://subversion.assembla.com/svn/chdkptp/trunk chdkptp
cd $builddir/chdkptp 
tar -xvzf $builddir/macosxiupcdlualibs.tgz
cp $builddir/config.mk-mac config.mk
make IUP_SUPPORT=1 CD_SUPPORT=1
cp $builddir/chdkptp-mac.sh .
