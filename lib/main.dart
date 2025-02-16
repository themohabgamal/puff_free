import 'package:flutter/material.dart';
import 'package:puff_free/const.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'splash_screen.dart';
import 'page1.dart';
import 'page2.dart';
import 'page3.dart';

void main() {
  runApp(const PuffFreeApp());
}

class PuffFreeApp extends StatelessWidget {
  const PuffFreeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Puff Free',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Nunito', // Setting the default font
      ),
      home: const SplashScreen(), // Initial page transitioning to HomeScreen
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Pages for navigation
  final List<Widget> _pages = [
    const Page1(),
    const Page2(),
    const Page3(),
  ];

  // Change page on BottomNavigationBar tap
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // floatingActionButton: FloatingActionButton(
      //   backgroundColor: Colors.blueAccent,
      //   child: const Icon(Icons.reset_tv),
      //   onPressed: () async {
      //     final prefs = await SharedPreferences.getInstance();
      //     await prefs.setBool('isFirstTime', true);
      //   },
      // ),
      extendBodyBehindAppBar: true,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SizedBox(
      height: 75,
      child: SlidingClippedNavBar(
        backgroundColor: kPrimaryColor.withOpacity(0.9),
        onButtonPressed: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        iconSize: 35,
        fontSize: 15,
        activeColor: Colors.white,
        inactiveColor: Colors.white,
        selectedIndex: _selectedIndex,
        barItems: [
          BarItem(
            icon: Icons.home,
            title: 'Home',
          ),
          BarItem(
            icon: Icons.analytics,
            title: 'Usage',
          ),
          BarItem(
            icon: Icons.flag,
            title: 'Quit Plan',
          ),
        ],
      ),
    );
  }
}
