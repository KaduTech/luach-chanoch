# Luach Chanoch

Luach Chanoch is an offline 364-day Enoch calendar companion for Android and iOS, built from the supplied product discussion.

## Included app features

- Current Enoch date, AM year, weekday, Sabbath status, and season
- Bidirectional Gregorian/Enoch date converter
- A complete 364-day month grid with Sabbath, observance, and seasonal markers
- Configurable calendar epoch and AM year
- First-launch explanation of the chosen convention
- Persisted preferences and a starter daily reading cycle
- Private, offline prayer and reflection journal
- An in-app explanation of the chronology and calculation assumptions
- Dark mode, an upcoming-observance view, and opt-in local calendar reminders
- Branded Android and iOS launcher and splash assets

## Important calendar convention

This app deliberately uses an explicit, configurable epoch: **25 March 2026 = AM 6029, Month 1 Day 1**. Every Enoch year is exactly 364 days (four 91-day quarters). The weekday is calculated from the same epoch, with Day 1 as Wednesday.

The attached conversation contains conflicting examples for the July 2026 month boundary. An epoch-based rule is used instead, so every date is reproducible and users can select their community's start date in Settings.

## Run

Install Flutter, then from this directory:

```sh
flutter pub get
flutter run
```

On macOS, select an iOS simulator or connected iPhone; on Windows, run against an Android emulator or device. The app does not use Firebase, sign-in, tracking, or a network service.

## Release materials

- `docs/PRIVACY_POLICY.md` — policy text to publish before store submission
- `docs/STORE_LISTING.md` — store copy, keywords, category, and screenshot plan
- `docs/RELEASE_CHECKLIST.md` — technical, content, privacy, and store gates

Calendar reminders are optional, local-device notifications. Users are asked for permission only after enabling them in Settings; Sabbaths are scheduled for 6 PM and approved feast observances for 9 AM. The approved festival schedule is included in the app's default calendar convention.
