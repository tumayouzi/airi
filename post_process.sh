#!/bin/bash

export LANG=C
export LC_ALL=C.UTF-8
export ALLOW_MISSING_DEPENDENCIES=true
export SOONG_ALLOW_MISSING_DEPENDENCIES=true

cd ../${BUILD_DIR}

# get setup status
source build/envsetup.sh
breakfast ${DEVICE}

# arg check
if [ $# -lt 1 ]; then
	echo "The specified argument is $#" 1>&2
	echo "Usage: ${CMDNAME} [build status(true|false)]" 1>&2
	exit 1
fi

build_status=$1
shift 1


# set build type
if [ "${BUILD_TYPE}" = "UNOFFICIAL" ]; then
    : # NOP
else
    export FLOKO_BUILD_TYPE=${BUILD_TYPE}
fi

# set log file name
filename="${BUILD_TIMESTAMP}_${BUILD_DIR}_${DEVICE}.log"

# get build information
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
# other 
	source=${BUILD_DIR}
	short="${source}"
	zipname="*"
	newzipname="${zipname}"
fi


# move product
if [ "${build_status}" = "true" ]; then
    # log file
    mv -v ${LOG_DIR}/${filename} ${LOG_DIR}/success/
    # ROM zip
    cp out/target/product/${DEVICE}/${zipname}.zip ${ROM_DIR}/${DEVICE}/${newzipname}.zip
    # ROM MD5SUM
    cp out/target/product/${DEVICE}/${zipname}.zip.md5sum ${ROM_DIR}/${DEVICE}/${newzipname}.zip.md5sum
    # change log
    cp out/target/product/${DEVICE}/changelog_${DEVICE}.txt ${ROM_DIR}/${DEVICE}/changelog/changelog_${newzipname}.txt
elif [ "${build_status}" = "false" ]; then
    # log file
    mv -v ${LOG_DIR}/${filename} ${LOG_DIR}/fail/
fi

# calculating build time
build_start_unixtime=`date -d "${START_BUILD_DATETIME}" +%s`
build_end_unixtime=`date +%s`
build_sec=`expr ${build_end_unixtime} - ${build_start_unixtime}`
((sec=${build_sec}%60, min=(${build_sec}%3600)/60, hrs=${build_sec}/3600))
build_hms=$(printf "%d:%02d:%02d" $hrs $min $sec)

# post to mastodon/pushbullet
if [ "${build_status}" = "true" ]; then
    # make pushbullet massage
    pbtitle=$(echo -e "BUILD SUCCESS: ${surce} for ${DEVICE} (${BUILD_TYPE})")
    pbbody=$(echo -e "Filename:${newzipname} Time:${build_hms} ${BUILD_URL}")
    
    # toot to mastodon
    if [ "${TOOT}" = "true" ]; then
        echo "📣${DEVICE} 向け ${source} の ${BUILD_TYPE} のビルドに成功しました🎉😎🥂 ビルド時間: ${build_hms} ${BUILD_URL} ${TOOT_TAG}" | toot
    fi

elif [ "${build_status}" = "false" ]; then
    # make pushbullet massage
    pbtitle=$(echo -e "BUILD FAIL: ${surce} for ${DEVICE} (${BUILD_TYPE})")
    pbbody=$(echo -e "Time:${build_hms} ${BUILD_URL}")

    # toot to mastodon
    if [ "${TOOT}" = "true" ]; then
        echo "📣${DEVICE} 向け ${source} の ${BUILD_TYPE} のビルドに失敗しました :very_sad: ビルド時間: ${build_hms} ${BUILD_URL} ${TOOT_TAG}" | toot --visibility unlisted
    fi
fi

curl -u ${PUSHBULLET_TOKEN}: -X POST \
    https://api.pushbullet.com/v2/pushes \
  	--header "Content-Type: application/json" \
  	--data-binary "{\"type\": \"note\", \"title\": \"${pbtitle}\", \"body\": \"${pbbody}\"}"
