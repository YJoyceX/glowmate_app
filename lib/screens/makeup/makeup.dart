import 'package:flutter/material.dart';
import 'package:glowmate_app/main.dart';
import '../auth/login.dart'; // For logout navigation
import '../../utils/constants.dart';
import '../../main_page.dart';
import '../product/product_browser.dart';
import '../profile/profile.dart';
import '../routine/routine_tracker.dart' show RoutineTracker;
import 'makeup_detail.dart';
import 'simple_makeup_detail.dart';
import 'favorite_makeup.dart';

// Mock data for tutorials/looks
class MakeupStepData {
  final int number;
  final String title;
  final String imageAsset;
  final String colorCode;
  final double top;
  final double left;

  MakeupStepData({
    required this.number,
    required this.title,
    required this.imageAsset,
    required this.colorCode,
    required this.top,
    required this.left,
  });
}

// Main Model for a Look
class MakeupLook {
  final String title;
  final String category;
  final String imageAsset;
  final Color bgColor;
  final List<MakeupStepData> steps; // Non-empty for Featured looks
  final String description; // Used for Simple view
  final bool isFullLook;
  bool isFavorite;

  MakeupLook({
    required this.title,
    required this.category,
    required this.imageAsset,
    required this.bgColor,
    this.steps = const [], 
    this.description = "Follow the image guide to recreate this look.",
    this.isFullLook = false,
    this.isFavorite = false,
  });
}

final List<String> kCategories = ['All', 'Eyeshadow', 'Lips', 'Eyebrows', 'Eyeliner'];

