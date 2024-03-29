#!/bin/bash

# kernel build script (kanged from somewhere i forgot)

#!/bin/bash


DEVICE=$1
STATUS=ALPHA 
ZIP="AnyKernel/*.zip"

if [[ $1 = curtana ]]; then 
    SAUCE="https://github.com/JamieHoSzeYui/mango414"
    DEFCONFIG=cust_defconfig
    KNAME=MangoWIP
    AKBRANCH=curtana 
    ZIPNAME="mango0414-curtana-OP"
elif [[ $1 = curtana-r ]]; then 
    SAUCE="https://github.com/JamieHoSzeYui/deoxy"
    DEFCONFIG=cust_defconfig
    KNAME=DeOxy
    AKBRANCH=curtana 
elif [[ $1 = lancelot ]]; then 
    SAUCE=$supersexyrepo
    DEFCONFIG=lancelot_defconfig 
    AKBRANCH=lancelot 
    KNAME=Skyfall
    ZIPNAME="Skyfall-lancelot-BrokenDreams-BETA"
elif [[ $1 = merlin ]]; then 
    SAUCE=https://github.com/JamieHoSzeYui/dream
    DEFCONFIG=merlin_defconfig 
    AKBRANCH=lancelot 
    KNAME=Dream
    ZIPNAME="Dream-merlin-JustTheTwoOfUs-BETA"
elif [[ $1 = shiva ]]; then 
    SAUCE=https://github.com/JamieHoSzeYui/dream
    DEFCONFIG=shiva_defconfig 
    AKBRANCH=lancelot 
    KNAME=Dream
    ZIPNAME="Dream-shiva-JustTheTwoOfUs-BETA"
elif [[ $1 = lava ]]; then 
    SAUCE="-b ten-micode https://github.com/JamieHoSzeYui/dream"
    DEFCONFIG=lava_defconfig
    AKBRANCH=lancelot
    KNAME=Dream
    ZIPNAME="Dream-lava-TwentySeven-BETA"
elif [[ $1 = lava-vdso ]]; then 
    SAUCE="-b ten-vdso https://github.com/JamieHoSzeYui/dream"
    DEFCONFIG=lava_defconfig
    AKBRANCH=lancelot
    KNAME="Dream but VDSO"
    ZIPNAME="Dream-vDSO-lava-TwentySeven-BETA"
elif [[ $1 = star ]]; then 
    SAUCE="https://github.com/LineageOS/android_kernel_samsung_universal9810"
    DEFCONFIG=exynos9810-star2lte_defconfig
    AKBRANCH=lancelot
    KNAME="hal3storm"
    ZIPNAME="hal3storm-star2lte-BETA"
elif [[ $1 = blueline ]]; then 
    SAUCE="https://github.com/JamieHoSzeYui/brutalstar"
    DEFCONFIG=blueline_defconfig
    AKBRANCH=blueline
    KNAME="Brutalstar"
    ZIPNAME="brutalstar-blueline-BETA"
elif [[ $1 = op7125 ]]; then 
    SAUCE=$deoxy
    DEFCONFIG=cust_defconfig
    AKBRANCH=curtana
    KNAME="sm7125"
    ZIPNAME="op8150-ported-ALPHA"
elif [[ $1 = cheems ]]; then 
    SAUCE=https://github.com/JamieHoSzeYui/mango409
    DEFCONFIG=mango_defconfig
    AKBRANCH=cheemsburger
    KNAME="Mango"
    ZIPNAME="mango409-cheeseburger-BETA"
else 
    echo "What the fuck ???"
    exit 
fi

# Setup
echo "Setting up.."
apt-get -y update 
apt-get install bc cpio build-essential zip curl libstdc++6 git wget python2 gcc lz4 clang libssl-dev rsync flex bison unzip -y
git config --global user.name "JamieHoSzeYui"
git config --global user.email "wileylau@gmail.com"
git config --global color.ui false
update-alternatives --install /usr/bin/python python /usr/bin/python2.7 1 #Python2 supremacy
cp wahoo-kernel-tools/bin/* /bin/
cp wahoo-kernel-tools/lib64/* /lib64/
python -V 

echo "Cloning dependencies"
git clone --depth=1 --single-branch $SAUCE build 

cd build 
git clone --depth=1 https://github.com/crdroidandroid/android_prebuilts_clang_host_linux-x86_clang-5484270 -b 9.0 clang
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 gcc
git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 gcc32
git clone https://github.com/HenloLab/AnyKernel3.git -b $AKBRANCH --depth=1 AnyKernel

echo "Done"
KERNEL_DIR=$(pwd)
IMAGE="${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb"
TANGGAL=$(date +"%Y%m%d-%H")
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
PATH="${KERNEL_DIR}/clang/bin:${KERNEL_DIR}/gcc/bin:${KERNEL_DIR}/gcc32/bin:${PATH}"
export KBUILD_COMPILER_STRING="$(${KERNEL_DIR}/clang/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g')"
export ARCH=arm64
export KBUILD_BUILD_USER=mad
export KBUILD_BUILD_HOST=disney
export LD_LIBRARY_PATH="${KERNEL_DIR}/clang/lib64/:$LD_LIBRARY_PATH"

make O=out ARCH=arm64 $DEFCONFIG

# Compile plox
compile() {
    make -j60 O=out \
                    ARCH=arm64 \
                    CC=clang \
                    CLANG_TRIPLE=aarch64-linux-gnu- \
                    CROSS_COMPILE=aarch64-linux-android- \
                    CROSS_COMPILE_ARM32=arm-linux-androideabi-
}

module() {
[ -d "modules" ] && rm -rf modules || mkdir -p modules

compile \
INSTALL_MOD_PATH=../modules \
INSTALL_MOD_STRIP=1 \
modules_install
}

ls out/arch/arm64/boot 

ls AnyKernel/

# Zipping
zipping() {
    cd AnyKernel || exit 1
    cp ../out/arch/arm64/boot/Image*-dtb .
    zip -r9 $ZIPNAME-${TANGGAL}.zip *
    cd ..
}

function start() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>• $KNAME •</b>%0ABuild started on <code>Drone CI</code>%0A <b>For device</b> <i>$DEVICE</i>%0A<b>branch:-</b> <code>$(git rev-parse --abbrev-ref HEAD)</code>(master)%0A<b>Under commit</b> <code>$(git log --pretty=format:'"%h : %s"' -1)</code>%0A<b>Using compiler:- </b> <code>Clang 5484270</code>%0A<b>Started on:- </b> <code>$(date)</code>%0A<b>Build Status:</b> #$STATUS"
}
# Push kernel to channel

function push() {
    cd AnyKernel
    ZIP=$(echo *.zip)
    curl -F document=@$ZIP "https://api.telegram.org/bot$token/sendDocument" \
        -F chat_id="$chat_id" \
        -F "disable_web_page_preview=true" \
        -F "parse_mode=html" \
        -F caption="Build finished on $(date) | For <b>$DEVICE</b> | @mango_ci "
}
# Fin Error

function finerr() {
    curl -s -X POST "https://api.telegram.org/bot$token/sendMessage" \
        -d chat_id="$chat_id" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=markdown" \
        -d text="Build throw an error(s)"
    exit 1
}

start
compile
module
zipping
if [[ $(ls AnyKernel/ | grep Image) ]]; then 
    push
else
    finerr
fi 
exit 
