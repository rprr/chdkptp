#!/bin/sh
# copy this file to chdkptp.sh and adjust for your configuration
# to use the GUI build from a binary package that includes both CLI and GUI change to chdkptp_gui
CHDKPTP_EXE=chdkptp

# path where chdkptp is installed
CHDKPTP_DIR=$HOME/CHDK/chdkptp

# LD_LIBRARY_PATH for shared libraries
# only need if you have compiled IUP support and have NOT installed the libraries to system directories 

export DYLD_LIBRARY_PATH="$CHDKPTP_DIR/macosxiupcdlualibs"

export LUA_PATH="$CHDKPTP_DIR/lua/?.lua;;"
export LUA_CPATH="$CHDKPTP_DIR/?.so;;"

"$CHDKPTP_DIR/$CHDKPTP_EXE" "$@"
