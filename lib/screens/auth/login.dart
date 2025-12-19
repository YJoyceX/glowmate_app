import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register.dart'; // Navigate to registration
import 'skin_analysis.dart'; // Navigate to skin analysis
import '../../main.dart'; //Imports supabase client
import '../../main_page.dart'; // Navigate to main dashboard
import '../../utils/constants.dart'; // Shared colors


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false;

  // --- Core Login Logic (FR1) ---
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Sign in
      final AuthResponse res = await supabase.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      final User user = res.user!;

      final data = await supabase
          .from('profiles')
          .select('skintype') // Select only the skinType column
          .eq('id', user.id)    // Where the id matches the logged-in user's id
          .maybeSingle();           // Get a single row

      if (mounted) {
        final skintype = data?['skintype'];

        // 3. Conditional Navigation
        if (skintype != null && skintype.toString() != 'Unset') {
          // Profile is complete: Go to Main Dashboard
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        } else {
          // First time login or incomplete profile: Go to Skin Analysis
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const SkinAnalysis()),
          );
        }
      }
    } on AuthException catch (e) {
      setState(() { _errorMessage = e.message; });
    } catch (e) {
      setState(() { _errorMessage = 'An unexpected error occurred. Check RLS policies.'; });
      print('Login Error: $e');
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  // --- UI Build ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: BackgroundGradient), 
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 100),
                const CircleAvatar(radius: 60, backgroundColor: Colors.white, child: Icon(Icons.spa_outlined, size: 40, color: PrimaryAccent)),
                const SizedBox(height: 40),
                if (_errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 15.0), child: Text(_errorMessage!, style: const TextStyle(color: ErrorRed, fontWeight: FontWeight.bold))),
                Form(key: _formKey, child: _buildLoginForm()),
                const SizedBox(height: 20),
                TextButton(onPressed: _isLoading ? null : () {Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Register()));}, child: const Text("Don't have an account? Register", style: TextStyle(color: TextColor, fontWeight: FontWeight.w600))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(20.0), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15)]),
      child: Column(
        children: <Widget>[
          TextFormField(controller: _email, decoration: _inputDecoration('Email', Icons.email_outlined), keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email.' : null),
          const SizedBox(height: 15),
          TextFormField(controller: _password, decoration: _inputDecoration('Password', Icons.lock_outline), obscureText: true, validator: (v) => (v == null || v.length < 6) ? 'Password must be 6+ characters.' : null),
          const SizedBox(height: 30),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _isLoading ? null : _handleLogin, child: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }
  
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label, prefixIcon: Icon(icon, color: PrimaryAccent), filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: PrimaryAccent, width: 2.0)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: ErrorRed, width: 1.0)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: ErrorRed, width: 2.0)),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    );
  }
}