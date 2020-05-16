#!/bin/bash

# for build arg
export LANG=C
export LC_ALL=C.UTF-8
export ALLOW_MISSING_DEPENDENCIES=true
export SOONG_ALLOW_MISSING_DEPENDENCIES=true
export CCACHE_DIR=${CCACHE_DIR}
export USE_CCACHE=1

#ccache
#CCACHE_CAP="50G"

# record the current dir.
workdir=`pwd`

# set log file name
filename="${BUILD_TIMESTAMP}_${BUILD_DIR}_${DEVICE}.log"

# move build dir
cd ../${BUILD_DIR}

# make clean
if [ "${MAKE_CLEAN}" = "true" ]; then
	make clean
	echo -e "\n"
fi

# set ccache
ccache -M ${CCACHE_CAP}

# if offical?
# Must be before breakfast
if [ "${BUILD_TYPE}" = "UNOFFICIAL" ]; then
    : # NOP
else
    export FLOKO_BUILD_TYPE=${BUILD_TYPE}
fi

# build preparation
source build/envsetup.sh
breakfast ${DEVICE}

# Build Information Settings
if [ ${BUILD_DIR} = lineage ]; then
	vernum="$(get_build_var PRODUCT_VERSION_MAJOR).$(get_build_var PRODUCT_VERSION_MINOR)"
	source="LineageOS ${vernum}"
	short="${source}"
	zipname="lineage-$(get_build_var LINEAGE_VERSION)"
	newzipname="lineage-$(get_build_var PRODUCT_VERSION_MAJOR).$(get_build_var PRODUCT_VERSION_MINOR)-${BUILD_TIMESTAMP}-${get_build_var LINEAGE_BUILDTYPE}-$(device)"

elif [ ${BUILD_DIR} = floko ]; then
        vernum="$(get_build_var FLOKO_VERSION)"
        source="floko-v${vernum}"
        short="${source}"
        zipname="$(get_build_var LINEAGE_VERSION)"
        newzipname="Floko-v${vernum}-${DEVICE}-${BUILD_TIMESTAMP}-$(get_build_var FLOKO_BUILD_TYPE)"
else
# Other 
	source=${BUILD_DIR}
	short="${source}"
	zipname="*"
	newzipname="${zipname}"
fi

# Start build
mka bacon 2>&1 | tee "${LOG_DIR}/${filename}"

if [ $(echo ${PIPESTATUS[0]}) -eq 0 ]; then
	ans=0
	statusdir="success"
else
	ans=1
	statusdir="fail"
fi

# KILL JACK-SERVER FOR SURE
prebuilts/sdk/tools/jack-admin kill-server

if [ ${ans} -eq 0 ]; then
	exit 0
else
	exit 1
fi
