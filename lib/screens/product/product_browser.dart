import 'package:flutter/material.dart';
import 'package:glowmate_app/main.dart';
import '../makeup/makeup.dart' show Makeup;
import '../profile/profile.dart';
import '../routine/routine_tracker.dart';
import 'product_detail.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart';
import '../../main_page.dart';
import '../auth/login.dart';


class ProductBrowser extends StatefulWidget {
  const ProductBrowser({super.key});

  @override
  State<ProductBrowser> createState() => _ProductBrowserState();
}

class _ProductBrowserState extends State<ProductBrowser> {
  // --- STATE VARIABLES ---
  List<Product> _allProducts = [];
  List<Product> _suggestedProducts = [];
  bool _isLoading = true;
  String _searchQuery = "";

  // User Profile State
  String _userSkinType = "";
  List<String> _userConcerns = [];
  
  // Filter States
  String _selectedSkinType = 'All';
  String _selectedConcern = 'All';
  String _selectedproducttype = 'All';
  String _selectedTime = 'All'; // NEW: Day/Night Filter

  int _selectedIndex = 1; 

  @override
  void initState() {
    super.initState();
    _loadData(); 
  }

    // ---Comprehensive Data Loading---
    Future<void> _loadData() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Fetch User Profile
      final profileData = await supabase
          .from('profiles')
          .select('skintype, skinconcerns')
          .eq('id', user.id)
          .maybeSingle();

      if (profileData != null) {
        _userSkinType = profileData['skintype'] ?? "";
        final dynamic concerns = profileData['skinconcerns'];
        if (concerns is List) {
          _userConcerns = concerns.map((e) => e.toString()).toList();
        }
      }

      // 2. Fetch Products
      final List<Map<String, dynamic>> rawData = await supabase
          .from('products')
          .select('*')
          .limit(1000); 
      
      final List<Product> fetchedProducts = rawData.map((data) => Product.fromSupabase(data)).toList();

      // 3. Logic for "Suggested for You"
      // Matches products that support the user's skin type AND at least one concern
      final List<Product> suggestions = fetchedProducts.where((product) {
        bool typeMatch = product.skintype.toLowerCase().contains(_userSkinType.toLowerCase());
        
        bool concernMatch = false;
        for (var concern in _userConcerns) {
          if (product.skinconcerns.toLowerCase().contains(concern.toLowerCase())) {
            concernMatch = true;
            break;
          }
        }
        return typeMatch && concernMatch;
      }).toList();

      if (mounted) {
        setState(() {
          _allProducts = fetchedProducts;
          _suggestedProducts = suggestions;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading product browser data: $e");
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  // --- FILTERING LOGIC ---
  List<Product> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch = product.productname.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final productSkinTypes = product.skintype.split('|'); 
      final matchesType = _selectedSkinType == 'All' || 
                          product.skintype == 'All' ||
                          productSkinTypes.contains(_selectedSkinType);

      final productConcerns = product.skinconcerns.split('|');
      final matchesConcern = _selectedConcern == 'All' || 
                             productConcerns.contains(_selectedConcern);

      final matchesCategory = _selectedproducttype == 'All' || 
                              product.producttype.toLowerCase().contains(_selectedproducttype.toLowerCase());

      final matchesTime = _selectedTime == 'All' || 
                          product.day_night.toLowerCase().contains(_selectedTime.toLowerCase());

      return matchesSearch && matchesType && matchesConcern && matchesCategory && matchesTime;
    }).toList();
  }

