import 'package:shared_preferences/shared_preferences.dart';

class CalendarPreferences {
  const CalendarPreferences({
    required this.epoch,
    required this.epochAmYear,
  });

  final DateTime epoch;
  final int epochAmYear;

  static const _epochKey = 'calendar_epoch';
  static const _yearKey = 'calendar_epoch_am_year';
  static const _onboardingKey = 'onboarding_completed';
  static const _darkModeKey = 'dark_mode';
  static const _sabbathRemindersKey = 'sabbath_reminders_enabled';

  static Future<CalendarPreferences> load() async {
    final store = await SharedPreferences.getInstance();
    final savedEpoch = store.getString(_epochKey);
    return CalendarPreferences(
      epoch: savedEpoch == null ? DateTime(2026, 3, 25) : DateTime.parse(savedEpoch),
      epochAmYear: store.getInt(_yearKey) ?? 6029,
    );
  }

  Future<void> save() async {
    final store = await SharedPreferences.getInstance();
    await store.setString(_epochKey, epoch.toIso8601String());
    await store.setInt(_yearKey, epochAmYear);
  }

  static Future<bool> hasCompletedOnboarding() async {
    final store = await SharedPreferences.getInstance();
    return store.getBool(_onboardingKey) ?? false;
  }

  static Future<void> completeOnboarding() async {
    final store = await SharedPreferences.getInstance();
    await store.setBool(_onboardingKey, true);
  }

  static Future<bool> usesDarkMode() async {
    final store = await SharedPreferences.getInstance();
    return store.getBool(_darkModeKey) ?? false;
  }

  static Future<void> saveDarkMode(bool enabled) async {
    final store = await SharedPreferences.getInstance();
    await store.setBool(_darkModeKey, enabled);
  }

  static Future<bool> hasSabbathRemindersEnabled() async {
    final store = await SharedPreferences.getInstance();
    return store.getBool(_sabbathRemindersKey) ?? false;
  }

  static Future<void> saveSabbathRemindersEnabled(bool enabled) async {
    final store = await SharedPreferences.getInstance();
    await store.setBool(_sabbathRemindersKey, enabled);
  }
}
