import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'onboarding.dart'; // تأكد من إنشاء ملف Onboarding لاحقاً

class SplashScreen1 extends StatefulWidget {
  const SplashScreen1({super.key});

  @override
  SplashScreen1State createState() => SplashScreen1State();
}

class SplashScreen1State extends State<SplashScreen1>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // _checkFirstTime();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  // Future<void> _checkFirstTime() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final isFirstTime = prefs.getBool('isFirstTime') ?? true;

  //   if (!isFirstTime) {
  //     _navigateToOnboarding();
  //   } else {
  //     await prefs.setBool('isFirstTime', false);
  //   }
  // }

  void _navigateToOnboarding() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const Onboarding()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // الشعار مع الحلقات النابضة في المنتصف
          Expanded(
            flex: 3,
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildPulseCircle(100),
                _buildPulseCircle(140),
                _buildPulseCircle(180),
                const CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(
                      'assets/images/logo_circle.png'), // تأكد من مسار الصورة
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // النصوص في المنتصف
          const Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Congratulations!',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                    color: Colors.blueAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Your Journey to a Clearer Tomorrow!",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black54,
                      fontFamily: 'Nunito',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // زر "Get Started" في الأسفل
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: ElevatedButton(
                  onPressed: _navigateToOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.blueAccent),
                    elevation: 5,
                    shadowColor: Colors.blueAccent.withOpacity(0.3),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle:
                        const TextStyle(fontFamily: 'Nunito', fontSize: 18),
                  ),
                  child: const Text('Get Started'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // بناء الحلقات النابضة
  Widget _buildPulseCircle(double radius) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blueAccent.withOpacity(0.2),
        ),
      ),
    );
  }
}
