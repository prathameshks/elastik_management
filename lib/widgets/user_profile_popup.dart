import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../screens/login_screen.dart';
import '../models/user.dart';
// import '../utils/auth_provider.dart';

class UserProfilePopup extends StatelessWidget {
  final User user;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  const UserProfilePopup({
    Key? key,
    required this.user,
    required this.onEditProfile,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(user.email),
            const SizedBox(height: 4),
            Text(user.designation),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onEditProfile,
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onLogout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}