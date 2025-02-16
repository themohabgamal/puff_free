import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'survey.dart'; // Ensure this file exists

class SocialProof extends StatefulWidget {
  const SocialProof({super.key});

  @override
  State<SocialProof> createState() => _SocialProofState();
}

class _SocialProofState extends State<SocialProof> {
  @override
  void initState() {
    super.initState();
    // _checkIfFirstTime();
  }

  // Future<void> _checkIfFirstTime() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final isFirstLaunch = prefs.getBool('isFirstLaunchSocialProof') ?? true;

  //   if (!isFirstLaunch && mounted) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const Survey()),
  //     );
  //   } else {
  //     await prefs.setBool('isFirstLaunchSocialProof', false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 30),
              _buildTextSection(),
              const SizedBox(height: 40),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(90),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: const CircleAvatar(
        radius: 80,
        backgroundImage: AssetImage('assets/images/logo_circle.png'),
      ),
    );
  }

  Widget _buildTextSection() {
    return const Column(
      children: [
        Text(
          'Join Our Thriving Community',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'A supportive and engaged community',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Nunito',
            color: Colors.black54,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 16),
        Text(
          'Connect with others focused on wellness and smart choices.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Nunito',
            color: Colors.black54,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Survey()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 3,
        shadowColor: Colors.black26,
        textStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      child: const Text(
        'Continue',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
