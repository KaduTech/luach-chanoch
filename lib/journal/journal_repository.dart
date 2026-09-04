import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class JournalEntry {
  const JournalEntry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.isPrayer,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isPrayer;

  Map<String, Object> toJson() => <String, Object>{
    'id': id,
    'title': title,
    'body': body,
    'createdAt': createdAt.toIso8601String(),
    'isPrayer': isPrayer,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> value) => JournalEntry(
    id: value['id'] as String,
    title: value['title'] as String,
    body: value['body'] as String,
    createdAt: DateTime.parse(value['createdAt'] as String),
    isPrayer: value['isPrayer'] as bool? ?? false,
  );
}

class JournalRepository {
  static const _entriesKey = 'journal_entries';

  Future<List<JournalEntry>> load() async {
    final store = await SharedPreferences.getInstance();
    final raw = store.getString(_entriesKey);
    if (raw == null) return <JournalEntry>[];
    final values = jsonDecode(raw) as List<dynamic>;
    final entries = values
        .map((value) => JournalEntry.fromJson(value as Map<String, dynamic>))
        .toList();
    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entries;
  }

  Future<void> save(List<JournalEntry> entries) async {
    final store = await SharedPreferences.getInstance();
    await store.setString(_entriesKey, jsonEncode(entries.map((entry) => entry.toJson()).toList()));
  }
}
