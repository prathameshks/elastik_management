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
  Widget build(BuildContext context) {
    // Build method remains the same but is now inside MyApp
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(), // Provide AuthProvider at the root
      child: MaterialApp(
        title: 'Elastik Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primaryColor,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            secondary: AppColors.secondaryColor,
          ),
          scaffoldBackgroundColor: AppColors.backgroundColor,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const AuthWrapper(),
        },
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
  bool _showHomeScreen = true; // Initially show home screen
  int _bottomNavIndex =
      0; // Index for bottom navigation (0=News after removing Home)

  final List<String> _screenTitles = [
    'Home',
    'News',
    'Stock',
    'Event',
    'WFO Schedule',
    'Contributions',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _bottomNavIndex = index;
      _showHomeScreen = false;
    });
  }

  void _goToHome() {
    setState(() {
      _showHomeScreen = true;
    });
  }

  Widget _getCurrentScreen() {
    if (_showHomeScreen) {
      return const HomeScreen();
    }
    
    switch (_bottomNavIndex) {
      case 0:
        return const NewsScreen();
      case 1:
        return const StockScreen();
      case 2:
        return const EventScreen();
      case 3:
        return const WfoScheduleScreen();
      case 4:
        return const ContributionsScreen();
      default:
        return const NewsScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Show home button only when not on home screen
        leading: !_showHomeScreen
            ? IconButton(icon: const Icon(Icons.home), onPressed: _goToHome)
            : null,
        title: Text(_screenTitles[_showHomeScreen ? 0 : _bottomNavIndex + 1]),
        backgroundColor: AppColors.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
      body: _getCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _bottomNavIndex,
        onTap: _onTabTapped,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.secondaryColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.fastfood), label: 'Stock'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'WFO',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volunteer_activism),
            label: 'Contributions',
          ),
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
    return isLoggedIn ? const MainScreen() : LoginScreen();
  }
}
