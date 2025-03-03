import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'paywall.dart'; // تأكد من وجود هذا الملف

class Survey extends StatelessWidget {
  const Survey({super.key});

  @override
  Widget build(BuildContext context) {
    return _buildSurveyPage(context);
  }

  // Future<bool> _checkFirstRun() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   return prefs.getBool('isFirstRun') ?? true;
  // }

  // Future<void> _markAsSeen() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setBool('isFirstRun', false);
  // }

  Widget _buildSurveyPage(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeaderText(),
            const SizedBox(height: 20),
            _buildLogo(),
            const SizedBox(height: 20),
            _buildDescriptionText(),
            const SizedBox(height: 20),
            _buildSurveyDuration(),
            const SizedBox(height: 40),
            _buildSurveyButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return const Text(
      'Take the survey to get your custom quitting plan',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        fontFamily: 'Nunito',
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLogo() {
    return const CircleAvatar(
      radius: 50,
      backgroundImage: AssetImage('assets/images/logo_circle.png'),
    );
  }

  Widget _buildDescriptionText() {
    return const Text(
      "Let's start by learning more about your habit",
      style: TextStyle(
        fontSize: 16,
        fontFamily: 'Nunito',
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSurveyDuration() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.timer, color: Colors.blue),
        SizedBox(width: 8),
        Text(
          'Takes 1 minute',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Nunito',
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SurveyQuestionPage()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
        ),
      ),
      child: const Text('Take the Survey'),
    );
  }
}

class SurveyQuestionPage extends StatefulWidget {
  const SurveyQuestionPage({super.key});

  @override
  SurveyQuestionPageState createState() => SurveyQuestionPageState();
}

class SurveyQuestionPageState extends State<SurveyQuestionPage> {
  int currentQuestionIndex = 0;
  int totalScore = 0;

  final List<Map<String, Object>> questions = [
    {
      "question": "How often do you vape?",
      "answers": [
        {"text": "Daily", "score": 3},
        {"text": "Weekly", "score": 2},
        {"text": "Occasionally", "score": 1},
        {"text": "Rarely", "score": 0}
      ],
    },
    {
      "question": "How many puffs do you take per session?",
      "answers": [
        {"text": "Less than 10", "score": 0},
        {"text": "10-20", "score": 1},
        {"text": "20-50", "score": 2},
        {"text": "More than 50", "score": 3}
      ],
    },
    {
      "question": "What time of day do you usually vape?",
      "answers": [
        {"text": "Morning", "score": 2},
        {"text": "Afternoon", "score": 1},
        {"text": "Evening", "score": 1},
        {"text": "Throughout the day", "score": 3}
      ],
    },
    {
      "question": "Do you experience cravings when you don’t vape?",
      "answers": [
        {"text": "Always", "score": 3},
        {"text": "Sometimes", "score": 2},
        {"text": "Rarely", "score": 1},
        {"text": "Never", "score": 0}
      ],
    },
    {
      "question": "Have you tried to quit vaping before?",
      "answers": [
        {"text": "Yes, multiple times", "score": 3},
        {"text": "Yes, once", "score": 2},
        {"text": "No, but I thought about it", "score": 1},
        {"text": "No, never", "score": 0}
      ],
    },
    {
      "question": "Why do you vape?",
      "answers": [
        {"text": "Stress relief", "score": 2},
        {"text": "Habit", "score": 3},
        {"text": "Social reasons", "score": 1},
        {"text": "I enjoy the flavors", "score": 1}
      ],
    },
    {
      "question": "Do you feel physical symptoms if you don’t vape?",
      "answers": [
        {"text": "Yes, often", "score": 3},
        {"text": "Yes, sometimes", "score": 2},
        {"text": "Rarely", "score": 1},
        {"text": "Never", "score": 0}
      ],
    },
    {
      "question": "Would you like to reduce or stop vaping?",
      "answers": [
        {"text": "Yes, immediately", "score": 0},
        {"text": "Yes, gradually", "score": 1},
        {"text": "I’m not sure", "score": 2},
        {"text": "No, not yet", "score": 3}
      ],
    },
  ];

