# Luach Chanoch — MVP requirements

## Product purpose

Luach Chanoch is a daily companion for people who follow a 364-day Enoch/Jubilees-style calendar. It makes the selected calendar convention visible, computes a daily date offline, and provides a clear path to future readings and reminders.

## Chosen MVP convention

| Setting | Default |
| --- | --- |
| Calendar length | 364 days / 52 weeks |
| Month pattern | 30, 30, 31 repeated four times |
| Epoch | 25 March 2026 = Month 1, Day 1 |
| Epoch weekday | Wednesday |
| Year count | AM 6029 at the epoch |

This is a user-editable convention, not a claim that all Enoch-calendar communities agree on it.

## MVP screens

1. **Today**: AM year, month/day, weekday, season, Sabbath status, daily-reading placeholder.
2. **Convert**: convert both Gregorian-to-Enoch and Enoch-to-Gregorian dates.
3. **Year**: browse all twelve months, their lengths, Gregorian start dates, and a day-grid that marks Sabbaths, seasonal days, and approved feast observances.
4. **Settings**: disclose and change the calendar epoch and AM year.
5. **Onboarding**: explain the chronology, epoch, and community-variation disclaimer before users first enter the calendar.
6. **Journal**: create and delete private prayer or reflection entries stored locally on the device.

The app saves the selected convention locally on the device. It does not require an account or connection to calculate dates.

## Release 1.1

- Persist settings using `shared_preferences`.
- Local Sabbath and feast-day notifications.
- Curated daily Scripture plan and offline content bundle.
- Accessibility labels, dark mode, localization.

## Service-backed phase

Firebase Authentication, Firestore content, Cloud Messaging, and a web admin portal should be introduced only when publishing shared devotionals or remote notifications. The calendar calculation itself remains fully offline.

## Content note

The app includes an approved seven-day reflection cycle and the approved Luach Chanoch feast schedule. The default epoch remains visible and user-adjustable so communities using a different calculation can choose their own convention.

## Release checklist

- Replace provisional name, icon, colors, and legal/support links.
- Maintain the approved feast schedule and readings with the appointed content owner.
- Test date rules against the approved chronology and a published reference table.
- Add Privacy Policy and App Store privacy disclosures.
- Run iOS and Android device tests, including notifications and offline mode.
