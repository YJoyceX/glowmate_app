import 'package:flutter/material.dart';
import 'package:glowmate_app/main.dart'; // Ensure supabase client is imported
import 'package:glowmate_app/screens/makeup/makeup.dart';
import 'package:glowmate_app/screens/product/product_browser.dart';
import 'package:glowmate_app/screens/routine/routine_tracker.dart';
import '../../utils/constants.dart';
import '../auth/login.dart';
import '../auth/skin_analysis.dart';
import 'package:glowmate_app/main_page.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isLoading = true;
  
  // Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  // Dropdown values
  String? _gender;
  String? _ageRange;
  
  // Skin Data
  String _skinType = 'Loading...';
  String _skinConcerns = 'Loading...';
  
  // Navigation index
  int _selectedIndex = 2;

  // Options
  final List<String> _genderOptions = ['Female', 'Male', 'Prefer not to say'];
  final List<String> _ageRanges = ['< 18', '18 - 24', '25 - 34', '35 - 49', '50+'];

  @override
  void initState() {
    super.initState();
    _getProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // --- 1. Fetch Profile Data ---
  Future<void> _getProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      _emailController.text = user.email ?? '';

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _nameController.text = data['name'] ?? '';
          
          // Gender Match
          String? dbGender = data['gender'];
          if (_genderOptions.contains(dbGender)) {
             _gender = dbGender;
          } else {
             _gender = null; 
          }

          // Age Range Match (Check both camelCase and lowercase keys just in case)
          String? dbAge = data['ageRange'] ?? data['agerange'];
          if (_ageRanges.contains(dbAge)) {
             _ageRange = dbAge;
          } else {
             _ageRange = null; 
          }

          // Skin Type Match
          _skinType = (data['skinType'] ?? data['skintype']) ?? 'Unset';
          
          // Skin Concerns Match (Handle List to String conversion)
          final dynamic concernsData = data['skinConcerns'] ?? data['skinconcerns'];
          if (concernsData is List) {
            // Join the list into a comma-separated string
            _skinConcerns = concernsData.join(', '); 
          } else if (concernsData is String) {
            _skinConcerns = concernsData; // If it's stored as a simple string
          } else {
            _skinConcerns = 'None selected';
          }
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        print("Profile Fetch Error: $e"); // Debug print
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: $e'), backgroundColor: ErrorRed),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // --- 2. Update Profile Data ---
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return;

      await supabase.from('profiles').update({
        'name': _nameController.text.trim(),
        'gender': _gender,
        'agerange': _ageRange, // Use consistent casing
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e'), backgroundColor: ErrorRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- 3. Sign Out ---
  Future<void> _signOut() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Login()),
        (route) => false,
      );
    }
  }

  // --- 4. Retake Analysis ---
  void _retakeAnalysis() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SkinAnalysis()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Edit Profile", style: TextStyle(color: TextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
        automaticallyImplyLeading: false, 
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: PrimaryAccent))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // --- PROFILE PICTURE ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: PrimaryAccent.withOpacity(0.2),
                          child: Text(
                            _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : "U",
                            style: const TextStyle(fontSize: 40, color: PrimaryAccent, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(color: PrimaryAccent, shape: BoxShape.circle),
                              child: const Icon(Icons.edit, size: 16, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- PERSONAL DETAILS FORM ---
                  _buildSectionTitle("Personal Details"),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: _nameController,
                    decoration: _inputDecoration("Full Name", Icons.person_outline),
                  ),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: _inputDecoration("Email", Icons.email_outlined).copyWith(
                      fillColor: Colors.grey.shade100,
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  DropdownButtonFormField<String>(
                    value: _gender,
                    decoration: _inputDecoration("Gender", Icons.wc),
                    items: _genderOptions.map((String val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (val) => setState(() => _gender = val),
                  ),
                  const SizedBox(height: 15),
                  
                  DropdownButtonFormField<String>(
                    value: _ageRange,
                    decoration: _inputDecoration("Age Range", Icons.cake_outlined),
                    items: _ageRanges.map((String val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (val) => setState(() => _ageRange = val),
                  ),

                  const SizedBox(height: 30),

                  // --- SKIN PROFILE SECTION ---
                  _buildSectionTitle("My Skin"),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: PrimaryAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: PrimaryAccent.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        // Row for Skin Type
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Skin Type", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(_skinType, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TextColor)),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: _retakeAnalysis,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: PrimaryAccent,
                                elevation: 0,
                                side: const BorderSide(color: PrimaryAccent),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                              child: const Text("Retake"),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 0.5),
                        // Row for Skin Concerns
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Concerns", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  // Use Text with maxLines to handle long lists of concerns
                                  Text(
                                    _skinConcerns, 
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: TextColor),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // --- SAVE / LOGOUT ---
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Save Changes", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: ErrorRed),
                    label: const Text("Log Out", style: TextStyle(color: ErrorRed, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  // --- Helpers ---
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TextColor)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: PrimaryAccent),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: PrimaryAccent, width: 2)),
    );
  }

  Widget _buildCustomBottomNavBar() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 25, left: 20, right: 20),
      child: Container(
        height: 65,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: Colors.black, width: 1.2),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavIcon(0, Icons.show_chart),
            _buildNavIcon(1, Icons.search),
            _buildHomeIcon(),
            _buildNavIcon(3, Icons.sentiment_satisfied_alt),
            _buildNavIcon(4, Icons.person_outline),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);

        if (index == 0) { // Routine Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const RoutineTracker()),
         );
      } else if (index == 1) { // Product Browser Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const ProductBrowser()),
         );
      } else if (index == 2) { // Main Page Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const MainPage()),
         );
      } else if (index == 3) { // Makeup Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const Makeup()),
         );
      } else if (index == 4) { // Profile Icon Index
         Navigator.of(context).push(
           MaterialPageRoute(builder: (context) => const Profile()),
         );
      }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.black, width: 1.0)),
        child: Icon(icon, size: 20, color: TextColor),
      ),
    );
  }

  Widget _buildHomeIcon() {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = 2),
      child: Container(
        width: 48, height: 48,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: const Icon(Icons.home_filled, color: Colors.white, size: 26),
      ),
    );
  }
}