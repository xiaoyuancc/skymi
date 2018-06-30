#!/bin/sh
clear

LANG=C
VERSION="v1"

# What you need installed to compile
# gcc, gpp, cpp, c++, g++, lzma, lzop, ia32-libs flex

# What you need to make configuration easier by using xconfig
# qt4-dev, qmake-qt4, pkg-config

# toolchain is already exist and set! in kernel git. android-toolchain-arm64/bin/

# location
KERNELDIR=$(readlink -f .);

#编译器链
CT="$KERNELDIR"/android-toolchain-arm64/bin/aarch64-SAGIT-linux-android-;
STRIP="$KERNELDIR"/android-toolchain-arm64/bin/aarch64-SAGIT-linux-android-strip;

mkd()
{
	if [ ! -e "$KERNELDIR"/mkbootimg_tools/$1/$2/ramdisk/$3 ]; then
			mkdir "$KERNELDIR"/mkbootimg_tools/$1/$2/ramdisk/$3;
	fi;
}

patchDMVerify()
{
	sed -i 's/\x2c\x76\x65\x72\x69\x66\x79/\x00\x00\x00\x00\x00\x00\x00/g' $1;
	echo -e "\033[33m DM-Verify patched. \033[0m"
}

BUILD_NOW()
{
	MODEL=$1
	VER=$2
	KERNEL_CONFIG_FILE=$3
	echo -e "\033[33m Initialising................. \033[0m"
	echo -e "\033[33m Building：${MODEL} \033[0m"

	if [ -e "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/kernel ]; then
		rm "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/kernel;
	fi;
	if [ -e "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/wlan.ko ]; then
		rm "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/*.ko;
	fi;
	if [ -e "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb ]; then
		rm "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb;
	fi;

	if [ -e "$KERNELDIR"/READY-KERNEL/boot.img ]; then
		rm "$KERNELDIR"/READY-KERNEL/boot.img;
	fi;

	echo -e "\033[33m Model：${MODEL} - Config：${KERNEL_CONFIG_FILE} \033[0m"

	# mkdir start
	mkd ${MODEL} ${VER} "acct";
	mkd ${MODEL} ${VER} "bt_firmware";
	mkd ${MODEL} ${VER} "cache";
	mkd ${MODEL} ${VER} "config";
	mkd ${MODEL} ${VER} "data";
	mkd ${MODEL} ${VER} "dev";
	mkd ${MODEL} ${VER} "dsp";
	mkd ${MODEL} ${VER} "firmware";
	mkd ${MODEL} ${VER} "mnt";
	mkd ${MODEL} ${VER} "oem";
	mkd ${MODEL} ${VER} "persist";
	mkd ${MODEL} ${VER} "proc";
	mkd ${MODEL} ${VER} "storage";
	mkd ${MODEL} ${VER} "sys";
	mkd ${MODEL} ${VER} "system";
	# mkdir end

	# remove all old modules before compile
	for i in $(find "$KERNELDIR"/ -name "*.ko"); do
		rm -f "$i";
	done;

	# Idea by savoca
	NR_CPUS=$(grep -c ^processor /proc/cpuinfo)

	if [ "$NR_CPUS" -le "2" ]; then
		NR_CPUS=4;
		echo -e "\033[33m Building kernel with 4 CPU threads \033[0m"
	else
		echo -e "\033[33m Building kernel with $NR_CPUS CPU threads \033[0m"
	fi;

	TP="sagit"
	if [ "$MODEL" == "mix2" ]; then
		TP="chiron";
		echo -e "\033[33m TARGET_PRODUCT = ${TP} \033[0m"
	else
		echo -e "\033[33m TARGET_PRODUCT = ${TP} \033[0m"
	fi;

	# build config
	time make ARCH=arm64 ${KERNEL_CONFIG_FILE} TARGET_PRODUCT=${TP}

	# build kernel and modules
	time make ARCH=arm64 TARGET_PRODUCT=${TP} CROSS_COMPILE=${CT} -j $NR_CPUS

	cp "$KERNELDIR"/.config "$KERNELDIR"/arch/arm64/configs/"$KERNEL_CONFIG_FILE";

	if [ -e "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb ]; then

		stat "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb;

		# move the compiled Image.gz-dtb and modules into the READY-KERNEL working directory
		echo "Move compiled objects........"

		cp "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb mkbootimg_tools/$MODEL/${VER}/kernel;

		time patchDMVerify "mkbootimg_tools/$MODEL/${VER}/kernel";

		for i in $(find "$KERNELDIR" -name '*.ko'); do
			$STRIP -g "$i"
			cp -av "$i" "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/;
		done;

		chmod 644 "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/*.ko

		if [ "$PYTHON_WAS_3" -eq "1" ]; then
			rm /usr/bin/python
			ln -s /usr/bin/python3 /usr/bin/python
		fi;

		sync

		pushd "$KERNELDIR"/mkbootimg_tools;
		"$KERNELDIR"/mkbootimg_tools/mkboot $MODEL/${VER}  "${MODEL}-SkyMi-${VER}-${VERSION}".img;
		popd;

		#cp "$KERNELDIR"/mkbootimg_tools/boot2.img "$KERNELDIR"/READY-KERNEL/boot.img
		#cd "$KERNELDIR"/READY-KERNEL;
		#zip -r Kernel-SAGIT-T-"$(date +"[%H-%M]-[%d-%m]-N")".zip * >/dev/null
		#mv *.zip "$KERNELDIR"/

		echo -e "\033[33m Cleaning... \033[0m"
		rm "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb;
		rm -rf "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/kernel;
		rm -rf "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/*.ko;
		git checkout "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/

		echo -e "\033[36m ImgDir：${KERNELDIR}/mkbootimg_tools/$MODEL/${VER} \036[0m"
		echo -e "\033[32m All Done \033[0m"
	else

		# with red-color
		echo -e "\e[1;31mKernel STUCK in BUILD! no Image.gz-dtb exist\e[m"
	fi;
}


echo "What to cook for you?!";
select CHOICE in MI6 MIX2 ALL; do
	case "$CHOICE" in
		"MI6")
			BUILD_NOW "mi6" "en" "sagit_user_defconfig";
			break;;
		"MIX2")
			BUILD_NOW "mix2" "en" "chiron_user_defconfig";
			break;;
		"ALL")
			BUILD_NOW "mi6" "en" "sagit_user_defconfig";
			BUILD_NOW "mix2" "en" "chiron_user_defconfig";
			break;;
	esac;
done;

#./sepolicy-inject -s system_server -t rootfs -c system -p module_load -P sepolicy
#./sepolicy-inject -s shell -t rootfs -c file -p getattr -P sepolicy
#./sepolicy-inject -s mt_daemon -t rootfs -c dir -p read -P sepolicy2
#./sepolicy-inject -s mt_daemon -t rootfs -c lnk_file -p getattr -P sepolicy
#./sepolicy-inject -s mt_daemon -t storage_file -c dir -p getattr -P sepolicy
#./sepolicy-inject -s mt_daemon -t adsprpcd_file -c dir -p getattr -P sepolicy
#./sepolicy-inject -s mt_daemon -t cache_file -c dir -p getattr -P sepolicy
#./sepolicy-inject -s mt_daemon -t tmpfs -c dir -p search -P sepolicy2
