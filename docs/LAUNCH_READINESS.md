# Luach Chanoch launch readiness

## Complete in the app

- Android and iOS Flutter projects share one offline application.
- The app is named **Luach Chanoch** and uses `com.kadutech.luachchanoch` on both platforms.
- Today, conversion, year/month views, daily readings, reference observances, onboarding, dark mode, and local private journal features are implemented.
- Users can set an epoch and AM year, so the calculation convention is visible and adjustable.
- Opt-in local calendar reminders schedule Sabbaths on-device at 6:00 PM and reference observances at 9:00 AM. No account, analytics, advertising, or remote data service is included.
- Branded launcher and splash assets are included for both Android and iOS.
- The iOS target includes an app privacy manifest that declares no tracking or collected data; bundled plugins retain their own manifests.
- The automated Flutter suite contains 12 tests and passes, including calendar reminder timing and limits.
- A private-repository CI workflow validates static analysis, tests, an unsigned Android bundle, and an unsigned iOS build when the source is pushed to GitHub.

## Required before a public store submission

1. The appointed content owner must approve the epoch, AM chronology, feast rules, and daily reading material. The app labels these as community-dependent until that approval is received.
2. Kadutech must provide an Android upload keystore and Apple distribution signing through its developer accounts. Follow `docs/SIGNING.md`; never commit keys.
3. Publish `docs/PRIVACY_POLICY.md` at a Kadutech-controlled HTTPS URL, set its effective date and support email, and put those URLs in the store records.
4. Create the Google Play Console and Apple Developer app records; complete their Data Safety/App Privacy questionnaires. The shipped app uses only local device storage and optional local notifications.
5. Build and test an Android App Bundle on a physical Android device and an iOS archive/TestFlight build on a Mac with Xcode. Check notification permission denial, device timezone changes, reboot rescheduling, offline launch, dark mode, and large-text accessibility.
6. Set the final version number in `pubspec.yaml`, upload to internal/TestFlight testing, then submit the approved build for review.

## Build environment status

Flutter 3.47.2 is available in this workspace. The workstation does not have an Android SDK or Xcode, so Android/iOS artifacts cannot be created or signed here. This is an environment and account gate, not a remaining implementation task.

## Source-control rule

When the Kadutech GitHub connection is available, use a private development repository for all continuing work. Do not push code to the public repository unless Kadutech explicitly directs that update.
