import 'package:luach_chanoch/calendar/enoch_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final calendar = EnochCalendar(epoch: DateTime(2026, 3, 25), epochAmYear: 6029);

  test('epoch is the first day of AM 6029', () {
    final date = calendar.fromGregorian(DateTime(2026, 3, 25));
    expect(date.amYear, 6029);
    expect(date.month, 1);
    expect(date.day, 1);
    expect(date.weekday, 'Wednesday');
  });

  test('a quarter has 91 days', () {
    final date = calendar.fromGregorian(DateTime(2026, 6, 23));
    expect(date.month, 3);
    expect(date.day, 31);
    expect(date.dayOfYear, 91);
  });

  test('the next fixed year starts after 364 days', () {
    final date = calendar.fromGregorian(DateTime(2027, 3, 24));
    expect(date.amYear, 6030);
    expect(date.month, 1);
    expect(date.day, 1);
  });

  test('a date before the epoch belongs to the preceding AM year', () {
    final date = calendar.fromGregorian(DateTime(2026, 3, 24));
    expect(date.amYear, 6028);
    expect(date.month, 12);
    expect(date.day, 31);
  });

  test('the supplied July example resolves consistently from the epoch', () {
    final date = calendar.fromGregorian(DateTime(2026, 7, 3));
    expect(date.month, 4);
    expect(date.day, 10);
  });
}
