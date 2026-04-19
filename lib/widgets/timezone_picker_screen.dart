import 'package:flutter/material.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TimezonePickerScreen extends StatefulWidget {
  const TimezonePickerScreen({super.key});

  @override
  State<TimezonePickerScreen> createState() => _TimezonePickerScreenState();
}

class _TimezonePickerScreenState extends State<TimezonePickerScreen> {
  final _searchController = TextEditingController();
  late List<String> _allTimezones;
  List<String> _filtered = [];

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _allTimezones = tz.timeZoneDatabase.locations.keys.toList()..sort();
    _filtered = _allTimezones;
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? _allTimezones
          : _allTimezones
              .where((tz) => tz.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'タイムゾーンを検索...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: _filtered.length,
        itemBuilder: (ctx, i) => ListTile(
          title: Text(_filtered[i]),
          onTap: () => Navigator.of(ctx).pop(_filtered[i]),
        ),
      ),
    );
  }
}
