#!/bin/bash

LANG=C

CT="$KERNELDIR"/android-toolchain-arm64/bin/aarch64-SAGIT-linux-android-;

cp -pv .config .config.bkp;
make ARCH=arm mrproper CROSS_COMPILE=${CT};
make clean;
cp -pv .config.bkp .config;

git checkout android-toolchain-arm64/

# clean ccache
read -t 5 -p "clean ccache, 5sec timeout (y/n)?";
if [ "$REPLY" == "y" ]; then
        ccache -C;
fi;
