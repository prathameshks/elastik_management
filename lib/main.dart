import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elastik_management/utils/auth_provider.dart';
import 'package:elastik_management/screens/home_screen.dart';
import 'package:elastik_management/screens/login_screen.dart';
import 'package:elastik_management/screens/news_screen.dart';
import 'package:elastik_management/screens/stock_screen.dart';
import 'package:elastik_management/screens/event_screen.dart';
import 'package:elastik_management/screens/wfo_schedule_screen.dart';
import 'package:elastik_management/screens/contributions_screen.dart';
import 'package:elastik_management/utils/constants.dart';
import 'package:elastik_management/screens/splash_screen.dart'; // Ensure this is correctly imported

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) { // Build method remains the same but is now inside MyApp
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(), // Provide AuthProvider at the root
      child: MaterialApp(
        title: 'Elastik Management',
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.secondaryColor),
          scaffoldBackgroundColor: AppColors.backgroundColor,
        ),
        home: const SplashScreen(), // Correctly set the SplashScreen as the home
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    const NewsScreen(),
    const StockScreen(),
    const EventScreen(),
    const WfoScheduleScreen(),
    const ContributionsScreen(),
  ];

  final List<String> _screenTitles = [
    'Home', 'News', 'Stock', 'Event', 'WFO Schedule', 'Contributions'
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_screenTitles[_currentIndex]),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Access AuthProvider and call logout
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.secondaryColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Stock',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'WFO'),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Contributions'),
        ],
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
    return isLoggedIn ? const MainScreen() :  LoginScreen();
  }
}
