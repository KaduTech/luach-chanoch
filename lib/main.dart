import 'dart:async';

import 'package:flutter/material.dart';
import 'calendar/enoch_calendar.dart';
import 'calendar/calendar_preferences.dart';
import 'content/daily_content.dart';
import 'journal/journal_repository.dart';
import 'notifications/sabbath_reminder_service.dart';

void main() => runApp(const EnochDayApp());

class EnochDayApp extends StatefulWidget {
  const EnochDayApp({super.key});
  @override
  State<EnochDayApp> createState() => _EnochDayAppState();
}

class _EnochDayAppState extends State<EnochDayApp> {
  late DateTime _epoch;
  late int _amYear;
  var _isLoading = true;
  var _hasCompletedOnboarding = false;
  var _darkMode = false;
  var _sabbathReminders = false;
  int _tab = 0;

  EnochCalendar get _calendar =>
      EnochCalendar(epoch: _epoch, epochAmYear: _amYear);

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final preferences = await CalendarPreferences.load();
    final completedOnboarding =
        await CalendarPreferences.hasCompletedOnboarding();
    final darkMode = await CalendarPreferences.usesDarkMode();
    final sabbathReminders =
        await CalendarPreferences.hasSabbathRemindersEnabled();
    if (!mounted) return;
    setState(() {
      _epoch = preferences.epoch;
      _amYear = preferences.epochAmYear;
      _hasCompletedOnboarding = completedOnboarding;
      _darkMode = darkMode;
      _sabbathReminders = sabbathReminders;
      _isLoading = false;
    });
    if (sabbathReminders) {
      await SabbathReminderService.instance.reschedule(_calendar);
    }
  }

  void _updateConvention(DateTime epoch, int amYear) {
    setState(() {
      _epoch = epoch;
      _amYear = amYear;
    });
    unawaited(CalendarPreferences(epoch: epoch, epochAmYear: amYear).save());
    if (_sabbathReminders) {
      unawaited(SabbathReminderService.instance.reschedule(_calendar));
    }
  }

  void _completeOnboarding() {
    setState(() => _hasCompletedOnboarding = true);
    unawaited(CalendarPreferences.completeOnboarding());
  }

  void _setDarkMode(bool enabled) {
    setState(() => _darkMode = enabled);
    unawaited(CalendarPreferences.saveDarkMode(enabled));
  }

  Future<void> _setSabbathReminders(bool enabled) async {
    final active = enabled
        ? await SabbathReminderService.instance.enable(_calendar)
        : await SabbathReminderService.instance.disable().then((_) => false);
    if (!mounted) return;
    setState(() => _sabbathReminders = active);
    await CalendarPreferences.saveSabbathRemindersEnabled(active);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Luach Chanoch',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff355c42)),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xff8ecf9e), brightness: Brightness.dark),
          useMaterial3: true,
        ),
        themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
        home: _isLoading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : !_hasCompletedOnboarding
                ? OnboardingPage(onComplete: _completeOnboarding)
                : Scaffold(
                    body: SafeArea(
                        child: IndexedStack(index: _tab, children: <Widget>[
                      HomePage(calendar: _calendar),
                      ConvertPage(calendar: _calendar),
                      YearPage(calendar: _calendar),
                      const JournalPage(),
                      SettingsPage(
                        epoch: _epoch,
                        amYear: _amYear,
                        onChanged: _updateConvention,
                        darkMode: _darkMode,
                        onDarkModeChanged: _setDarkMode,
                        sabbathReminders: _sabbathReminders,
                        onSabbathRemindersChanged: _setSabbathReminders,
                      ),
                    ])),
                    bottomNavigationBar: NavigationBar(
                      selectedIndex: _tab,
                      onDestinationSelected: (value) =>
                          setState(() => _tab = value),
                      destinations: const <NavigationDestination>[
                        NavigationDestination(
                            icon: Icon(Icons.today_outlined),
                            selectedIcon: Icon(Icons.today),
                            label: 'Today'),
                        NavigationDestination(
                            icon: Icon(Icons.swap_horiz), label: 'Convert'),
                        NavigationDestination(
                            icon: Icon(Icons.calendar_month_outlined),
                            label: 'Year'),
                        NavigationDestination(
                            icon: Icon(Icons.edit_note_outlined),
                            selectedIcon: Icon(Icons.edit_note),
                            label: 'Journal'),
                        NavigationDestination(
                            icon: Icon(Icons.tune), label: 'Settings'),
                      ],
                    ),
                  ),
      );
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.onComplete});
  final VoidCallback onComplete;
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  var _page = 0;
  final _pages = const <_OnboardingContent>[
    _OnboardingContent(
        Icons.calendar_today_outlined,
        'Welcome to Luach Chanoch',
        'Luach Chanoch is a daily companion for a fixed 364-day Enoch calendar. Your date calculation works even when you are offline.'),
    _OnboardingContent(Icons.rule_outlined, 'Your convention is visible',
        'This app starts with 25 March 2026 as AM 6029, Month 1, Day 1. Different communities may use another epoch or chronology.'),
    _OnboardingContent(Icons.tune_outlined, 'Make it yours',
        'You can review and change the epoch and AM year in Settings. The default feast schedule follows the approved Luach Chanoch calendar.'),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
          body: SafeArea(
              child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(children: <Widget>[
          const Spacer(),
          Icon(_pages[_page].icon,
              size: 72, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 30),
          SizedBox(
              height: 210,
              child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (value) => setState(() => _page = value),
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    return Column(children: <Widget>[
                      Text(item.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Text(item.body,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center),
                    ]);
                  })),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: index == _page ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                          color: index == _page
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(10))))),
          const Spacer(),
          FilledButton(
              onPressed: _page == _pages.length - 1
                  ? widget.onComplete
                  : () => _controller.nextPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut),
              child: Text(_page == _pages.length - 1
                  ? 'Continue to calendar'
                  : 'Next')),
          const SizedBox(height: 10),
          TextButton(
              onPressed: widget.onComplete,
              child: const Text('Skip introduction')),
        ]),
      )));
}

