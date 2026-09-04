# Luach Chanoch signing setup

## Android — Google Play upload key

1. In a secure Kadutech-controlled location, generate an upload key:

   ```sh
   keytool -genkey -v -keystore luach-chanoch-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias luachchanoch
   ```

2. Store the keystore in an encrypted Kadutech-controlled password manager or secure vault. Back it up according to the organization’s key-management policy.
3. Copy `android/key.properties.example` to `android/key.properties` and enter the real passwords and keystore path. This file is ignored by Git.
4. Build an upload bundle with `flutter build appbundle --release`.
5. Enroll in Google Play App Signing and keep the upload key separate from any Play-generated app-signing key.

The Android release task intentionally fails when `android/key.properties` is absent. This prevents a release artifact from being accidentally signed with a debug key.

## iOS — Apple distribution signing

On a Mac with Xcode, open `ios/Runner.xcworkspace`, select the Runner target, select the Kadutech Apple Developer team, and enable automatic signing. Create the App Store Connect record using:

`com.kadutech.luachchanoch`

Archive and upload through Xcode or use `flutter build ipa --release` after the signing team and provisioning profile are configured.

## Never commit

- `android/key.properties`
- Android `.jks` / `.keystore` files
- Apple certificates, provisioning profiles, API keys, or private keys
