import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login.dart'; // Starts the authentication flow
import 'utils/constants.dart'; // Imports shared colors like kPrimaryAccent
// NOTE: You must run 'flutterfire configure' to generate this file.

Future<void> main() async {
  // Ensure Flutter is ready
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://maqzjovpmeehczvvycgz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1hcXpqb3ZwbWVlaGN6dnZ5Y2d6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI0MTI0MDMsImV4cCI6MjA3Nzk4ODQwM30.VQvdn4p5QSFcXkujOAJagdKGmWL5u-ZHGT8AP1jfVVc',
  );
  
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlowMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Set the primary color scheme using the Rose Gold accent
        colorScheme: ColorScheme.fromSeed(seedColor: PrimaryAccent), 
        useMaterial3: true,
        // Global button style for the black/dark buttons used in auth flow
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: TextColor, // Black button background
            foregroundColor: Colors.white, // White text
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      // App starts on the Login Screen
      home: const Login(), 
    );
  }
}