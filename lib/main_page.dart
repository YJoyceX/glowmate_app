import 'package:flutter/material.dart';
import 'package:glowmate_app/main.dart';
import 'screens/auth/login.dart';
import 'utils/constants.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  // Function to handle logging out the user
  Future<void> _handleLogout(BuildContext context) async {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GlowMate Dashboard', style: TextStyle(color: Colors.white)),
        backgroundColor: PrimaryAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _handleLogout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: PrimaryAccent,
            ),
            const SizedBox(height: 20),
            const Text(
              'Analysis Complete! Welcome to GlowMate.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: TextColor),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your routines and product suggestions are ready!',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 40),
            // Placeholder for main navigation button
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to Routine Tracker or Product Browser
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting the Product Browser...'))
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: PrimaryAccent, 
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text(
                'Start Your Routine',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}