class _OnboardingContent {
  const _OnboardingContent(this.icon, this.title, this.body);
  final IconData icon;
  final String title, body;
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.calendar});
  final EnochCalendar calendar;

  @override
  Widget build(BuildContext context) {
    final date = calendar.fromGregorian(DateTime.now());
    return ListView(padding: const EdgeInsets.all(24), children: <Widget>[
      const Text('LUACH CHANOCH',
          style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
      const SizedBox(height: 28),
      Text(date.weekday, style: Theme.of(context).textTheme.headlineMedium),
      Text('AM ${date.amYear}', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 10),
      Text('${date.monthName} ${date.day}',
          style: Theme.of(context).textTheme.displaySmall),
      Text('Day ${date.dayOfYear} of 364',
          style: Theme.of(context).textTheme.bodyLarge),
      const SizedBox(height: 28),
      _InfoCard(
          icon: Icons.wb_sunny_outlined,
          title: 'Season',
          value: calendar.seasonFor(date)),
      _InfoCard(
          icon: Icons.self_improvement_outlined,
          title: 'Sabbath',
          value: date.isSabbath
              ? 'Today is Sabbath'
              : 'Next Sabbath: ${6 - date.weekdayIndex} day(s)'),
      _ReadingCard(content: readingFor(date)),
      if (observanceFor(date.month, date.day) case final observance?)
        _InfoCard(
            icon: Icons.celebration_outlined,
            title: observance.name,
            value: observance.description),
      _UpcomingObservancesCard(
          items: upcomingObservances(calendar, DateTime.now())),
      const SizedBox(height: 12),
      Text(
          'This app follows a fixed 364-day Enoch calendar. Open Settings to see or change the epoch used for conversion.',
          style: Theme.of(context).textTheme.bodySmall),
    ]);
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(
      {required this.icon, required this.title, required this.value});
  final IconData icon;
  final String title, value;
  @override
  Widget build(BuildContext context) => Card(
      child: ListTile(
          leading: Icon(icon), title: Text(title), subtitle: Text(value)));
}

class _ReadingCard extends StatelessWidget {
  const _ReadingCard({required this.content});
  final DailyContent content;
  @override
  Widget build(BuildContext context) => Card(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                const Icon(Icons.menu_book_outlined),
                const SizedBox(width: 12),
                Text('Daily reading',
                    style: Theme.of(context).textTheme.titleMedium)
              ]),
              const SizedBox(height: 12),
              Text(content.title,
                  style: Theme.of(context).textTheme.titleSmall),
              Text(content.reference,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(content.prompt),
            ]),
      ));
}

class _UpcomingObservancesCard extends StatelessWidget {
  const _UpcomingObservancesCard({required this.items});
  final List<UpcomingObservance> items;

  @override
  Widget build(BuildContext context) => Card(
          child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(children: <Widget>[
                const Icon(Icons.event_note_outlined),
                const SizedBox(width: 12),
                Text('Upcoming observances',
                    style: Theme.of(context).textTheme.titleMedium)
              ]),
              const SizedBox(height: 8),
              for (final item in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.observance.name),
                  subtitle: Text(
                      '${item.enochDate.monthName} ${item.enochDate.day} · ${MaterialLocalizations.of(context).formatMediumDate(item.enochDate.gregorianDate)}'),
                ),
            ]),
      ));
}

