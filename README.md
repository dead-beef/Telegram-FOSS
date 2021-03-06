# Telegram-FOSS

[Telegram](https://telegram.org) is a messaging app with a focus on speed and security. It’s superfast, simple and free.

This is an unofficial, FOSS-friendly fork of [an unofficial, FOSS-friendly fork](https://github.com/Telegram-FOSS-Team/Telegram-FOSS) of the original [Telegram App for Android](https://github.com/DrKLO/Telegram).

## Changes

*Replacement of non-FOSS, untrustworthy or suspicious binaries or source code:*
- Do location sharing with OpenStreetMap(osmdroid) instead of Google Maps
- Use Twemoji emoji set instead of Apple's emoji
- Google Play Services GCM replaced with Telegram's push service
- Has to show a notification on Oreo+, ask Google
- **SECURITY:** Old BoringSSL prebuilts are replaced with the newest upstream source code built at compile time
- **SECURITY:** Old FFmpeg prebuilts are replaced with the newest upstream source code built at compile time
- **SECURITY:** Bundled libWebP is updated

*Removal of non-FOSS, untrustworthy or suspicious binaries or source code and their functionality:*
- Google Vision face detection and barcode scanning (Passport)
- Google Wallet and Android Pay integration
- Google Voice integration
- HockeyApp crash reporting and self-updates
- Google SMS retrieval. You have to type the code manually

*Other:*
- Allow to set a proxy before login
- Added the ability to parse locations from intents containing a `geo:<lat>,<lon>,<zoom>` string
- Force static map previews from Telegram
- Added the ability to export the database
- Hide messages from blocked users
- Added the ability to download chats

## Versioning

This repository contains tags to make tracking versions easier.

Versions are in form "v$UPSTREAM$RELEASE" where:

* $UPSTREAM is the public, visible version of upstream.
* $RELEASE is a letter ([a-z]) indicating minor releases between official versions (sometimes, upstream is updated without relating the changes to an specific version).

## API, Protocol documentation

Telegram API manuals: https://core.telegram.org/api

MTproto protocol manuals: https://core.telegram.org/mtproto

## Building

**NOTE: Building on Windows is, unfortunately, not supported.
Consider using a Linux VM or dual booting.**
![WindowsSupport](/tgfoss-build-under-win.gif?raw=true)

**Important:**

1. You need the Android NDK, Go(Golang) and [Ninja](https://ninja-build.org/) to build the apk.

2. Don't forget to include the submodules when you clone:
      - `git clone --recursive https://github.com/Telegram-FOSS-Team/Telegram-FOSS.git`

3. Define the variables:
   ```
   cat >vars.sh <<EOF
   export NINJA_PATH=[PATH_TO_NINJA]
   export JAVA_HOME=[PATH_TO_JAVA]
   export ANDROID_HOME=[PATH_TO_ANDROID_SDK]
   export ANDROID_BUILD_TOOLS=[PATH_TO_ANDROID_BUILD_TOOLS]
   export NDK=[PATH_TO_NDK]

   KEY=[PATH_TO_KEYSTORE]
   KEY_ALIAS=[KEY_ALIAS]
   KEY_PASSWORD=[KEYSTORE_PASSWORD]
   EOF
   ```

4. Build native FFmpeg and BoringSSL dependencies:
   ```
   ./build.sh -d
   ```

5. If you want to publish a modified version of Telegram:
      - You should get **your own API key** here: https://core.telegram.org/api/obtaining_api_id and create a file called `API_KEYS` in the source root directory.
        The contents should look like this:
        ```
        APP_ID = 12345
        APP_HASH = aaaaaaaabbbbbbccccccfffffff001122
        ```
      - Do not use the name Telegram and the standard logo (white paper plane in a blue circle) for your app — or make sure your users understand that it is unofficial
      - Take good care of your users' data and privacy
      - **Please remember to publish your code too in order to comply with the licenses**

The project can be built with Android Studio or from the command line:

`./build.sh`
