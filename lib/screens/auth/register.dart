import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login.dart'; // To navigate back
import '../../main.dart';
import '../../utils/constants.dart'; // Our colors


class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _selectedGender;
  String? _selectedAge;
  String? _errorMessage;
  bool _isLoading = false;

  final List<String> _gender = ['Female', 'Male'];
  final List<String> _age = ['< 18', '18 - 24', '25 - 34', '35 - 49', '50+'];

  // --- Core Backend Registration Logic (FR1) ---
  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { 
      _isLoading = true;
      _errorMessage = null; 
    });

    try {
      final email = _email.text.trim();
      final password = _password.text.trim();

      final userData = {
        'name': _name.text.trim(),
        'gender': _selectedGender,
        'ageRange': _selectedAge,
        // 'skinType' will use the 'Unset' default value from the database
      };

      // 3. Sign up the user AND insert their profile data
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: userData, // This data is passed to the 'profiles' table!
      );

      if (mounted) {
        if (res.user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registration completed! Please log in.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Login()),
          );
        }
      }
    } on AuthException catch (e) {
      setState(() { _errorMessage = e.message; });
    } catch (e) {
      setState(() { _errorMessage = 'An unexpected error occurred.'; });
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

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
                const SizedBox(height: 50),
                const CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_add_alt_1_outlined, size: 40, color: PrimaryAccent),
                ),
                const SizedBox(height: 40),

                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 15.0),
                    child: Text(_errorMessage!, style: const TextStyle(color: ErrorRed, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ),

                Form(
                  key: _formKey,
                  child: _buildFormCard(),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: _isLoading ? null : () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  child: const Text("Already have an account? Log In", style: TextStyle(color: TextColor, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(25.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: <Widget>[
          _buildTextField(controller: _name, label: 'Name', icon: Icons.person_outline, validator: (v) => v!.isEmpty ? 'Please enter your name.' : null),
          _buildSpace(),
          _buildTextField(controller: _email, label: 'Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email.' : null),
          _buildSpace(),
          _buildDropdownField(value: _selectedGender, hint: 'Gender', icon: Icons.wc_outlined, items: _gender, onChanged: (v) => setState(() => _selectedGender = v)),
          _buildSpace(),
          _buildDropdownField(value: _selectedAge, hint: 'Age', icon: Icons.cake_outlined, items: _age, onChanged: (v) => setState(() => _selectedAge = v)),
          _buildSpace(),
          _buildTextField(controller: _password, label: 'Password', icon: Icons.lock_outline, isPassword: true, validator: (v) => (v == null || v.length < 6) ? 'Password must be 6+ characters.' : null),
          _buildSpace(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleRegistration,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- Reusable Form Widgets ---
  Widget _buildTextField({required TextEditingController controller, required String label, required IconData icon, TextInputType keyboardType = TextInputType.text, bool isPassword = false, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller, obscureText: isPassword, keyboardType: keyboardType, validator: validator,
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildDropdownField({required String? value, required String hint, required IconData icon, required List<String> items, required void Function(String?) onChanged}) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(hint),
      decoration: _inputDecoration(hint, icon).copyWith(labelText: null), // Dropdowns use 'hint' not 'label'
      items: items.map((item) => DropdownMenuItem<String>(value: item, child: Text(item))).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select an option.' : null,
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: PrimaryAccent),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: PrimaryAccent, width: 2.0)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: ErrorRed, width: 1.0)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: const BorderSide(color: ErrorRed, width: 2.0)),
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
    );
  }

  Widget _buildSpace({double height = 15}) => SizedBox(height: height);
}