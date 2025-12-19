import 'package:flutter/material.dart';
import 'package:glowmate_app/main.dart';
import 'screens/auth/login.dart'; // For logout navigation
import 'screens/routine/routine_tracker.dart';
import 'screens/product/product_browser.dart';
import 'screens/makeup/makeup.dart';
import 'screens/profile/profile.dart';
import 'utils/constants.dart'; // Our colors and constants

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 2;

  // --- Logout Logic ---
  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted) {
      // Navigate user back to the Login Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows body to go behind the bottom nav bar
      body: Container(
        // Use your main background gradient
        decoration: const BoxDecoration(gradient: BackgroundGradient),
        child: SafeArea(
          bottom: false, // Let content flow behind the bottom nav
          child: Column(
            children: [
              const SizedBox(height: 10),
              
              // --- 1. HEADER SECTION (Logo + Quote) ---
              _buildHeader(),

              const SizedBox(height: 25),

              // --- 2. SCROLLABLE CARD LIST ---
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  children: [
                    // Card 1: Routine Tracker (Image Left, Blue Glow)
                    _buildFeatureCard(
                      title: "Routine\nTracker",
                      imageAsset: 'assets/images/SkincareRoutine.png', 
                      glowColor: const Color(0xFFC8EAFF), // Light Blue
                      isImageLeft: true,
                      icon: Icons.trending_up,
                      onTap: () { 
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const RoutineTracker()),
                        ); 
                      },
                    ),
                    const SizedBox(height: 20),

                    // Card 2: Product Browser (Image Right, Pink Glow)
                    _buildFeatureCard(
                      title: "Product\nBrowser",
                      imageAsset: 'assets/images/SkincareProducts.png',
                      glowColor: const Color(0xFFFFD0E2), // Light Pink
                      isImageLeft: false, // Image on Right
                      icon: Icons.search,
                      onTap: () { 
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (context) => const ProductBrowser()),
                        ); 
                      },
                    ),
                    const SizedBox(height: 20),

                    // Card 3: Makeup Looks (Image Left, Cyan Glow)
                    _buildFeatureCard(
                      title: "Makeup\nLooks",
                      imageAsset: 'assets/images/Makeup.png',
                      glowColor: Colors.cyan.shade100, // Soft Cyan
                      isImageLeft: true,
                      icon: Icons.face,
                      onTap: () { 
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const Makeup()), 
                        );
                      },
                    ),
                    // Extra space at bottom so cards aren't hidden by nav bar
                    const SizedBox(height: 100), 
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // --- 3. CUSTOM BOTTOM NAVIGATION ---
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  // --- Big image feature card ---
  Widget _buildFeatureCard({
    required String title,
    required String imageAsset,
    required Color glowColor,
    required bool isImageLeft,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    // Height of the white card background
    const double cardHeight = 140; 
    // How much the image should stick out the top
    const double imageOverflow = 30; 

    return GestureDetector(
      onTap: onTap,
      // 1. The Main Stack must allow overflow
      child: Stack(
        clipBehavior: Clip.none, // <--- CRITICAL: Allows image to go outside
        alignment: Alignment.bottomCenter,
        children: [
          // --- LAYER 1: The White Card Background ---
          Container(
            height: cardHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Stack(
                children: [
                  // Glow Gradient
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            glowColor.withOpacity(0.9),
                            Colors.white.withOpacity(0.1)
                          ],
                          begin: isImageLeft ? Alignment.centerLeft : Alignment.centerRight,
                          end: isImageLeft ? Alignment.centerRight : Alignment.centerLeft,
                        ),
                      ),
                    ),
                  ),
                  
                  // Text Content
                  // We add padding to avoid overlapping the image area
                  Row(
                    children: [
                      // If image is left, empty space is left, text is right
                      Expanded(
                        flex: isImageLeft ? 4 : 5, // Adjust space for image
                        child: isImageLeft 
                          ? const SizedBox() 
                          : _buildTextContent(title, true, icon), 
                      ),
                      // If image is right, empty space is right, text is left
                      Expanded(
                        flex: isImageLeft ? 5 : 4, 
                        child: isImageLeft 
                          ? _buildTextContent(title, false, icon) 
                          : const SizedBox(), 
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- LAYER 2: The Pop-Out Image ---
          Positioned(
            // Negative top allows it to stick out
            top: -imageOverflow, 
            bottom: 0, 
            // Position left or right based on config
            left: isImageLeft ? 10 : null,
            right: isImageLeft ? null : 10,
            width: 150, // Fixed width for the image container
            child: Image.asset(
              imageAsset,
              // fitHeight will make it tall, alignment ensures it sits at the bottom
              fit: BoxFit.fitHeight, 
              alignment: Alignment.bottomCenter, 
            ),
          ),
        ],
      ),
    );
  }

  // Helper for the text part to keep the main widget clean
  Widget _buildTextContent(String title, bool isLeftAligned, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: isLeftAligned ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Icon(icon, size: 24, color: TextColor),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: isLeftAligned ? TextAlign.left : TextAlign.right,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TextColor,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }

  // --- HEADER WIDGET ---
   Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.6), shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
            child: const Icon(Icons.spa, color: PrimaryAccent, size: 30),
          ),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text("Glowmate always be", style: TextStyle(fontFamily: 'Cursive', fontSize: 16, fontWeight: FontWeight.w600, color: TextColor)),
              Text("here with you", style: TextStyle(fontFamily: 'Cursive', fontSize: 16, fontWeight: FontWeight.w600, color: TextColor)),
            ],
          )
        ],
      ),
    );
  }

  // --- Bottom Nav ---
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