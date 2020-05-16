#!/bin/bash

export LANG=C
export LC_ALL=C.UTF-8
export ALLOW_MISSING_DEPENDENCIES=true
export SOONG_ALLOW_MISSING_DEPENDENCIES=true

# Change dir
cd ../${BUILD_DIR}

# get setup status
source build/envsetup.sh
breakfast ${DEVICE}

# Get build Information
if [ ${BUILD_DIR} = lineage ]; then
	vernum="$(get_build_var PRODUCT_VERSION_MAJOR).$(get_build_var PRODUCT_VERSION_MINOR)"
	source="LineageOS ${vernum}"

elif [ ${BUILD_DIR} = floko ]; then
    vernum="$(get_build_var FLOKO_VERSION)"
    source="floko-v${vernum}"
else
# Other 
	source=${BUILD_DIR}
fi

# set relase status
if [ "${BUILD_TYPE}" = "UNOFFICIAL" ]; then
    : # NOP
else
    export FLOKO_BUILD_TYPE=${BUILD_TYPE}
fi

# make dir
mkdir -p ${LOG_DIR}/success ${LOG_DIR}/fail ${ROM_DIR}/${DEVICE}/changelog

# toot to mastodon
if [ "${TOOT}" = "true" ]; then
    echo "📣${DEVICE} 向け ${source} の ${BUILD_TYPE} ビルドを開始します :loading: ${BUILD_URL} ${TOOT_TAG}" | toot --visibility unlisted
fi