final List<MakeupLook> kAllLooks = [

  MakeupLook(
    title: "Everyday Natural", 
    category: 'Full Look', 
    imageAsset: "assets/images/everyday_natural.jpg", 
    bgColor: const Color(0xFFFFE4E1), 
    isFullLook: true, 
    steps: [
      MakeupStepData(
        number: 1, 
        title: "Contour", 
        imageAsset: "assets/images/everyday_natural_parts/e_n_contour.png", 
        colorCode: "Contour: Cinereous",
        top: 0.35, 
        left: 0.5
        ),

        MakeupStepData(
        number: 2, 
        title: "Highlight", 
        imageAsset: "assets/images/everyday_natural_parts/e_n_highlight.png", 
        colorCode: "Highlight: Off White",
        top: 0.3, 
        left: 0.45
        ),

        MakeupStepData(
        number: 3, 
        title: "Blush", 
        imageAsset: "assets/images/everyday_natural_parts/e_n_blush.png", 
        colorCode: "Blush: Voyage",
        top: 0.4, 
        left: 0.66
        ),

        MakeupStepData(
        number: 4, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/everyday_natural_parts/e_n_eyeshadow1.png", 
        colorCode: "Eyeshadow: Voyage",
        top: 0.31, 
        left: 0.3
        ),

        MakeupStepData(
        number: 5, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/everyday_natural_parts/e_n_eyeshadow2.png", 
        colorCode: "Eyeshadow: Americano Coffee",
        top: 0.33, 
        left: 0.36
        ),

        MakeupStepData(
        number: 6, 
        title: "Lips", 
        imageAsset: "assets/images/everyday_natural_parts/e_n_lips.png", 
        colorCode: "Lips: Spicy Mix",
        top: 0.48, 
        left: 0.5
        )
      ]
  ),

  MakeupLook(
    title: "Sweet Grunge", 
    category: 'Full Look', 
    imageAsset: "assets/images/sweet_grunge.jpg", 
    bgColor: const Color(0xFFFFE4E1), 
    isFullLook: true, 
    steps: [
      MakeupStepData(
        number: 1, 
        title: "Contour", 
        imageAsset: "assets/images/sweet_grunge_parts/s_g_contour.png", 
        colorCode: "Countour: Cinereous",
        top: 0.37, 
        left: 0.55
        ),

        MakeupStepData(
        number: 2, 
        title: "Highlight", 
        imageAsset: "assets/images/sweet_grunge_parts/s_g_highlight1.png", 
        colorCode: "Highlight: Off White",
        top: 0.4, 
        left: 0.5
        ),

        MakeupStepData(
        number: 3, 
        title: "Blush", 
        imageAsset: "assets/images/sweet_grunge_parts/s_g_blush.png", 
        colorCode: "Blush: Charm",
        top: 0.4, 
        left: 0.7
        ),

        MakeupStepData(
        number: 4, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/sweet_grunge_parts/s_g_eyeshadow1.png", 
        colorCode: "Eyeshadow: Campfire",
        top: 0.32, 
        left: 0.25
        ),

        MakeupStepData(
        number: 5, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/sweet_grunge_parts/s_g_eyeshadow2.png", 
        colorCode: "Eyeshadow: Rosewood Rouge",
        top: 0.33, 
        left: 0.36
        ),

        MakeupStepData(
        number: 6, 
        title: "Eyeliner", 
        imageAsset: "assets/images/sweet_grunge_parts/s_g_eyeliner.png", 
        colorCode: "Eyeliner: Black",
        top: 0.33, 
        left: 0.75
        ),

        MakeupStepData(
        number: 7, 
        title: "Highlight", 
        imageAsset: "assets/images/sweet_grunge_parts/s_g_highlight2.png", 
        colorCode: "Highlight: Off White",
        top: 0.37, 
        left: 0.45
        ),

        MakeupStepData(
        number: 8, 
        title: "Lips", 
        imageAsset: "assets/images/sweet_grunge_parts/s_g_lips.png", 
        colorCode: "Lips: Au Chico",
        top: 0.55, 
        left: 0.5
        )
      ]
  ),

  MakeupLook(
    title: "Snow Elf", 
    category: 'Full Look', 
    imageAsset: "assets/images/snow_elf.jpg", 
    bgColor: const Color(0xFFFFE4E1), 
    isFullLook: true, 
    steps: [
      MakeupStepData(
        number: 1, 
        title: "Contour", 
        imageAsset: "assets/images/snow_elf_parts/s_e_contour.png", 
        colorCode: "BB Cream",
        top: 0.5, 
        left: 0.6
        ),

        MakeupStepData(
        number: 2, 
        title: "Highlight", 
        imageAsset: "assets/images/snow_elf_parts/s_e_highlight.png", 
        colorCode: "BB Cream",
        top: 0.4, 
        left: 0.55
        ),

        MakeupStepData(
        number: 3, 
        title: "Blush", 
        imageAsset: "assets/images/snow_elf_parts/s_e_blush.png", 
        colorCode: "BB Cream",
        top: 0.5, 
        left: 0.9
        ),

        MakeupStepData(
        number: 4, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/snow_elf_parts/s_e_eyeshadow1.png", 
        colorCode: "BB Cream",
        top: 0.25, 
        left: 0.25
        ),

        MakeupStepData(
        number: 5, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/snow_elf_parts/s_e_eyeshadow2.png", 
        colorCode: "BB Cream",
        top: 0.33, 
        left: 0.33
        ),

        MakeupStepData(
        number: 6, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/snow_elf_parts/s_e_eyeshadow3.png", 
        colorCode: "BB Cream",
        top: 0.45, 
        left: 0.75
        ),

        MakeupStepData(
        number: 7, 
        title: "Lips", 
        imageAsset: "assets/images/snow_elf_parts/s_e_lips.png", 
        colorCode: "BB Cream",
        top: 0.7, 
        left: 0.45
        )
      ]
  ),

  MakeupLook(
    title: "Soft Asian", 
    category: 'Full Look', 
    imageAsset: "assets/images/soft_asian.jpg", 
    bgColor: const Color(0xFFFFE4E1), 
    isFullLook: true, 
    steps: [
      MakeupStepData(
        number: 1, 
        title: "Contour", 
        imageAsset: "assets/images/soft_asian_parts/s_a_contour.png", 
        colorCode: "BB Cream",
        top: 0.43, 
        left: 0.47
        ),

        MakeupStepData(
        number: 2, 
        title: "Highlight", 
        imageAsset: "assets/images/soft_asian_parts/s_a_highlight1.png", 
        colorCode: "BB Cream",
        top: 0.33, 
        left: 0.5
        ),

        MakeupStepData(
        number: 3, 
        title: "Blush", 
        imageAsset: "assets/images/soft_asian_parts/s_a_blush.png", 
        colorCode: "BB Cream",
        top: 0.4, 
        left: 0.7
        ),

        MakeupStepData(
        number: 4, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/soft_asian_parts/s_a_eyeshadow1.png", 
        colorCode: "BB Cream",
        top: 0.33, 
        left: 0.36
        ),

        MakeupStepData(
        number: 5, 
        title: "Eyeliner", 
        imageAsset: "assets/images/soft_asian_parts/s_a_eyeliner.png", 
        colorCode: "BB Cream",
        top: 0.35, 
        left: 0.3
        ),

        MakeupStepData(
        number: 6, 
        title: "Highlight", 
        imageAsset: "assets/images/soft_asian_parts/s_a_highlight2.png", 
        colorCode: "BB Cream",
        top: 0.37, 
        left: 0.56
        ),

        MakeupStepData(
        number: 7, 
        title: "Lips", 
        imageAsset: "assets/images/soft_asian_parts/s_a_lips.png", 
        colorCode: "BB Cream",
        top: 0.53, 
        left: 0.5
        )
      ]
  ),

  MakeupLook(
    title: "Blue Cat", 
    category: 'Full Look', 
    imageAsset: "assets/images/blue_cat.jpg", 
    bgColor: const Color(0xFFFFE4E1), 
    isFullLook: true, 
    steps: [
      MakeupStepData(
        number: 1, 
        title: "Contour", 
        imageAsset: "assets/images/blue_cat_parts/b_c_contour.png", 
        colorCode: "BB Cream",
        top: 0.35, 
        left: 0.57
        ),

        MakeupStepData(
        number: 2, 
        title: "Highlight", 
        imageAsset: "assets/images/blue_cat_parts/b_c_highlight.png", 
        colorCode: "BB Cream",
        top: 0.45, 
        left: 0.52
        ),

        MakeupStepData(
        number: 3, 
        title: "Blush", 
        imageAsset: "assets/images/blue_cat_parts/b_c_blush.png", 
        colorCode: "BB Cream",
        top: 0.4, 
        left: 0.8
        ),

        MakeupStepData(
        number: 4, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/blue_cat_parts/b_c_eyeshadow1.png", 
        colorCode: "BB Cream",
        top: 0.28, 
        left: 0.25
        ),

        MakeupStepData(
        number: 5, 
        title: "Eyeshadow", 
        imageAsset: "assets/images/blue_cat_parts/b_c_eyeshadow2.png", 
        colorCode: "BB Cream",
        top: 0.28, 
        left: 0.38
        ),

        MakeupStepData(
        number: 6, 
        title: "Eyeliner", 
        imageAsset: "assets/images/blue_cat_parts/b_c_eyeliner.png", 
        colorCode: "BB Cream",
        top: 0.3, 
        left: 0.85
        ),

        MakeupStepData(
        number: 7, 
        title: "Lips", 
        imageAsset: "assets/images/blue_cat_parts/b_c_lips.png", 
        colorCode: "BB Cream",
        top: 0.55, 
        left: 0.5
        )
      ]
  ),

  MakeupLook(title: "Meniscus", category: 'Eyebrows', imageAsset: "assets/images/eyebrows1.jpg", bgColor: Colors.blueGrey.shade100, description: "A curved, soft arch that follows the natural brow bone."),
  MakeupLook(
    title: "Standard Eyebrows", 
    category: 'Eyebrows', 
    imageAsset: "assets/images/eyebrows2.jpg", 
    bgColor: Colors.red.shade100, 
    description: "A classic eyebrow shape with a gentle arch, suitable for most face shapes."
    ),

  MakeupLook(title: "Lancet Eyebrows", category: 'Eyebrows', imageAsset: "assets/images/eyebrows3.jpg", bgColor: Colors.brown.shade100),
  MakeupLook(title: "Small Eyebrows", category: 'Eyebrows', imageAsset: "assets/images/eyebrows4.jpg", bgColor: Colors.purple.shade100),
  MakeupLook(title: "Unibrow", category: 'Eyebrows', imageAsset: "assets/images/eyebrows5.jpg", bgColor: Colors.pink.shade100),
  MakeupLook(title: "European Eyebrows", category: 'Eyebrows', imageAsset: "assets/images/eyebrows6.jpg", bgColor: Colors.green.shade100),
  MakeupLook(title: "Tightlining", category: 'Eyeliner', imageAsset: "assets/images/eyeliner1.jpg", bgColor: Colors.blueGrey.shade100),
  MakeupLook(title: "Thin Classic Line", category: 'Eyeliner', imageAsset: "assets/images/eyeliner2.jpg", bgColor: Colors.red.shade100),
  MakeupLook(title: "Natural Eyeliner", category: 'Eyeliner', imageAsset: "assets/images/eyeliner3.jpg", bgColor: Colors.brown.shade100),
  MakeupLook(title: "Puppy Eyeliner", category: 'Eyeliner', imageAsset: "assets/images/eyeliner4.jpg", bgColor: Colors.purple.shade100),
  MakeupLook(title: "Classic Winged Eyeliner", category: 'Eyeliner', imageAsset: "assets/images/eyeliner5.jpg", bgColor: Colors.pink.shade100),
  MakeupLook(title: "Soft Wing", category: 'Eyeliner', imageAsset: "assets/images/eyeliner6.jpg", bgColor: Colors.green.shade100),
  MakeupLook(title: "Charp Wing", category: 'Eyeliner', imageAsset: "assets/images/eyeliner7.jpg", bgColor: Colors.green.shade100),
];


