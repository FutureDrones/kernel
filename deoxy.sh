#!/bin/bash 

# i am kernel retard 
function start() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• DeOxyKernel •</b>%0ABuild started on <code>Drone CI</code>%0A <b>For device</b> <i>miatoll</i>%0A<b>branch:-</b> <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0A<b>Under commit</b> <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0A<b>Using compiler:- </b> <code>Clang 5484270</code>%0A<b>Started on:- </b> <code>$(date)</code>%0A<b>Build Status:</b> #BETA"
}

# sudo apt-get update -y
# sudo apt-get install bc cpio build-essential zip curl libstdc++6 git wget python2 gcc clang libssl-dev rsync flex bison -y

function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build finished on $(date) | For <b>miatoll</b> | @mango_ci "
}

git clone --depth=1 --single-branch --recurse-submodules https://github.com/jamiehoszeyui/deoxy work
cd work 
git clone --depth=1 https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-5484270 -b 9.0 clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc32
git clone https://github.com/HenloLab/AnyKernel3.git -b curtana --depth=1 AnyKernel

KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
export ARCH=arm64
export KBUILD_BUILD_USER=mad
export KBUILD_BUILD_HOST=disney
start
make cust_defconfig O=out CC=clang+
make -j$(nproc --all) O=out CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump STRIP=llvm-strip
cd AnyKernel
cp ../out/arch/arm64/boot/Image.gz-dtb .
cp ../out/arch/arm64/boot/dtbo.img .
zip -r9 DeOxy-BETA-${TANGGAL}.zip *
cd ..
if [[ -f AnyKernel/Image.gz-dtb ]]; then 
    push
else
    finerr
fi 