class ConvertPage extends StatefulWidget {
  const ConvertPage({super.key, required this.calendar});
  final EnochCalendar calendar;
  @override
  State<ConvertPage> createState() => _ConvertPageState();
}

class _ConvertPageState extends State<ConvertPage> {
  DateTime _selected = DateTime.now();
  var _convertingFromGregorian = true;
  late final TextEditingController _amYear = TextEditingController(
    text: widget.calendar.fromGregorian(DateTime.now()).amYear.toString(),
  );
  int _month = 1;
  int _day = 1;

  @override
  void dispose() {
    _amYear.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.calendar.fromGregorian(_selected);
    return ListView(padding: const EdgeInsets.all(24), children: <Widget>[
      Text('Date converter', style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      SegmentedButton<bool>(
        segments: const <ButtonSegment<bool>>[
          ButtonSegment(value: true, label: Text('Gregorian → Enoch')),
          ButtonSegment(value: false, label: Text('Enoch → Gregorian')),
        ],
        selected: <bool>{_convertingFromGregorian},
        onSelectionChanged: (selection) =>
            setState(() => _convertingFromGregorian = selection.first),
      ),
      const SizedBox(height: 20),
      if (_convertingFromGregorian) ...<Widget>[
        OutlinedButton.icon(
          icon: const Icon(Icons.edit_calendar),
          label: Text(
              MaterialLocalizations.of(context).formatMediumDate(_selected)),
          onPressed: () async {
            final pick = await showDatePicker(
                context: context,
                firstDate: DateTime(1900),
                lastDate: DateTime(2200),
                initialDate: _selected);
            if (pick != null) setState(() => _selected = pick);
          },
        ),
        const SizedBox(height: 28),
        _EnochResultCard(date: result, calendar: widget.calendar),
      ] else ...<Widget>[
        TextField(
            controller: _amYear,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'AM year')),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
            key: ValueKey(_month),
            initialValue: _month,
            decoration: const InputDecoration(labelText: 'Month'),
            items: List<DropdownMenuItem<int>>.generate(
                12,
                (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text('${i + 1} · ${EnochCalendar.monthNames[i]}'))),
            onChanged: (value) => setState(() {
                  _month = value!;
                  _day = _day.clamp(1, widget.calendar.daysInMonth(_month));
                })),
        const SizedBox(height: 12),
        DropdownButtonFormField<int>(
            key: ValueKey(_day),
            initialValue: _day,
            decoration: const InputDecoration(labelText: 'Day'),
            items: List<DropdownMenuItem<int>>.generate(
                widget.calendar.daysInMonth(_month),
                (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
            onChanged: (value) => setState(() => _day = value!)),
        const SizedBox(height: 20),
        FilledButton(
            onPressed: () => setState(() {}),
            child: const Text('Convert date')),
        const SizedBox(height: 20),
        _GregorianResultCard(
            date: widget.calendar.toGregorian(
                amYear:
                    int.tryParse(_amYear.text) ?? widget.calendar.epochAmYear,
                month: _month,
                day: _day)),
      ],
    ]);
  }
}

class _EnochResultCard extends StatelessWidget {
  const _EnochResultCard({required this.date, required this.calendar});
  final EnochDate date;
  final EnochCalendar calendar;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('ENOCH DATE',
                    style: TextStyle(
                        letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text('${date.weekday}, ${date.monthName} ${date.day}',
                    style: Theme.of(context).textTheme.headlineSmall),
                Text('AM ${date.amYear} · Day ${date.dayOfYear}'),
                const SizedBox(height: 8),
                Text(calendar.isSeasonalDay(date)
                    ? 'Seasonal boundary day'
                    : calendar.seasonFor(date)),
              ])));
}

class _GregorianResultCard extends StatelessWidget {
  const _GregorianResultCard({required this.date});
  final DateTime date;
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('GREGORIAN DATE',
                    style: TextStyle(
                        letterSpacing: 1.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(MaterialLocalizations.of(context).formatFullDate(date),
                    style: Theme.of(context).textTheme.headlineSmall),
              ])));
}

class YearPage extends StatefulWidget {
  const YearPage({super.key, required this.calendar});
  final EnochCalendar calendar;
  @override
  State<YearPage> createState() => _YearPageState();
}

