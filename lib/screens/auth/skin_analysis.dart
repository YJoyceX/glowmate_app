import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart'; // For supabase client
import '../../main_page.dart'; // Destination
import '../../utils/constants.dart'; // Colors

class SkinAnalysis extends StatefulWidget {
  const SkinAnalysis({super.key});

  @override
  State<SkinAnalysis> createState() => _SkinAnalysisState();
}

class _SkinAnalysisState extends State<SkinAnalysis> {
  int _step = 0; 
  String? _selectedSkinType;
  final List<String> _selectedConcerns = [];
  String? _errorMessage;
  bool _isLoading = false;

  final List<String> _skinTypes = ['Oily', 'Dry', 'Combine', 'Sensitive'];
  final List<String> _skinConcerns = ['Dark Circles', 'Spots', 'Acne', 'Wrinkles', 'Uneven Skin-Tone', 'Dehydration'];

  void _navigateToStep(int step) { setState(() { _step = step; }); }

  void _selectSkinType(String type) {
    setState(() { _selectedSkinType = type; _errorMessage = null; });
  }

  void _toggleConcern(String concern) {
    setState(() {
      _errorMessage = null;
      if (_selectedConcerns.contains(concern)) {
        _selectedConcerns.remove(concern);
      } else {
        _selectedConcerns.add(concern);
      }
    });
  }

  // --- SAVE TO SUPABASE ---
  Future<void> _saveAnalysisAndContinue() async {
    final User? user = supabase.auth.currentUser;
    
    if (_selectedSkinType == null) {
       setState(() { _errorMessage = 'Please select a skin type.'; _step = 1; });
       return;
    }
    if (_selectedConcerns.isEmpty) {
       setState(() { _errorMessage = 'Please select at least one concern.'; _step = 2; });
       return;
    }
    if (user == null) return;

    setState(() { _isLoading = true; });

    try {
      // Update profile in Supabase
      await supabase.from('profiles').update({
        'skintype': _selectedSkinType,
        'skinconcerns': _selectedConcerns,
      }).eq('id', user.id);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      setState(() { _errorMessage = 'Failed to save. Please try again.'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget currentPage;
    switch (_step) {
      case 0: currentPage = _buildIntroStep(); break;
      case 1: currentPage = _buildTypeStep(); break;
      case 2: currentPage = _buildConcernsStep(); break;
      default: currentPage = _buildIntroStep();
    }
    return Scaffold(body: AnimatedSwitcher(duration: const Duration(milliseconds: 300), child: currentPage));
  }

  Widget _buildStepContainer(String title, List<Widget> children, Widget button) {
    return Container(
      key: ValueKey<int>(_step),
      width: double.infinity, height: double.infinity,
      decoration: const BoxDecoration(gradient: BackgroundGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: TextColor)),
              const SizedBox(height: 30),
              Expanded(child: Column(children: children)),
              if (_errorMessage != null) Padding(padding: const EdgeInsets.only(bottom: 15), child: Text(_errorMessage!, style: const TextStyle(color: ErrorRed))),
              button,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroStep() {
    return _buildStepContainer(
      'Skin Analysis',
      [_buildActionCard(title: 'Skin Type', onTap: () => _navigateToStep(1)), const SizedBox(height: 20), _buildActionCard(title: 'Skin Concerns', onTap: () => _navigateToStep(2))],
      _buildActionButton(label: 'Continue', onPressed: () => _navigateToStep(1)),
    );
  }

  Widget _buildTypeStep() {
    return _buildStepContainer(
      'Skin Type',
      [Expanded(child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.2, crossAxisSpacing: 20, mainAxisSpacing: 20), itemCount: _skinTypes.length, itemBuilder: (context, index) { final type = _skinTypes[index]; return _buildSelectionCard(label: type, isSelected: _selectedSkinType == type, onTap: () => _selectSkinType(type)); }))],
      _buildActionButton(label: 'Apply', onPressed: () => _selectedSkinType == null ? setState(() => _errorMessage = 'Select a type') : _navigateToStep(2)),
    );
  }

  Widget _buildConcernsStep() {
    return _buildStepContainer(
      'Skin Concerns',
      [Expanded(child: ListView.builder(itemCount: _skinConcerns.length, itemBuilder: (context, index) { final concern = _skinConcerns[index]; return Padding(padding: const EdgeInsets.only(bottom: 15), child: _buildSelectionCard(label: concern, isSelected: _selectedConcerns.contains(concern), onTap: () => _toggleConcern(concern), isWide: true)); }))],
      _buildActionButton(label: 'Apply', onPressed: _isLoading ? null : _saveAnalysisAndContinue, child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : null),
    );
  }

  Widget _buildActionButton({required String label, required VoidCallback? onPressed, Widget? child}) {
    return SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: onPressed, child: child ?? Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))));
  }

  Widget _buildActionCard({required String title, required VoidCallback onTap}) {
    return InkWell(onTap: onTap, child: Container(height: 100, alignment: Alignment.center, decoration: BoxDecoration(color: ActiveCard, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)]), child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: TextColor))));
  }

  Widget _buildSelectionCard({required String label, required bool isSelected, required VoidCallback onTap, bool isWide = false}) {
    return InkWell(onTap: onTap, child: Container(height: isWide ? 70 : null, alignment: Alignment.center, decoration: BoxDecoration(color: isSelected ? PrimaryAccent.withOpacity(0.9) : InactiveCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: isSelected ? PrimaryAccent : Colors.transparent, width: 2)), child: Text(label, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : TextColor))));
  }
}