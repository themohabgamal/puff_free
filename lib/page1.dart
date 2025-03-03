import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:puff_free/const.dart';
import 'package:puff_free/home_fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Page1 extends StatefulWidget {
  const Page1({super.key});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  int _puffCount = 0;
  final int _puffGoal = 100;
  int? _dailyPuffLimit;
  bool _exceedsLimit = false;
  List<DateTime> puffTimestamps = [];
  bool clear = false;
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();

    if (!mounted) return;

    setState(() {
      _puffCount = prefs.getInt(todayKey) ?? 0;
      _dailyPuffLimit = prefs.getInt('daily_puff_limit');
      _exceedsLimit = _dailyPuffLimit != null && _puffCount > _dailyPuffLimit!;
      // Load puffTimestamps
      final savedTimestamps = prefs.getStringList('puffTimestamps') ?? [];
      puffTimestamps = savedTimestamps
          .map((timestamp) => DateTime.parse(timestamp))
          .toList();
    });
  }

  Future<void> _saveTodayPuffCount() async {
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();
    await prefs.setInt(todayKey, _puffCount);
    final timestampStrings =
        puffTimestamps.map((timestamp) => timestamp.toIso8601String()).toList();
    await prefs.setStringList('puffTimestamps', timestampStrings);
  }

  String _getTodayKey() => DateTime.now().toIso8601String().substring(0, 10);

  void _incrementPuff() {
    setState(() {
      _puffCount++;
      puffTimestamps.add(DateTime.now());
      _exceedsLimit = _dailyPuffLimit != null && _puffCount > _dailyPuffLimit!;
    });
    _saveTodayPuffCount();
  }

  Future<void> _showSettingsDialog(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    const lastSetDateKey = 'daily_limit_last_set';
    final lastSetDate = prefs.getString(lastSetDateKey);
    final now = DateTime.now();
    final canUpdateLimit = lastSetDate == null ||
        DateTime.parse(lastSetDate).difference(now).inDays < 0;

    if (!mounted) return;

    if (!canUpdateLimit) {
      await showDialog(
        context: context,
        builder: (context) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 16,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_outlined,
                    color: Colors.orange, size: 50),
                const SizedBox(height: 16),
                const Text(
                  'Limit Already Set',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You can update the daily puff limit only once per day.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      return;
    }

    final dailyLimitController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 16,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit, color: kPrimaryColor, size: 50),
              const SizedBox(height: 16),
              const Text(
                'Set Daily Puff Limit',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: dailyLimitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter daily puff limit',
                  hintStyle: const TextStyle(color: Colors.black38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: kPrimaryColor, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () async {
                  if (dailyLimitController.text.isNotEmpty) {
                    final limit = int.parse(dailyLimitController.text);
                    await prefs.setInt('daily_puff_limit', limit);
                    await prefs.setString(
                        lastSetDateKey, now.toIso8601String());

                    if (!mounted) return;
                    setState(() {
                      _dailyPuffLimit = limit;
                      _exceedsLimit = _puffCount > _dailyPuffLimit!;
                    });
                  }
                  if (mounted) Navigator.of(dialogContext).pop();
                },
                child: const Text(
                  'Save',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _clearRecentData(SharedPreferences prefs, int days) async {
    for (int i = 0; i < days; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      String key = _getDateKey(date);
      await prefs.remove(key);
    }
  }

  String _getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);
  @override
  Widget build(BuildContext context) {
    final progress =
        _puffGoal != 0 ? (_puffCount / _puffGoal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: _resetPuffCount,
        child: const Icon(
          Icons.clear,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    _buildTitle(),
                    const SizedBox(height: 60),
                    _buildProgressIndicator(progress),
                    const SizedBox(height: 20),
                    HomeFlChart(
                      puffTimestamps: puffTimestamps,
                      clear: clear,
                    ),
                    const SizedBox(height: 40),
                    _buildPuffButton(),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 10,
              child: IconButton(
                style: IconButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  backgroundColor: kPrimaryColor,
                ),
                icon: const Text(
                  'Daily Limit',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 18),
                ),
                onPressed: () {
                  _showSettingsDialog(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Puff ',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: Colors.black,
          ),
        ),
        Text(
          'Free',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: kPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(double progress) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 250,
          height: 250,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: Colors.blue[100],
            color: kPrimaryColor,
          ),
        ),
        CircleAvatar(
          radius: 110,
          backgroundColor: _exceedsLimit ? Colors.red[50] : Colors.blue[50],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$_puffCount',
                style: TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: _exceedsLimit ? Colors.red : Colors.blue,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Puffs Today',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontFamily: 'Nunito',
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${(_puffCount * 0.41).toStringAsFixed(2)} mg \n Nicotine',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.orange,
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPuffButton() {
    return ElevatedButton(
      onPressed: _incrementPuff,
      style: ElevatedButton.styleFrom(
        backgroundColor: kPrimaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      ),
      child: const Text(
        '+ Puff',
        style: TextStyle(
          fontSize: 24,
          fontFamily: 'Nunito',
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _resetPuffCount() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _puffCount = 0;
      puffTimestamps.clear(); // Clear the timestamps as well
      clear = true;
      _exceedsLimit = false; // Reset limit warning
    });

    // Save the cleared state in SharedPreferences
    final todayKey = _getTodayKey();
    await prefs.remove(todayKey);
    await prefs.remove('puffTimestamps'); // Remove stored timestamps
  }
}