class Makeup extends StatefulWidget {
  const Makeup({super.key});

  @override
  State<Makeup> createState() => _MakeupState();
}

class _MakeupState extends State<Makeup> {
  String _selectedCategory = kCategories.first; // Default to 'All'

  int _selectedIndex = 3;

  @override
  void initState() {
    super.initState();
    _fetchUserFavorites(); // Load favorites on startup
  }

  Future<void> _fetchUserFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await supabase
          .from('user_favorite_makeup')
          .select('title')
          .eq('user_id', user.id);

      final List<dynamic> data = response as List<dynamic>;
      final Set<String> favoriteTitles = data.map((item) => item['title'] as String).toSet();

      setState(() {
        for (var look in kAllLooks) {
          if (favoriteTitles.contains(look.title)) {
            look.isFavorite = true;
          } else {
            look.isFavorite = false;
          }
        }
      });
    } catch (e) {
      print('Error fetching favorites: $e');
    }
  }

  // 2. Toggle Favorite
  Future<void> _toggleFavorite(MakeupLook look) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please login to save favorites.")));
      return;
    }

    // Optimistic UI update
    setState(() {
      look.isFavorite = !look.isFavorite;
    });

    try {
      if (look.isFavorite) {
        // Add to database
        await supabase.from('user_favorite_makeup').insert({
          'user_id': user.id,
          'title': look.title,
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Added to favorites!"), duration: Duration(milliseconds: 500)));
      } else {
        // Remove from database
        await supabase.from('user_favorite_makeup').delete().match({
          'user_id': user.id,
          'title': look.title,
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Removed from favorites."), duration: Duration(milliseconds: 500)));
      }
    } catch (e) {
      // Revert if error
      setState(() {
        look.isFavorite = !look.isFavorite;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  // 1. Get Featured Looks (Always shows FULL LOOKS)
  List<MakeupLook> _getTrendingLooks() {
    return kAllLooks.where((look) => look.isFullLook).toList();
  }

  // 2. Get Grid Items (Shows PARTS, filtered by the selected Tab)
  List<MakeupLook> _getFilteredGridItems() {
    return kAllLooks.where((look) {
      // Must NOT be a full look (we only want parts in the grid)
      bool isPart = !look.isFullLook; 
      
      // Filter by Category
      bool matchesCategory = _selectedCategory == 'All' || look.category == _selectedCategory;
      
      return isPart && matchesCategory;
    }).toList();
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  void _onNavBarTap(int index) {
    // 3 corresponds to 'Looks' (this page), so no action needed if 3 is tapped
    if (index == 2) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainPage()));
    } else if (index == 4) {
      _handleLogout();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<MakeupLook> trendingLooks = _getTrendingLooks();
    List<MakeupLook> gridItems = _getFilteredGridItems();
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: TextColor),
          onPressed: () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          ),
        ),
        title: const Text("Makeup Looks", style: TextStyle(color: TextColor, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,

        //Favorite Button
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_outline, color: TextColor),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const FavoriteMakeup()),
              ).then((_) => _fetchUserFavorites()); // Refresh status when coming back
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // --- 1. TRENDING NOW (Horizontal List) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text("Trending Now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TextColor)),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 180, 
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                itemCount: trendingLooks.length,
                separatorBuilder: (_,__) => const SizedBox(width: 15),
                itemBuilder: (context, index) {
                  return _buildFeaturedCard(context, trendingLooks[index]);
                },
              ),
            ),

            const SizedBox(height: 30),

            // --- 2. CATEGORY TABS (Filter Bar) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Text("Explore Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TextColor)),
            ),
            const SizedBox(height: 15),
            
            SizedBox(
              height: 35,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final category = kCategories[index];
                  final isSelected = category == _selectedCategory;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? PrimaryAccent : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? PrimaryAccent : Colors.grey.shade300),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            // --- 3. FILTERED GRID (Shows items matching the Tab) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: gridItems.isEmpty
                  ? Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: Text("No items found for $_selectedCategory.", style: const TextStyle(color: Colors.grey)),
                    )
                  : GridView.builder(
                      shrinkWrap: true, 
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: gridItems.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 items per row
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 15,
                        childAspectRatio: 0.70,
                      ),
                      itemBuilder: (context, index) {
                        return _buildLookGridItem(context, gridItems[index]);
                      },
                    ),
            ),

            const SizedBox(height: 50),
          ],
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  // --- Helper Widgets ---

  // Featured Card -> Interactive Page
  Widget _buildFeaturedCard(BuildContext context, MakeupLook look) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => MakeupDetail(title: look.title, imageAsset: look.imageAsset, steps: look.steps)));
      },
      child: Stack(
      children:[ 
        Container(
        width: 140, 
        // ★★★ FIX 2: Reduce card height slightly for a squarer look ★★★
        height: 160, 
        decoration: BoxDecoration(color: look.bgColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), 
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    look.imageAsset, 
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (c,e,s) => Container(
                      color: Colors.white.withOpacity(0.5),
                      child: Center(child: Icon(Icons.face_retouching_natural, size: 40, color: PrimaryAccent.withOpacity(0.5)))
                    )
                  )
                )
              )
            ),
            Padding(padding: const EdgeInsets.all(12.0), child: Text(look.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: TextColor), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      Positioned(
        top: 5, right: 5,
        child: GestureDetector(
          onTap: () => _toggleFavorite(look),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
              child: Icon(look.isFavorite ? Icons.favorite : Icons.favorite_border, size: 16, color: look.isFavorite ? Colors.red : Colors.grey),
            ),
          ),
        ),
      ],
    ),
  );
}

  // 2. Grid Item (Navigates to SIMPLE SimpleMakeupDetailPage)
  Widget _buildLookGridItem(BuildContext context, MakeupLook look) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SimpleMakeupDetail(look: look),
          ),
        );
      },
      child: Stack(
      children: [
      Container(
        decoration: BoxDecoration(color: look.bgColor, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), 
                child: Container(
                  color: Colors.white,
                  child: Image.asset(
                    look.imageAsset, 
                    fit: BoxFit.cover, // Show whole image
                    width: double.infinity,
                    errorBuilder: (c,e,s) => Container(
                      color: Colors.white.withOpacity(0.5),
                      child: Center(child: Icon(Icons.camera_enhance, size: 30, color: PrimaryAccent.withOpacity(0.5)))
                    )
                  )
                )
              )
            ),
            Padding(padding: const EdgeInsets.all(10.0), child: Center(child: Text(look.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: TextColor), maxLines: 2, overflow: TextOverflow.ellipsis))),
          ],
        ),
      ),
      Positioned(
        top: 5, right: 5,
        child: GestureDetector(
          onTap: () => _toggleFavorite(look),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.8), shape: BoxShape.circle),
              child: Icon(look.isFavorite ? Icons.favorite : Icons.favorite_border, size: 16, color: look.isFavorite ? Colors.red : Colors.grey),
            ),
          ),
        ),
      ],
      ),
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