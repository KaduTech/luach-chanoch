import 'package:luach_chanoch/journal/journal_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('journal entries serialize without losing fields', () {
    final entry = JournalEntry(
      id: 'entry-1',
      title: 'A reflection',
      body: 'Remember this day.',
      createdAt: DateTime(2026, 3, 25),
      isPrayer: true,
    );

    final restored = JournalEntry.fromJson(entry.toJson());
    expect(restored.id, entry.id);
    expect(restored.title, entry.title);
    expect(restored.body, entry.body);
    expect(restored.createdAt, entry.createdAt);
    expect(restored.isPrayer, isTrue);
  });
}
