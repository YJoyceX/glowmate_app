import 'package:flutter/material.dart';
import 'package:glowmate_app/main.dart';
import '../../utils/constants.dart';
import 'makeup.dart';
import 'makeup_detail.dart';
import 'simple_makeup_detail.dart';

class FavoriteMakeup extends StatefulWidget {
  const FavoriteMakeup({super.key});

  @override
  State<FavoriteMakeup> createState() => _FavoriteMakeupState();
}

class _FavoriteMakeupState extends State<FavoriteMakeup> {
  List<MakeupLook> _favoriteLooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Fetch titles from Supabase
      final response = await supabase
          .from('user_favorite_makeup')
          .select('title')
          .eq('user_id', user.id);

      final List<dynamic> data = response as List<dynamic>;
      final Set<String> favTitles = data.map((item) => item['title'] as String).toSet();
      // 2. Filter the local kAllLooks list
      final List<MakeupLook> matchedLooks = kAllLooks.where((look) {
        return favTitles.contains(look.title);
      }).toList();

      if (mounted) {
        setState(() {
          _favoriteLooks = matchedLooks;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching favorites: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _removeFavorite(MakeupLook look) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      await supabase.from('user_favorite_makeup').delete().match({
        'user_id': user.id,
        'title': look.title,
      });

      setState(() {
        _favoriteLooks.removeWhere((l) => l.title == look.title);
        // Also update the global list state if necessary
        look.isFavorite = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Removed from favorites"), duration: Duration(milliseconds: 500)),
      );
    } catch (e) {
      print("Error removing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: TextColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("My Favorites", style: TextStyle(color: TextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: BackgroundGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: PrimaryAccent))
            : _favoriteLooks.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _favoriteLooks.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 15,
                      mainAxisSpacing: 15,
                      childAspectRatio: 0.8,
                    ),
                    itemBuilder: (context, index) {
                      final look = _favoriteLooks[index];
                      return _buildFavoriteCard(look);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 20),
          const Text("No favorites yet", style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Heart some looks to see them here!", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(MakeupLook look) {
    return GestureDetector(
      onTap: () {
        if (look.isFullLook) {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MakeupDetail(title: look.title, imageAsset: look.imageAsset, steps: look.steps),
          ));
        } else {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => SimpleMakeupDetail(look: look),
          ));
        }
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: look.bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      width: double.infinity,
                      color: Colors.white.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Image.asset(look.imageAsset, fit: BoxFit.contain),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(look.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: TextColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text(look.category, style: TextStyle(fontSize: 10, color: TextColor.withOpacity(0.5))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () => _removeFavorite(look),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.favorite, size: 16, color: Colors.red),
              ),
            ),
          ),
        ],
      ),
    );
  }
}