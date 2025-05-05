import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:elastik_management/models/user.dart';
import 'package:elastik_management/utils/auth_provider.dart';
import 'package:elastik_management/screens/home_screen.dart';
import 'package:elastik_management/screens/login_screen.dart';
import 'package:elastik_management/screens/news_screen.dart';
import 'package:elastik_management/screens/stock_screen.dart';
import 'package:elastik_management/screens/wfo_schedule_screen.dart';
import 'package:elastik_management/screens/contribution_screen.dart';
import 'package:elastik_management/utils/constants.dart';
import 'package:elastik_management/screens/splash_screen.dart';

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
  int _currentIndex = 0; // Index for bottom navigation (0=Home)

  bool _showProfilePopup = false;
  final List<String> _screenTitles = [
    'Elastik Internal',
    'News Remainder',
    'Office Snack Stock',
    // 'Event',
    'WFO Schedule',
    'Community Contributions',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _getCurrentScreen() {
    // Create screens on demand instead of storing them
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const NewsScreen();
      case 2:
        return const StockScreen();
      case 3:
        return const WfoScheduleScreen();
      case 4:
        return const ContributionScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildProfilePopup(User? user) {
    return Positioned(
      top: 60,
      right: 10,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 250,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(user?.name ?? 'User Name'),
                subtitle: Text(user?.email ?? 'user@example.com'),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(user?.designation ?? 'Designation'),
              ),
              const Divider(),
              TextButton.icon(
                onPressed: () {
                  // Handle edit profile action
                  print('Edit profile tapped');
                  setState(() {
                    _showProfilePopup = false;
                  });
                },
                icon: const Icon(Icons.edit, color: AppColors.primaryColor),
                label: const Text(
                  'Edit Profile',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  context.read<AuthProvider>().logout();
                  setState(() {
                    _showProfilePopup = false;
                  });
                },
                icon: const Icon(Icons.logout, color: AppColors.primaryColor),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(_screenTitles[_currentIndex]),
            backgroundColor: AppColors.primaryColor,
            actions: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showProfilePopup = !_showProfilePopup;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: _buildUserAvatar(user?.imageUrl),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _getCurrentScreen(),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            selectedItemColor: AppColors.primaryColor,
            unselectedItemColor: AppColors.secondaryColor,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                label: 'News',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.fastfood),
                label: 'Stock',
              ),
              // BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Event'),
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
        ),
        if (_showProfilePopup) ...[
          // First add the overlay that covers the whole screen to handle taps outside
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showProfilePopup = false;
                });
              },
              // Make it transparent
              child: Container(color: Colors.transparent),
            ),
          ),
          // Then add the popup on top
          _buildProfilePopup(user),
        ],
      ],
    );
  }

  Widget _buildUserAvatar(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      // Attempt to load the image from the network
      try {
        return CircleAvatar(
          backgroundImage: NetworkImage(imageUrl),
          onBackgroundImageError: (exception, stackTrace) {
            // Handle image loading errors by showing a default icon
            print('Error loading image: $exception');
          },
        );
      } catch (e) {
        // Handle any other errors that might occur (e.g., invalid URL)
        print('Error with image URL: $e');
        return const CircleAvatar(child: Icon(Icons.person));
      }
    } else {
      // If there's no image URL, show the default icon
      return const CircleAvatar(child: Icon(Icons.person));
    }
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
