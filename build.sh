#!/usr/bin/env bash
SECONDS=0 # builtin bash timer
zipname="Samsung-A51-nethunter-$(date '+%Y%m%d-%H%M').zip"
topdir="$(pwd)"
toolchain="$topdir/Neutron_Clang_18/"
ak3_dir="$topdir/AnyKernel3"
nh_defconfig="arch/arm64/configs/nethunter_defconfig"

export PATH="$toolchain/bin:$PATH"

if [ ! -d "$toolchain" ]; then
	echo "Downloading toolchain..."
	mkdir -p $toolchain && cd $toolchain
	curl -fSsL https://github.com/Neutron-Toolchains/clang-build-catalogue/releases/download/05012024/neutron-clang-05012024.tar.zst | tar --zstd -xvf -
	tc_result="$?"
	if [ $tc_result -ne 0 ]; then
		echo "Download failed!"
		exit $tc_result
	fi
fi

if [ ! -d $TOPDIR/out ]; then
    mkdir -p $TOPDIR/out
fi

make O=out ARCH=arm64 $nh_defconfig

echo -e "\nStarting compilation...\n"
make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 Image 2> >(tee log.txt >&2) || exit $?
kernel="out/arch/arm64/boot/Image"
if [ ! -f "$kernel" ]; then
	if [ -f "arch/arm64/boot/Image" ];
		kernel="arch/arm64/boot/Image"
	else
		echo "Build failed"
		exit 1
	fi
else
	echo -e "\nKernel compiled succesfully! Zipping up...\n"
	if [ ! -d "$ak3_dir" ]; then
		mkdir -p $ak3_dir
	fi
	cd $ak3_dir
	echo "Downloading latest released zip to freshen with new kernel"
	curl -o Samsung-A51-nethunter.zip https://github.com/akabul0us/android_kernel_samsung_universal9611/releases/download/Nethunter-Samsung-A51-1.0.0/Samsung-A51-nethunter-20250730-1119.zip
	unzip Samsung-A51-nethunter.zip
	cp $topdir/$kernel .
	zip -f0 Samsung-A51-nethunter.zip Image
	mv Samsung-A51-nethunter.zip $topdir/out/$zipname
	cd $topdir
	echo -e "\nCompleted in $((SECONDS / 60)) minute(s) and $((SECONDS % 60)) second(s) !"
	echo "Zip: $zipname"
else
	echo -e "\nCompilation failed!"
	exit 1
fi
#check if config contained any instructions to build as modules - if so build them
grep "=m" $topdir/out/.config > /dev/null
mod_result="$?"
if [ "$mod_result" -eq 0 ]; then
	echo "Configuration with modules detected -- building modules"
	make -j$(nproc --all) O=out ARCH=arm64 CC=clang LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- LLVM=1 LLVM_IAS=1 modules
	bash $TOPDIR/pack_module_tarball.sh
else
	echo "No modules detected in configuration, so not building any"
fi

