import 'package:luach_chanoch/content/daily_content.dart';
import 'package:luach_chanoch/calendar/enoch_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reference observances are discoverable by month and day', () {
    expect(observanceFor(1, 14)?.name, 'Passover');
    expect(observanceFor(7, 10)?.name, 'Day of Atonement');
    expect(observanceFor(2, 14), isNull);
  });

  test('daily reading cycle contains a reading for each weekly position', () {
    expect(weeklyReadingCycle, hasLength(7));
    expect(weeklyReadingCycle.every((reading) => reading.reference.isNotEmpty), isTrue);
  });

  test('upcoming observances cross into the next AM year when necessary', () {
    final calendar = EnochCalendar(epoch: DateTime(2026, 3, 25), epochAmYear: 6029);
    final dates = upcomingObservances(calendar, DateTime(2027, 3, 24));

    expect(dates.first.observance.name, 'Passover');
    expect(dates.first.enochDate.amYear, 6030);
  });
}