class _YearPageState extends State<YearPage> {
  int? _selectedMonth;
  @override
  Widget build(BuildContext context) {
    final current = widget.calendar.fromGregorian(DateTime.now());
    final selectedMonth = _selectedMonth ?? current.month;
    return ListView(padding: const EdgeInsets.all(20), children: <Widget>[
      Text('AM ${current.amYear}',
          style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 12),
      _MonthGrid(
          calendar: widget.calendar,
          amYear: current.amYear,
          month: selectedMonth),
      const SizedBox(height: 20),
      Text('Months', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 4),
      ...List<Widget>.generate(12, (i) {
        final month = i + 1;
        final start = widget.calendar
            .toGregorian(amYear: current.amYear, month: month, day: 1);
        return Card(
            child: ListTile(
          leading: CircleAvatar(child: Text('$month')),
          title: Text(EnochCalendar.monthNames[i]),
          subtitle: Text(
              '${widget.calendar.daysInMonth(month)} days · begins ${MaterialLocalizations.of(context).formatMediumDate(start)}'),
          trailing: observanceFor(month, 1) == null && month % 3 != 0
              ? null
              : const Icon(Icons.event_outlined),
          onTap: () => setState(() => _selectedMonth = month),
        ));
      }),
    ]);
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid(
      {required this.calendar, required this.amYear, required this.month});
  final EnochCalendar calendar;
  final int amYear, month;
  @override
  Widget build(BuildContext context) {
    final start = calendar.toGregorian(amYear: amYear, month: month, day: 1);
    final startDay = calendar.fromGregorian(start).weekdayIndex;
    final count = calendar.daysInMonth(month);
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: <Widget>[
              Text('${EnochCalendar.monthNames[month - 1]} · $count days',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(children: <Widget>[
                for (final d in <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'])
                  Expanded(
                      child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold))))
              ]),
              const SizedBox(height: 8),
              GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: startDay + count,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4),
                  itemBuilder: (context, index) {
                    if (index < startDay) return const SizedBox.shrink();
                    final day = index - startDay + 1;
                    final eDate = calendar.fromGregorian(calendar.toGregorian(
                        amYear: amYear, month: month, day: day));
                    final observance = observanceFor(month, day);
                    final color = eDate.isSabbath
                        ? Theme.of(context).colorScheme.secondaryContainer
                        : observance != null || calendar.isSeasonalDay(eDate)
                            ? Theme.of(context).colorScheme.tertiaryContainer
                            : null;
                    return Tooltip(
                        message: observance?.name ??
                            (calendar.isSeasonalDay(eDate)
                                ? 'Seasonal boundary day'
                                : eDate.weekday),
                        child: DecoratedBox(
                            decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(child: Text('$day'))));
                  }),
              const SizedBox(height: 10),
              const Text(
                  'Sabbaths and seasonal/observance days are highlighted.',
                  textAlign: TextAlign.center),
            ])));
  }
}

class JournalPage extends StatefulWidget {
  const JournalPage({super.key});
  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  final _repository = JournalRepository();
  var _entries = <JournalEntry>[];
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _repository.load();
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _addEntry() async {
    final entry = await showDialog<JournalEntry>(
        context: context, builder: (_) => const _JournalEntryDialog());
    if (entry == null) return;
    setState(() => _entries = <JournalEntry>[entry, ..._entries]);
    await _repository.save(_entries);
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Delete entry?'),
              content: const Text(
                  'This journal entry will be removed from this device.'),
              actions: <Widget>[
                TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Delete')),
              ],
            ));
    if (accepted != true) return;
    setState(() => _entries.removeWhere((item) => item.id == entry.id));
    await _repository.save(_entries);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton.extended(
            onPressed: _addEntry,
            icon: const Icon(Icons.add),
            label: const Text('New entry')),
        body: SafeArea(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _entries.isEmpty
                    ? const _EmptyJournal()
                    : ListView(
                        padding: const EdgeInsets.all(20),
                        children: <Widget>[
                            Text('Prayer & journal',
                                style:
                                    Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 6),
                            const Text(
                                'Entries are stored only on this device.'),
                            const SizedBox(height: 16),
                            ..._entries.map((entry) => Card(
                                    child: ListTile(
                                  leading: Icon(entry.isPrayer
                                      ? Icons.volunteer_activism_outlined
                                      : Icons.edit_note_outlined),
                                  title: Text(entry.title),
                                  subtitle: Text(
                                      '${MaterialLocalizations.of(context).formatMediumDate(entry.createdAt)}\n${entry.body}',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis),
                                  isThreeLine: true,
                                  trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline),
                                      tooltip: 'Delete entry',
                                      onPressed: () => _deleteEntry(entry)),
                                ))),
                          ])),
      );
}

