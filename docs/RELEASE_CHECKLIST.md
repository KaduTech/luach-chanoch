# Luach Chanoch Release Checklist

## Product and content

- [x] Public app name and a production launcher icon are in place: Luach Chanoch.
- [x] Confirm the epoch, AM chronology, seasonal days, and feast rules with the appointed ministry/content owner.
- [x] Review every observance description and calendar disclaimer for theological and editorial accuracy.
- [x] Receive the appointed content owner's approval for the seven-day reading/reflection plan.
- [x] Add a support email and public support site.

## Technical

- [x] Flutter Android and iOS platform projects are generated.
- [x] Run `flutter pub get` and `flutter test` (12 automated tests pass).
- [x] Run static analysis in the target release environment (`flutter analyze` is clean locally and in GitHub Actions).
- [x] Test conversion boundary cases and at least one full 364-day calendar table approved by the content owner.
- [ ] Test on physical iPhone and Android devices, including light/dark mode, offline launch, and large text accessibility.
- [x] Branded app icons, splash screen, Android package name, and iOS bundle identifier are set.
- [x] Set the final release version to `1.0.0+1` before store upload.
- [x] Android package name and iOS bundle identifier are set to `com.kadutech.luachchanoch`.
- [x] Add opt-in local Sabbath-reminder scheduling.
- [ ] Test notification permission denial, timezone changes, and reboot rescheduling on physical devices.

## Privacy and stores

- [x] Publish [PRIVACY_POLICY.md](PRIVACY_POLICY.md) at https://www.kadutech.com/luach-chanoch/privacy.
- [ ] Complete Apple App Privacy and Google Play Data Safety forms to reflect the final shipped dependencies.
- [ ] Create Apple Developer and Google Play Console accounts, app records, tax/banking information, and signing keys.
- [ ] Follow `docs/SIGNING.md` to create and secure Kadutech Android upload signing and Apple distribution signing.
- [ ] Upload release builds to TestFlight and Google Play internal testing.
- [ ] Complete closed/beta testing, fix issues, then submit for review.

## Explicit launch blockers

The following cannot be completed from this workspace: store account ownership, signing certificates/keys, and physical-device testing.
