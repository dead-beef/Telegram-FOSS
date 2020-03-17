#!/bin/bash

usage() {
    cat >&2 <<EOF
usage: $0 [-a|-d|-j]

optional arguments:
  -h    show this help message and exit
  -j    build only apk (default)
  -d    build only native dependencies
  -a    build native dependencies and apk
EOF
    exit 1
}

cmd() {
    echo "$@" >&2
    "$@" || exit 1
}

build_deps=
build_apk=1

while getopts 'hadj' OPT; do
    case "$OPT" in
        a)
            build_deps=1
            build_apk=1
            ;;
        d)
            build_deps=1
            build_apk=
            ;;
        j)
            build_deps=
            build_apk=1
            ;;
        h) usage ;;
        \?) exit 1 ;;
    esac
done

cmd cd "$(dirname "${BASH_SOURCE[0]}")"

if [[ -e vars.sh ]]; then
    source vars.sh
fi

if [[ -z $JAVA_HOME ]]; then
    dir="${HOME}/java/"
    if [[ -d $dir ]]; then
        export JAVA_HOME="$dir"
    else
        echo "Error: JAVA_HOME is not set and ${dir} does not exist" >&2
        exit 1
    fi
fi

if [[ -z $ANDROID_HOME ]]; then
    dir="${HOME}/Android/Sdk"
    if [[ -d $dir ]]; then
        export ANDROID_HOME="$dir"
    else
        echo "Error: ANDROID_HOME is not set and ${dir} does not exist" >&2
        exit 1
    fi
fi

if [[ -z $ANDROID_BUILD_TOOLS ]]; then
    dir="$(ls "${ANDROID_HOME}/build-tools" | head -n 1)"
    if [[ -n $dir ]]; then
        ANDROID_BUILD_TOOLS="${ANDROID_HOME}/build-tools/${dir}"
    else
        echo "Error: ANDROID_BUILD_TOOLS is not set and ${ANDROID_HOME}/build-tools/<version> does not exist" >&2
        exit 1
    fi
fi

if [[ -z $NDK ]]; then
    dir="$(ls "${ANDROID_HOME}/ndk" | head -n 1)"
    if [[ -n $dir ]]; then
        export NDK="${ANDROID_HOME}/ndk/${dir}"
    else
        echo "Error: NDK is not set and ${ANDROID_HOME}/ndk/<version> does not exist" >&2
        exit 1
    fi
fi

if [[ -z $NINJA_PATH ]]; then
    if [[ -f /usr/bin/ninja ]]; then
        export NINJA_PATH=/usr/bin/ninja
    else
        echo 'Error: NINJA_PATH is not set and /usr/bin/ninja does not exist' >&2
        exit 1
    fi
fi

if [[ -z $KEY ]]; then
    KEY='release-key.keystore'
    KEY_ALIAS='key-alias'
    KEY_PASSWORD='release'
fi


BUILD_APK='TMessagesProj/build/outputs/apk/afat/release/TMessagesProj-afat-release-unsigned.apk'
UNSIGNED_APK='build/release-unsigned.apk'
SIGNED_APK='build/release-signed.apk'

if [[ -n $build_deps ]]; then
    cmd pushd TMessagesProj/jni

    echo 'Cleaning native dependencies...' >&2
    cmd pushd boringssl
    rm -rfv build
    cmd git checkout -- .
    cmd popd
    cmd pushd ffmpeg
    cmd git checkout -- .
    cmd popd

    echo 'Building native dependencies...' >&2
    cmd ./build_ffmpeg_clang.sh
    cmd ./patch_ffmpeg.sh
    cmd ./patch_boringssl.sh
    cmd ./build_boringssl.sh

    cmd popd
fi

if [[ -n $build_apk ]]; then
    echo 'Cleaning APK...' >&2
    rm -fv "$BUILD_APK" "$UNSIGNED_APK" "$SIGNED_APK"

    echo 'Building APK...' >&2
    cmd ./gradlew assembleAfatRelease

    if [[ ! -e $KEY ]]; then
        echo 'Generating key...' >&2
        cmd keytool -genkey -v -keystore "$KEY" -alias "$KEY_ALIAS" -storepass "$KEY_PASSWORD" -keyalg RSA -keysize 2048 -validity 1000000
    fi

    echo 'Signing APK...' >&2
    cmd cp "$BUILD_APK" "$UNSIGNED_APK"
    cmd jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore "$KEY" "$UNSIGNED_APK" "$KEY_ALIAS" -storepass "$KEY_PASSWORD"
    cmd "${ANDROID_BUILD_TOOLS}/zipalign" -v 4 "$UNSIGNED_APK" "$SIGNED_APK"
    cmd "${ANDROID_BUILD_TOOLS}/apksigner" verify "$SIGNED_APK"
fi
