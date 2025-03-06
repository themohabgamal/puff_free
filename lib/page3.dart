import 'package:flutter/material.dart';
import 'package:puff_free/const.dart';
import 'package:puff_free/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  bool _isPlanActive = false;

  @override
  void initState() {
    super.initState();
    _checkIfPlanIsActive();
  }

  Future<void> _checkIfPlanIsActive() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? quitDate = prefs.getString('quit_date');
    final int? daysFromToday = prefs.getInt('days_from_today');
    final int? dailyPuffs = prefs.getInt('daily_puffs');

    if (daysFromToday != null) {
      setState(() {
        _isPlanActive = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If a plan is active, navigate to QuitPlanScreen with cached values
    if (_isPlanActive) {
      return FutureBuilder(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            // Handle error
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else {
            // Retrieve cached values
            final SharedPreferences prefs = snapshot.data!;
            final int duration = prefs.getInt('days_from_today') ?? 0;
            final int dailyPuffs = prefs.getInt('daily_puffs') ?? 0;

            // Navigate to QuitPlanScreen with cached values
            return QuitPlanScreen(
              duration: duration,
              dailyPuffs: dailyPuffs,
            );
          }
        },
      );
    }

    // Otherwise, show the default screen
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildMainContent(context),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Quit Plan',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 100,
            backgroundColor: Colors.transparent,
            child: Image.asset('assets/images/goal1.png', width: 150),
          ),
          const SizedBox(height: 20),
          Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Create your quit plan in just a few steps:\n'
                '- Choose desired quit date\n'
                '- Enter your daily puffs\n'
                '- Follow daily goals to lessen cravings & intake',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.start,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              // Navigate to SetQuitDateScreen using Navigator.push
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SetQuitDateScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
            ),
            child: const Text(
              'Start Your Quit Plan',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class SetQuitDateScreen extends StatefulWidget {
  const SetQuitDateScreen({super.key});

  @override
  SetQuitDateScreenState createState() => SetQuitDateScreenState();
}

class SetQuitDateScreenState extends State<SetQuitDateScreen> {
  DateTime? _selectedDate;
  int? _dailyPuffs;
  String? _selectedOption;

  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );
    if (!mounted) return;

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _selectedOption = null;
      });
    }
  }

  Future<void> _saveQuitPlan() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    int? duration;

    if (_selectedDate != null) {
      // Calculate the duration in days
      duration = _selectedDate!.difference(DateTime.now()).inDays;

      // Add an extra day to the duration
      duration += 1;

      // Save the quit date and duration to SharedPreferences
      await prefs.setString(
          'quit_date', DateFormat('yyyy-MM-dd').format(_selectedDate!));
      await prefs.setInt('days_from_today', duration);

      // Print for debugging
      print("Quit date saved: ${prefs.getString('quit_date')}");
      print("Days from today: ${prefs.getInt('days_from_today')}");
    } else if (_selectedOption != null) {
      duration = int.parse(_selectedOption!.split(' ')[0]);
      await prefs.setInt('days_from_today', duration);
      print("Quick selection saved: $duration days");
    }

    if (_dailyPuffs != null) {
      await prefs.setInt('daily_puffs', _dailyPuffs!);
      print("Daily puffs saved: ${prefs.getInt('daily_puffs')}");
    }

    // Navigate to QuitPlanScreen using Navigator.pushReplacement
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => QuitPlanScreen(
          duration: duration!,
          dailyPuffs: _dailyPuffs ?? 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Text(
                'Set a Quit Date',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Choose a date that's realistic and achievable based on your current intake.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Quit Date Picker
              const Text(
                'Choose your quit date',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _selectDate,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    border: Border.all(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                        : 'Select Date',
                    style: const TextStyle(fontSize: 18, color: kPrimaryColor),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Quick Selection Options
              const Text(
                'Quick Selection Options',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children: [7, 30, 60].map((day) {
                  return ChoiceChip(
                    label: Text('$day days'),
                    selected: _selectedOption == '$day days',
                    onSelected: (selected) {
                      setState(() {
                        _selectedOption = selected ? '$day days' : null;
                        _selectedDate =
                            null; // Clear date when quick option selected
                      });
                    },
                    selectedColor: kPrimaryColor,
                    labelStyle: TextStyle(
                      color: _selectedOption == '$day days'
                          ? Colors.white
                          : kPrimaryColor,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Daily Puffs Input
              const Text(
                'How many puffs do you currently take daily?',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter number of puffs',
                ),
                onChanged: (value) {
                  setState(() {
                    _dailyPuffs = int.tryParse(value);
                  });
                },
              ),
              const SizedBox(height: 30),

              // Done Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_selectedDate == null && _selectedOption == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select a quit plan option!')),
                      );
                      return;
                    }

                    if (_dailyPuffs == null || _dailyPuffs! <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Please enter a valid number of puffs!')),
                      );
                      return;
                    }

                    await _saveQuitPlan();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: bottomPadding + 20),
            ],
          ),
        ),
      ),
    );
  }
}