  void answerQuestion(int score) async {
    totalScore += score;
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      await saveScoreToPreferences();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SliderPage()),
      );
    }
  }

  Future<void> saveScoreToPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('vaping_addiction_score', totalScore);
  }

  void skipSurvey() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SliderPage()),
    );
  }

  double get progressValue => (currentQuestionIndex + 1) / questions.length;

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[currentQuestionIndex];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Skip button and progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentQuestionIndex + 1}/${questions.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: skipSurvey,
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        color: Colors.blue,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progressValue,
                backgroundColor: Colors.grey[300],
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              // Question text
              Text(
                currentQuestion['question'] as String,
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              // Answers
              Expanded(
                child: ListView.separated(
                  itemCount:
                      (currentQuestion['answers'] as List<Map<String, Object>>)
                          .length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final answer = (currentQuestion['answers']
                        as List<Map<String, Object>>)[index];
                    return ElevatedButton(
                      onPressed: () => answerQuestion(answer['score'] as int),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor:
                            Colors.black, // Set text color to black
                        textStyle: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                        ),
                      ),
                      child: Text(answer['text'] as String),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// صفحة Slider
class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  SliderPageState createState() => SliderPageState();
}

class SliderPageState extends State<SliderPage> {
  final List<int> _puffOptions = [50, 100, 150, 200, 250, 300];
  int _selectedPuff = 50;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Header Text
              const Text(
                'Select Your Monthly Payments',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Instruction Subtext
              const Text(
                'Slide To Adjust',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Nunito',
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Modern Vertical Scroll Wheel
              Container(
                height: 220,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: Colors.blue.withOpacity(0.3), width: 1.5),
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [Colors.blue[50]!, Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ListWheelScrollView.useDelegate(
                  itemExtent: 60, // Height of each item
                  physics: const FixedExtentScrollPhysics(),
                  perspective: 0.0025, // Perspective for depth effect
                  diameterRatio: 1.7, // Controls the roundness
                  onSelectedItemChanged: (index) {
                    setState(() {
                      _selectedPuff = _puffOptions[index];
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      return AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.bold,
                          color: _selectedPuff == _puffOptions[index]
                              ? Colors.blue
                              : Colors.black26,
                        ),
                        child: Center(
                          child: Text('${_puffOptions[index]}'),
                        ),
                      );
                    },
                    childCount: _puffOptions.length,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Selected Puff Display
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  'Selected Payments: $_selectedPuff',
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Analyze Now Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ResultPage(amount: _selectedPuff.toDouble()),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  elevation: 5,
                  shadowColor: Colors.blueAccent.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text(
                  'Analyze Now',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

// صفحة النتائج
class ResultPage extends StatelessWidget {
  final double amount;

  const ResultPage({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    final yearlyAmount = (amount * 12).round();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Decorative Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue[50],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/shield.png',
                  height: 80,
                ),
              ),
              const SizedBox(height: 30),

              // Main Title
              const Text(
                'Your Average Yearly Spend on Vaping',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Highlighted Amount
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  '\$$yearlyAmount',
                  style: const TextStyle(
                    fontSize: 36,
                    fontFamily: 'Nunito',
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Subtext
              const Text(
                'We can help you save this money and improve your health.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Nunito',
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Call-to-Action Button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const FinalSurveyPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 5,
                  shadowColor: Colors.blueAccent.withOpacity(0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 55),
                ),
                child: const Text(
                  "See Your Quit Plan",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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

class FinalSurveyPage extends StatelessWidget {
  const FinalSurveyPage({super.key});

  Future<int> getTotalScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('vaping_addiction_score') ??
        0; // Default to 0 if no score is saved
  }

  String getAddictionLevel(int totalScore) {
    if (totalScore <= 6) {
      return "Based on your answers, there is an indication that you have a Low addiction level to vaping.";
    } else if (totalScore <= 14) {
      return "Based on your answers, there is a strong indication that you have a Medium addiction level to vaping.";
    } else {
      return "Based on your answers, there is a strong indication that you have a High addiction level to vaping.";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  size: 60,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),

              // Main text with FutureBuilder
              FutureBuilder<int>(
                future: getTotalScore(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text(
                      "Error loading score",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    return Text(
                      getAddictionLevel(snapshot.data ?? 0),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              const Text(
                'We can help you quit vaping by creating a personalized plan tailored to your habits.',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Nunito',
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PaywallPage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadowColor: Colors.blueAccent.withOpacity(0.2),
                  elevation: 5,
                ),
                child: const Text(
                  "Let's fix that together",
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
