import 'package:flutter/material.dart';
import 'package:glowmate_app/main.dart';
import '../../models/product_model.dart';
import '../../utils/constants.dart'; 

class ProductDetail extends StatefulWidget {
  final Product product;

  const ProductDetail({super.key, required this.product});

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  bool _isAddingDay = false;
  bool _isAddingNight = false;
  
  Map<String, String> _ingredientDetails = {}; 
  bool _isLoadingIngredients = true;

  @override
  void initState() {
    super.initState();
    _fetchIngredientDetails();
  }

  // --- 1. Fetch Ingredient Descriptions ---
  Future<void> _fetchIngredientDetails() async {
    List<String> names = widget.product.ingredients.split('|');
    names = names.where((ingredientname) => ingredientname.trim().isNotEmpty).toList();

    if (names.isEmpty) {
      setState(() { _isLoadingIngredients = false; });
      return;
    }

    try {
      final data = await supabase
          .from('ingredients')
          .select('ingredientname, description')
          .inFilter('ingredientname', names); 

      final Map<String, String> detailsMap = {};
      for (var row in data) {
        if (row['ingredientname'] != null) {
          detailsMap[row['ingredientname']] = row['description'] ?? 'No description available.';
        }
      }

      if (mounted) {
        setState(() {
          _ingredientDetails = detailsMap;
          _isLoadingIngredients = false;
        });
      }
    } catch (e) {
      print('Error fetching ingredients: $e');
      if (mounted) setState(() { _isLoadingIngredients = false; });
    }
  }

  // --- 2. Add to Routine Logic ---
  Future<void> _addToRoutine(String routineType) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login first.')));
      return;
    }

    setState(() {
      if (routineType == 'Day') _isAddingDay = true;
      else _isAddingNight = true;
    });

    try {
      // Step A: Check if already exists
      final existingData = await supabase
          .from('user_routines')
          .select('id')
          .eq('user_id', user.id)
          .eq('product_id', widget.product.productid) // Use String ID
          .eq('routine_type', routineType)
          .maybeSingle();

      if (existingData != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Already in your $routineType Routine!'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      } else {
        // Step B: Insert if new
        await supabase.from('user_routines').insert({
          'user_id': user.id,
          'product_id': widget.product.productid,
          'routine_type': routineType,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added to $routineType Routine!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    }catch (e) {
      print("Add Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: ErrorRed));
      }
    } finally {
      if (mounted) {
        setState(() {
          if (routineType == 'Day') _isAddingDay = false;
          else _isAddingNight = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> ingredientNames = widget.product.ingredients.split('|');
    ingredientNames = ingredientNames.where((n) => n.trim().isNotEmpty).toList();
    
    List<String> skinTypes = widget.product.skintype.split('|');
    List<String> concerns = widget.product.skinconcerns.split('|');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: TextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.product.producttype.toUpperCase(), style: const TextStyle(color: TextColor, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. PRODUCT IMAGE ---
            Center(
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset(
                    widget.product.image_url,
                    fit: BoxFit.contain,
                    errorBuilder: (c,e,s) => const Icon(Icons.image_not_supported, size: 80, color: Colors.grey),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. HEADER INFO ---
            Text(widget.product.brand, style: TextStyle(fontSize: 16, color: TextColor.withOpacity(0.6), fontWeight: FontWeight.w500)),
            const SizedBox(height: 5),
            Text(widget.product.productname, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: TextColor)),
            
            const SizedBox(height: 25),

            // --- 3. SKIN TYPES & CONCERNS ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.face, size: 16, color: PrimaryAccent),
                          const SizedBox(width: 5),
                          Text("Best for", style: TextStyle(fontSize: 14, color: TextColor.withOpacity(0.6), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: skinTypes.map((type) => _buildBadge(type, PrimaryAccent.withOpacity(0.1), TextColor)).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.healing, size: 16, color: Colors.blue),
                          const SizedBox(width: 5),
                          Text("Targets", style: TextStyle(fontSize: 14, color: TextColor.withOpacity(0.6), fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: concerns.map((c) => _buildBadge(c, Colors.blue.shade50, Colors.blue.shade800)).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- 4. ROUTINE SUITABILITY ---
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: Colors.teal),
                const SizedBox(width: 5),
                Text("Routine", style: TextStyle(fontSize: 14, color: TextColor.withOpacity(0.6), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            _buildRoutineBadge(widget.product.day_night),

            const SizedBox(height: 30),

            // --- 5. INGREDIENTS LIST ---
            const Text("Key Ingredients", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TextColor)),
            const SizedBox(height: 15),

            if (_isLoadingIngredients)
              const Center(child: CircularProgressIndicator(color: PrimaryAccent))
            else if (ingredientNames.isEmpty)
              const Text("No specific ingredients listed.", style: TextStyle(color: Colors.grey))
            else
              ...ingredientNames.map((ingredientname) {
                final description = _ingredientDetails[ingredientname.trim()] ?? 'Description loading...';
                return _buildIngredientItem(ingredientname, description);
              }).toList(),

            const SizedBox(height: 40),

            // --- 6. ADD BUTTONS ---
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAddingDay ? null : () => _addToRoutine('Day'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange.shade50,
                      foregroundColor: Colors.orange.shade800,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.orange.shade200)),
                    ),
                    icon: _isAddingDay ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orange)) : const Icon(Icons.wb_sunny_outlined),
                    label: const Text("Add to Day"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isAddingNight ? null : () => _addToRoutine('Night'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8EAF6),
                      foregroundColor: const Color(0xFF3949AB),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Color(0xFFC5CAE9))),
                    ),
                    icon: _isAddingNight ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.indigo)) : const Icon(Icons.nightlight_round),
                    label: const Text("Add to Night"),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 11)),
    );
  }

  Widget _buildRoutineBadge(String dayNight) {
    Color bgColor;
    Color textColor;
    IconData icon;
    String text;

    if (dayNight == 'Day') {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.wb_sunny_outlined;
      text = "Day Routine";
    } else if (dayNight == 'Night') {
      bgColor = const Color(0xFFE8EAF6);
      textColor = const Color(0xFF3949AB);
      icon = Icons.nightlight_round;
      text = "Night Routine";
    } else {
      bgColor = Colors.purple.shade50;
      textColor = Colors.purple.shade800;
      icon = Icons.access_time; 
      text = "Day & Night Routine";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: textColor),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildIngredientItem(String name, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 8, height: 8,
            decoration: const BoxDecoration(color: PrimaryAccent, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name.trim(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: TextColor)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: TextColor.withOpacity(0.7), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}