  // --- NAVIGATION LOGIC ---
  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login()));
    }
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RoutineTracker()));
    } else if (index == 1) {
      // Already here
    } else if (index == 2) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const MainPage()));
    } else if (index == 3) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Makeup()));
    } else if (index == 4) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Profile()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: BackgroundGradient),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // --- 1. HEADER & SEARCH ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: TextColor, size: 20),
                          onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => const MainPage())
                          ),
                        ),
                        const Expanded(
                          child: Text(
                            "Product Browser",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TextColor),
                          ),
                        ),
                        const SizedBox(width: 40), 
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: "Search products...",
                        hintStyle: const TextStyle(fontSize: 14),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        prefixIcon: const Icon(Icons.search, color: TextColor, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      ),
                    ),
                  ],
                ),
              ),

              // --- 2. FILTER SECTION ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.5))),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Quick Filters", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TextColor)),
                    const SizedBox(height: 10),
                    _buildFilterRow("Routine", ['All', 'day', 'night'], _selectedTime, (val) => setState(() => _selectedTime = val)),
                    const SizedBox(height: 8),
                    _buildFilterRow("Skin", ['All', 'Dry', 'Oily', 'Combine', 'Sensitive'], _selectedSkinType, (val) => setState(() => _selectedSkinType = val)),
                    const SizedBox(height: 8),
                    _buildFilterRow("Concern", ['All', 'Acne', 'Wrinkles', 'Spots', 'Uneven Skin-Type', 'Dehydration'], _selectedConcern, (val) => setState(() => _selectedConcern = val)),
                  ],
                ),
              ),

              // --- 3. SCROLLABLE CONTENT ---
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator(color: PrimaryAccent)) 
                  : SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 20, bottom: 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- SUGGESTED SECTION ---
                          if (_suggestedProducts.isNotEmpty && _searchQuery.isEmpty && _selectedSkinType == 'All') ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: PrimaryAccent, size: 18),
                                  SizedBox(width: 8),
                                  Text("Suggested for You", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: TextColor)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 150,
                              child: ListView.separated(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                scrollDirection: Axis.horizontal,
                                itemCount: _suggestedProducts.length,
                                separatorBuilder: (_,__) => const SizedBox(width: 12),
                                itemBuilder: (context, index) => _buildProductCardHorizontal(_suggestedProducts[index]),
                              ),
                            ),
                            const SizedBox(height: 25),
                          ],

                          // --- ALL PRODUCTS SECTION ---
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Text("Explore All", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: TextColor)),
                          ),
                          const SizedBox(height: 12),
                          
                          _filteredProducts.isEmpty 
                            ? const Padding(
                                padding: EdgeInsets.all(40.0),
                                child: Center(child: Text("No products match your filters.")),
                              )
                            : GridView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  childAspectRatio: 0.65, 
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) => _buildProductSquare(_filteredProducts[index]),
                              ),
                        ],
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildCustomBottomNavBar(),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildFilterRow(String label, List<String> options, String selectedValue, Function(String) onSelect) {
    return SizedBox(
      height: 28,
      child: Row(
        children: [
          SizedBox(width: 60, child: Text(label, style: const TextStyle(fontSize: 11, color: TextColor, fontWeight: FontWeight.w600))),
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = options[index];
                final isSelected = option.toLowerCase() == selectedValue.toLowerCase();
                return GestureDetector(
                  onTap: () => onSelect(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? PrimaryAccent : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: isSelected ? PrimaryAccent : Colors.grey.shade400),
                    ),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : TextColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCardHorizontal(Product product) {
    return GestureDetector( 
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetail(product: product))),
      child: Container(
        width: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Image.asset(product.image_url, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
              child: Text(product.productname, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSquare(Product product) {
    return GestureDetector( 
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductDetail(product: product))),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Expanded(
              child: Image.asset(product.image_url, fit: BoxFit.contain, errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported)),
            ),
            const SizedBox(height: 8),
            Text(
              product.productname,
              maxLines: 2, 
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: TextColor),
            ),
            const SizedBox(height: 2),
            Text(
              product.brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: TextColor.withOpacity(0.5)),
            ),
          ],
        ),
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
            _buildNavIcon(0, Icons.show_chart, false),
            _buildNavIcon(1, Icons.search, true),
            _buildHomeIcon(),
            _buildNavIcon(3, Icons.sentiment_satisfied_alt, false),
            _buildNavIcon(4, Icons.person_outline, false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon, bool isActive) {
    return GestureDetector(
      onTap: () => _onNavBarTap(index),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle, 
          color: isActive ? PrimaryAccent.withOpacity(0.2) : Colors.transparent,
          border: Border.all(color: isActive ? PrimaryAccent : Colors.black, width: 1.0)
        ),
        child: Icon(icon, size: 20, color: isActive ? PrimaryAccent : TextColor),
      ),
    );
  }

  Widget _buildHomeIcon() {
    return GestureDetector(
      onTap: () => _onNavBarTap(2),
      child: Container(
        width: 48, height: 48,
        decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: const Icon(Icons.home_filled, color: Colors.white, size: 26),
      ),
    );
  }
}