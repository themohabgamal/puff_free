import 'package:flutter/material.dart';
import 'package:puff_free/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async'; // Add this import statement

class Page3 extends StatefulWidget {
  const Page3({super.key});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  bool _showQuitDateScreen = false;
  bool showQuitPlan = false;
  showScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      showQuitPlan = prefs.getBool('showQuitPlan') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _showQuitDateScreen
              ? SetQuitDateScreen(
                  onBack: () {
                    setState(() {
                      _showQuitDateScreen = false;
                    });
                  },
                )
              : _buildMainContent(context),
        ),
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
              // Show the SetQuitDateScreen content
              setState(() {
                _showQuitDateScreen = true;
              });
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
  final VoidCallback onBack;
  const SetQuitDateScreen({super.key, required this.onBack});

  @override
  SetQuitDateScreenState createState() => SetQuitDateScreenState();
}

class SetQuitDateScreenState extends State<SetQuitDateScreen> {
  DateTime? _selectedDate;
  int? _dailyPuffs;
  String? _selectedOption;
  bool _showQuitPlanScreen = false;

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
      duration = _selectedDate!.difference(DateTime.now()).inDays;
      await prefs.setString(
          'quit_date', DateFormat('yyyy-MM-dd').format(_selectedDate!));
      await prefs.setInt('days_from_today', duration);
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

    // if (duration != null) {
    //   Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => QuitPlanScreen(
    //       duration: duration!,
    //       dailyPuffs: _dailyPuffs ?? 0,
    //       onBack: () {
    //         setState(() {
    //           _showQuitPlanScreen = false;
    //         });
    //       },
    //     ),
    //   ));
    // }
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return _showQuitPlanScreen
        ? QuitPlanScreen(
            dailyPuffs: _dailyPuffs ?? 0,
            duration: (_selectedDate != null)
                ? _selectedDate!.difference(DateTime.now()).inDays
                : int.parse(_selectedOption!.split(' ')[0]),
            onBack: () {
              setState(() {
                _showQuitPlanScreen = false;
              });
            })
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                ),
                onPressed: widget.onBack,
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
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: kPrimaryColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                              : 'Select Date',
                          style: const TextStyle(
                              fontSize: 18, color: kPrimaryColor),
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
                          if (_selectedDate == null &&
                              _selectedOption == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please select a quit plan option!')),
                            );
                            return;
                          }

                          if (_dailyPuffs == null || _dailyPuffs! <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please enter a valid number of puffs!')),
                            );
                            return;
                          }
                          setState(() {
                            _showQuitPlanScreen = true;
                          });
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
  final VoidCallback onBack;
  final int duration; // Duration in days
  final int dailyPuffs;

  const QuitPlanScreen({
    super.key,
    required this.onBack,
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
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Check if there's a saved start time
    String? savedStartTime = prefs.getString("startTime");
    if (savedStartTime == null) {
      // If no saved time, set start time to now and save it
      startTime = DateTime.now();
      prefs.setString("startTime", startTime.toIso8601String());
    } else {
      startTime = DateTime.parse(savedStartTime);
    }

    // Calculate end time
    endTime = startTime.add(Duration(days: widget.duration));

    // Start the timer
    _startCountdown();
  }

  void _startCountdown() {
    _updateRemainingTime();

    // Set up a timer to update every minute
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

    // Stop the timer if the countdown has ended
    if (remainingDuration.isNegative) {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // void getTodayPuffs() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final todayKey = _getTodayKey();
  //   setState(() {
  //     todayPuffs = prefs.getInt(todayKey) ?? 0;
  //     todayLimit = prefs.getInt("daily_puffs") ?? 0;
  //   });
  // }
  void getTodayPuffs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final todayKey = _getTodayKey();

    setState(() {
      todayPuffs = prefs.getInt(todayKey) ?? 0;
      todayLimit = _calculateDynamicLimit();
    });
  }

  int _calculateDynamicLimit() {
    final totalDays = widget.duration;
    final daysElapsed = DateTime.now().difference(startTime).inDays;

    // Ensure the days elapsed does not exceed the total duration
    final remainingDays = (totalDays - daysElapsed).clamp(0, totalDays);

    // Calculate today's limit proportionally
    return ((remainingDays / totalDays) * widget.dailyPuffs).ceil();
  }

  String _getTodayKey() => DateTime.now().toIso8601String().substring(0, 10);

  @override
  Widget build(BuildContext context) {
    final daysLeft = remainingDuration.inDays;
    final hoursLeft = remainingDuration.inHours % 24;
    final minutesLeft = remainingDuration.inMinutes % 60;

    return Scaffold(
      backgroundColor: const Color(0xFFEFF7FA), // Background color
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
        leading: const SizedBox(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Card 1: Limit Today and Puffs Today
            _buildLimitTodayCard(),
            const SizedBox(height: 20),
            // Card 2: Countdown Timer
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
                              borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 50, vertical: 15)),
                      onPressed: () async {
                        SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                        await prefs.setBool('showQuitPlan', false);
                        widget.onBack;
                      },
                      child: const Text("Cancel Plan",
                          style: TextStyle(color: Colors.white, fontSize: 22))),
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
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}

class QuitPlanResult extends StatelessWidget {
  final VoidCallback onBack;
  const QuitPlanResult({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Quit Plan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: onBack,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Action for Yes
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'Yes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    // Action for No
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: kPrimaryColor, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 15),
                  ),
                  child: const Text(
                    'No',
                    style: TextStyle(
                      color: kPrimaryColor,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10.0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Countdown Timer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTimeBlock('00', 'day'),
                      _buildSeparator(),
                      _buildTimeBlock('00', 'hour'),
                      _buildSeparator(),
                      _buildTimeBlock('00', 'min'),
                      _buildSeparator(),
                      _buildTimeBlock('00', 'sec'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBlock(String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSeparator() {
    return const Text(
      ':',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }
}

class YesAnswer extends StatelessWidget {
  const YesAnswer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events,
                color: Colors.orange,
                size: 80.0,
              ),
              const SizedBox(height: 20.0),
              const Text(
                "Congratulations!",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              const Text(
                "You did it! You quit for good!",
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Text(
                "Take some time to celebrate achieving your goal! You deserve it.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                "To keep the momentum going, visit our website for a guide on post-quit success.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20.0),
              Text(
                "We’re so glad Puff Count was a part of your journey. Well done!",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  // Action for "Reset quit coach"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  "Reset quit coach",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NoAnswer extends StatelessWidget {
  const NoAnswer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Quit Plan",
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20.0),
              const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.orange,
                size: 60.0,
              ),
              const SizedBox(height: 20.0),
              const Text(
                "Almost there!",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                "You didn’t meet your goal quite yet, but don’t despair.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                "You’ve already made a huge leap forward by starting a Quit Plan.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                "Reset your Quit Coach, and keep moving toward your goal.",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10.0),
              Text(
                "You’ve got this!",
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  // Action for "Reset Quit Coach"
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor, // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 12.0),
                ),
                child: const Text(
                  "Reset Quit Coach",
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