class QuitPlanScreen extends StatefulWidget {
  final int duration; // Duration in days
  final int dailyPuffs;

  const QuitPlanScreen({
    super.key,
    required this.duration,
    required this.dailyPuffs,
  });

  @override
  State<QuitPlanScreen> createState() => _QuitPlanScreenState();
}

class _QuitPlanScreenState extends State<QuitPlanScreen> {
  late DateTime startTime;
  late DateTime endTime;
  Duration remainingDuration = Duration.zero;
  Timer? _timer;

  int todayPuffs = 0;
  int todayLimit = 0;

  @override
  void initState() {
    super.initState();
    initializeTimer();
    getTodayPuffs();
  }

  void initializeTimer() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedStartTime = prefs.getString("startTime");

    if (savedStartTime == null) {
      startTime = DateTime.now();
      prefs.setString("startTime", startTime.toIso8601String());
    } else {
      startTime = DateTime.parse(savedStartTime);
    }

    endTime = startTime.add(Duration(days: widget.duration));
    _startCountdown();
  }

  void _startCountdown() {
    _updateRemainingTime();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      setState(() {
        _updateRemainingTime();
      });
    });
  }

  void _updateRemainingTime() {
    setState(() {
      remainingDuration = endTime.difference(DateTime.now());
    });

    if (remainingDuration.isNegative) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void getTodayPuffs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();

    setState(() {
      todayPuffs = prefs.getInt(todayKey) ?? 0;
      todayLimit = _calculateDynamicLimit();
    });
  }

  int _calculateDynamicLimit() {
    final totalDays = widget.duration;
    final daysElapsed = DateTime.now().difference(startTime).inDays;
    final remainingDays = (totalDays - daysElapsed).clamp(0, totalDays);
    return ((remainingDays / totalDays) * widget.dailyPuffs).ceil();
  }

  String _getTodayKey() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final daysLeft = remainingDuration.inDays;
    final hoursLeft = remainingDuration.inHours % 24;
    final minutesLeft = remainingDuration.inMinutes % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FA),
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Quit Plan",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: const SizedBox()),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLimitTodayCard(),
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              color: Colors.lightBlue.withOpacity(0.1),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  children: [
                    const Text(
                      "Countdown Timer",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCountdownItem("$daysLeft", "Days"),
                        const Text(":",
                            style:
                                TextStyle(fontSize: 24, color: Colors.black)),
                        _buildCountdownItem("$hoursLeft", "Hours"),
                        const Text(":",
                            style:
                                TextStyle(fontSize: 24, color: Colors.black)),
                        _buildCountdownItem("$minutesLeft", "Minutes"),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 50, vertical: 15),
                    ),
                    onPressed: () async {
                      final SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      await prefs.remove('quit_date');
                      await prefs.remove('days_from_today');
                      await prefs.remove('daily_puffs');
                      await prefs.remove('startTime');

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      "Cancel Plan",
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitTodayCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      color: kPrimaryColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/images/goal.png',
                  width: 50,
                  height: 50,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Limit today",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      "$todayLimit puffs",
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const VerticalDivider(color: Colors.grey, thickness: 1),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Today Puffs",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Text(
                  "$todayPuffs puffs",
                  style: const TextStyle(
                    color: Colors.yellow,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountdownItem(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kPrimaryColor, width: 2),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
