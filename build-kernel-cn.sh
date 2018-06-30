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
	echo -e "\033[33m DM-Verify 已去除！ \033[0m"
}


BUILD_NOW()
{
	MODEL=$1
	VER=$2
	KERNEL_CONFIG_FILE=$3
	echo -e "\033[33m 初始化中................. \033[0m"
	echo -e "\033[33m 开始编译：${MODEL} \033[0m"

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

	echo -e "\033[33m 机型：${MODEL} - 配置：${KERNEL_CONFIG_FILE} \033[0m"

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
		echo -e "\033[33m 使用 4 线程编译 \033[0m"
	else
		echo -e "\033[33m 使用 $NR_CPUS 线程编译 \033[0m"
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
		echo -e "\033[33m 复制编译好的内核文件....... \033[0m"

		cp "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb mkbootimg_tools/$MODEL/${VER}/kernel;

		time patchDMVerify "mkbootimg_tools/$MODEL/${VER}/kernel";

		for i in $(find "$KERNELDIR" -name '*.ko'); do
			$STRIP -g "$i"
			cp -av "$i" "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/;
		done;

		chmod 644 "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/*.ko

		sync

		pushd "$KERNELDIR"/mkbootimg_tools;
		"$KERNELDIR"/mkbootimg_tools/mkboot $MODEL/${VER}  "${MODEL}-SkyMi-${VER}-${VERSION}".img;
		popd;

		#cp "$KERNELDIR"/mkbootimg_tools/boot2.img "$KERNELDIR"/READY-KERNEL/boot.img
		#cd "$KERNELDIR"/READY-KERNEL;
		#zip -r Kernel-SAGIT-T-"$(date +"[%H-%M]-[%d-%m]-N")".zip * >/dev/null
		#mv *.zip "$KERNELDIR"/

		echo -e "\033[33m 清理中... \033[0m"
		rm "$KERNELDIR"/arch/arm64/boot/Image.gz-dtb;
		rm -rf "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/kernel;
		rm -rf "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/*.ko;
		git checkout "$KERNELDIR"/mkbootimg_tools/$MODEL/${VER}/ramdisk/crk_modules/

		echo -e "\033[36m 镜像目录：${KERNELDIR}/mkbootimg_tools/ \033[0m"
		echo -e "\033[32m 构建成功！ \033[0m"
	else
		# with red-color
		echo -e "\e[1;31m 构建内核停止! 没有发现 Image.gz-dtb \e[m"
	fi;
}


echo "你想编译啥?!";
select CHOICE in MI6 MIX2 ALL; do
	case "$CHOICE" in
		"MI6")
			BUILD_NOW "mi6" "cn" "sagit_user_defconfig";
			break;;
		"MIX2")
			BUILD_NOW "mix2" "cn" "chiron_user_defconfig";
			break;;
		"ALL")
			BUILD_NOW "mi6" "cn" "sagit_user_defconfig";
			BUILD_NOW "mix2" "cn" "chiron_user_defconfig";
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
