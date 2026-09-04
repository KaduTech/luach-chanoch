# Luach Chanoch launch readiness

## Complete in the app

- Android and iOS Flutter projects share one offline application.
- The app is named **Luach Chanoch** and uses `com.kadutech.luachchanoch` on both platforms.
- Today, conversion, year/month views, a seven-day reflection cycle, approved feast observances, onboarding, dark mode, and local private journal features are implemented.
- Users can set an epoch and AM year, so the calculation convention is visible and adjustable.
- Opt-in local calendar reminders schedule Sabbaths on-device at 6:00 PM and feast observances at 9:00 AM. No account, analytics, advertising, or remote data service is included.
- Branded launcher and splash assets are included for both Android and iOS.
- The iOS target includes an app privacy manifest that declares no tracking or collected data; bundled plugins retain their own manifests.
- The automated Flutter suite contains 12 tests and passes, including calendar reminder timing and limits.
- The private-repository CI workflow has passed static analysis, tests, an unsigned Android bundle, and an unsigned iOS build for version `1.0.0+1`.

## Required before a public store submission

1. The epoch, AM chronology, feast rules, and existing observance descriptions have been approved by the appointed content owner. Maintain that approval for future content changes.
2. The appointed content owner must either approve a final daily-reading/reflection plan or direct Kadutech to remove the reading card from version 1.0. The existing seven-day prompts are intentionally not represented as final ministry content.
3. Kadutech must provide an Android upload keystore and Apple distribution signing through its developer accounts. Follow `docs/SIGNING.md`; never commit keys.
4. The privacy policy and support pages are published at `https://www.kadutech.com/luach-chanoch/privacy` and `https://www.kadutech.com/luach-chanoch/support`; enter these URLs in the store records.
5. Create the Google Play Console and Apple Developer app records; complete their Data Safety/App Privacy questionnaires. The shipped app uses only local device storage and optional local notifications.
6. Build and test an Android App Bundle on a physical Android device and an iOS archive/TestFlight build on a Mac with Xcode. Check notification permission denial, device timezone changes, reboot rescheduling, offline launch, dark mode, and large-text accessibility.
7. Upload version `1.0.0+1` to internal/TestFlight testing, then submit the approved build for review.

## Build environment status

Flutter 3.47.2 is available in this workspace. The workstation does not have an Android SDK or Xcode, so Android/iOS artifacts cannot be created or signed here. This is an environment and account gate, not a remaining implementation task.

## Source-control rule

When the Kadutech GitHub connection is available, use a private development repository for all continuing work. Do not push code to the public repository unless Kadutech explicitly directs that update.
