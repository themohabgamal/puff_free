import 'package:flutter/material.dart';
import 'package:puff_free/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'social_proof.dart'; // Ensure this file exists

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // _checkIfFirstTime();
  }

  // Future<void> _checkIfFirstTime() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final isFirstLaunch = prefs.getBool('isFirstLaunchOnboarding') ?? true;

  //   if (!isFirstLaunch && mounted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const SocialProof()),
  //     );
  //   } else {
  //     await prefs.setBool('isFirstLaunchOnboarding', false);
  //   }
  // }

  void _onPageChanged(int page) {
    setState(() => _currentPage = page);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _controller,
              onPageChanged: _onPageChanged,
              children: [
                _buildOnboardingPage(
                  title: 'Puff Free',
                  subtitle: 'Puff Monitoring',
                  description:
                      'Monitor your puffs and nicotine consumption. Visualize your progress over time.',
                  image: 'assets/images/data-analysis.png',
                ),
                _buildOnboardingPage(
                  title: 'Puff Free',
                  subtitle: 'Your Quit Plan',
                  description:
                      'Create your own customized quit plan that will guide you through the journey of quitting.',
                  image: 'assets/images/checklist.png',
                ),
                _buildOnboardingPage(
                  title: 'Puff Free',
                  subtitle: 'Help Us Make The World Healthier',
                  description:
                      'Your app store review helps spread the word and grow the Puff Free community.',
                  image: 'assets/images/rate.png',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) => _buildDot(index)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: ElevatedButton(
              onPressed: _onButtonPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _currentPage == 2 ? Colors.green : kPrimaryColor,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                elevation: 5,
                shadowColor: kPrimaryColor.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                textStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 18),
              ),
              child: Text(_currentPage == 2 ? 'Rate Us' : 'Next'),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _onButtonPressed() {
    if (_currentPage == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SocialProof()),
      );
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildOnboardingPage({
    required String title,
    required String subtitle,
    required String description,
    required String image,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTitle(title),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _currentPage == 0 ? 1.0 : 0.8,
            duration: const Duration(seconds: 1),
            child: Image.asset(image, height: 200),
          ),
          const SizedBox(height: 20),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 20,
              color: kPrimaryColor,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'Nunito',
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return RichText(
      text: const TextSpan(
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
          shadows: [
            Shadow(color: Colors.black26, offset: Offset(1, 1), blurRadius: 2)
          ],
        ),
        children: [
          TextSpan(
            text: 'Puff ',
            style: TextStyle(color: Colors.black),
          ),
          TextSpan(
            text: 'Free',
            style: TextStyle(color: kPrimaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 10,
      width: _currentPage == index ? 16 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.blue : Colors.grey,
        borderRadius: BorderRadius.circular(5),
        boxShadow: _currentPage == index
            ? [
                BoxShadow(
                    color: kPrimaryColor.withOpacity(0.5),
                    blurRadius: 5,
                    spreadRadius: 1)
              ]
            : [],
      ),
    );
  }
}