class _EmptyJournal extends StatelessWidget {
  const _EmptyJournal();
  @override
  Widget build(BuildContext context) => Center(
      child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
            const Icon(Icons.edit_note_outlined, size: 72),
            const SizedBox(height: 20),
            Text('Your journal is private',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text(
                'Save prayers, reflections, and notes. They remain on this device unless you choose to export them in a future release.',
                textAlign: TextAlign.center),
          ])));
}

class _JournalEntryDialog extends StatefulWidget {
  const _JournalEntryDialog();
  @override
  State<_JournalEntryDialog> createState() => _JournalEntryDialogState();
}

class _JournalEntryDialogState extends State<_JournalEntryDialog> {
  final _title = TextEditingController();
  final _body = TextEditingController();
  var _isPrayer = false;
  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('New entry'),
        content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
          TextField(
              controller: _title,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(labelText: 'Title')),
          TextField(
              controller: _body,
              onChanged: (_) => setState(() {}),
              textCapitalization: TextCapitalization.sentences,
              minLines: 3,
              maxLines: 6,
              decoration:
                  const InputDecoration(labelText: 'Reflection or prayer')),
          SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Prayer entry'),
              value: _isPrayer,
              onChanged: (value) => setState(() => _isPrayer = value)),
        ])),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: _title.text.trim().isEmpty || _body.text.trim().isEmpty
                  ? null
                  : () => Navigator.pop(
                      context,
                      JournalEntry(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          title: _title.text.trim(),
                          body: _body.text.trim(),
                          createdAt: DateTime.now(),
                          isPrayer: _isPrayer)),
              child: const Text('Save')),
        ],
      );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage(
      {super.key,
      required this.epoch,
      required this.amYear,
      required this.onChanged,
      required this.darkMode,
      required this.onDarkModeChanged,
      required this.sabbathReminders,
      required this.onSabbathRemindersChanged});
  final DateTime epoch;
  final int amYear;
  final void Function(DateTime, int) onChanged;
  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final bool sabbathReminders;
  final ValueChanged<bool> onSabbathRemindersChanged;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final TextEditingController _year =
      TextEditingController(text: widget.amYear.toString());
  @override
  void dispose() {
    _year.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      ListView(padding: const EdgeInsets.all(24), children: <Widget>[
        Text('Calendar convention',
            style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text(
            'Choose the Gregorian day that is Month 1, Day 1 for your tradition. The app then counts fixed 364-day years from that point.'),
        const SizedBox(height: 20),
        ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Calendar epoch'),
            subtitle: Text(MaterialLocalizations.of(context)
                .formatMediumDate(widget.epoch)),
            trailing: const Icon(Icons.edit_calendar),
            onTap: () async {
              final pick = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2200),
                  initialDate: widget.epoch);
              if (pick != null) {
                widget.onChanged(
                    pick, int.tryParse(_year.text) ?? widget.amYear);
              }
            }),
        TextField(
            controller: _year,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'AM year at epoch',
                helperText: 'Selected default: AM 6029')),
        const SizedBox(height: 16),
        FilledButton(
            onPressed: () => widget.onChanged(
                widget.epoch, int.tryParse(_year.text) ?? widget.amYear),
            child: const Text('Save convention')),
        const SizedBox(height: 20),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Dark mode'),
          subtitle: const Text('Use a low-light color theme.'),
          value: widget.darkMode,
          onChanged: widget.onDarkModeChanged,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Calendar reminders'),
          subtitle: const Text(
              'Sabbaths at 6:00 PM and feast observances at 9:00 AM.'),
          value: widget.sabbathReminders,
          onChanged: widget.onSabbathRemindersChanged,
        ),
        const SizedBox(height: 32),
        Text('About this calendar',
            style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        const Text(
            'Luach Chanoch uses its approved 364-day calendar and feast schedule. You can review or change the epoch and AM year if your local observance uses a different calculation.'),
        const SizedBox(height: 20),
        OutlinedButton.icon(
            icon: const Icon(Icons.info_outline),
            label: const Text('App and privacy information'),
            onPressed: () => showAboutDialog(
                  context: context,
                  applicationName: 'Luach Chanoch',
                  applicationVersion: '1.0.0',
                  applicationLegalese:
                      'Calendar preferences and journal entries are stored locally on your device. Luach Chanoch does not create accounts or transmit personal data.',
                  children: const <Widget>[
                    Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: Text(
                            'The default feast dates follow the approved Luach Chanoch calendar. Change the calendar convention in Settings only when your observance uses a different epoch.'))
                  ],
                )),
      ]);
}
