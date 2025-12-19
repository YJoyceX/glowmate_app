import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'makeup.dart'; // To access the updated MakeupStepData class

class MakeupDetail extends StatefulWidget {
  final String title;
  final String imageAsset;
  final List<MakeupStepData> steps;

  const MakeupDetail({super.key, required this.title, required this.imageAsset, required this.steps});

  @override
  State<MakeupDetail> createState() => _MakeupDetailState();
}

class _MakeupDetailState extends State<MakeupDetail> with SingleTickerProviderStateMixin {
  final bool _debugMode = false; // Set to true to find coordinates
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 2), vsync: this)..repeat(reverse: true);
    _animation = Tween<double>(begin: 0, end: 5).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _onStepTapped(MakeupStepData step) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allows the sheet to be taller for the image
      builder: (context) => _buildStepSheet(step),
    );
  }

  Color _getColorForShade(String shadeName) {
    final name = shadeName.toLowerCase();
    if (name.contains('blush voyage') || name.contains('voyage')) return const Color(0xffad6e65);
    if (name.contains('blush charm') || name.contains('charm')) return const Color(0xffcf7d89);
    if (name.contains('lips spicy mix') || name.contains('spicy mix')) return const Color(0xff8e5045);
    if (name.contains('lips au chico') || name.contains('au chico')) return const Color(0xff965f62);
    if (name.contains('contour cinerous') || name.contains('cinereous')) return const Color(0xff98817b);
    if (name.contains('highlight off white') || name.contains('off white')) return const Color(0xfff9f5ec);
    if (name.contains('eyeshadow voyage') || name.contains('voyage')) return const Color(0xffad6e65);
    if (name.contains('eyeshadow campfire') || name.contains('campfire')) return const Color(0xffc78970);
    if (name.contains('eyeshadow rosewood rouge') || name.contains('rosewood rouge')) return const Color(0xff87756e);
    if (name.contains('eyeliner black') || name.contains('black')) return const Color(0xFF000000);
    if (name.contains('eyeshadow americano coffee') || name.contains('americano coffee')) return const Color(0xff87756e);
    if (name.contains('eyeshadow americano coffee') || name.contains('americano coffee')) return const Color(0xff87756e);
    if (name.contains('eyeshadow americano coffee') || name.contains('americano coffee')) return const Color(0xff87756e);
    if (name.contains('eyeshadow americano coffee') || name.contains('americano coffee')) return const Color(0xff87756e);
    return PrimaryAccent; // Default fallback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_back_ios, color: TextColor, size: 18),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.title, style: const TextStyle(color: TextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: BackgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(_debugMode ? "DEBUG: Tap to see coords" : "Tap numbers to see steps", style: TextStyle(fontSize: 16, color: _debugMode ? Colors.red : Colors.black54, fontStyle: FontStyle.italic)),
              const SizedBox(height: 20),
              
              // --- INTERACTIVE FACE AREA ---
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  double maxWidth = constraints.maxWidth * 0.95;
                  double maxHeight = constraints.maxHeight * 0.95;
                  return Center(
                    child: SizedBox(
                      width: maxWidth, height: maxHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: GestureDetector(
                              onTapUp: (details) {
                                if (_debugMode) {
                                  final top = (details.localPosition.dy / maxHeight).toStringAsFixed(2);
                                  final left = (details.localPosition.dx / maxWidth).toStringAsFixed(2);
                                  print("top: $top, left: $left");
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("top: $top, left: $left"), duration: const Duration(seconds: 2)));
                                }
                              },
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(widget.imageAsset, fit: BoxFit.cover, alignment: Alignment.topCenter, errorBuilder: (c,e,s) => Container(color: Colors.white.withOpacity(0.5), child: const Center(child: Icon(Icons.face, size: 100, color: Colors.grey)))),
                              ),
                            ),
                          ),
                          ...widget.steps.map((step) => Positioned(
                            top: maxHeight * step.top - 17, left: maxWidth * step.left - 17,
                            child: GestureDetector(
                              onTap: () => _onStepTapped(step),
                              child: AnimatedBuilder(
                                animation: _animation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, -_animation.value),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.keyboard_arrow_down, size: 30, color: PrimaryAccent, shadows: [Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 2, offset: const Offset(0, 1))]),
                                        Container(
                                          width: 24, height: 24,
                                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle, border: Border.all(color: PrimaryAccent, width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, 2))]),
                                          child: Center(child: Text("${step.number}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PrimaryAccent))),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          )),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- UPDATED BOTTOM SHEET UI ---
  Widget _buildStepSheet(MakeupStepData step) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header: Number + Title
          Row(
            children: [
              Container(
                width: 40, height: 40, alignment: Alignment.center,
                decoration: BoxDecoration(color: PrimaryAccent.withOpacity(0.1), shape: BoxShape.circle),
                child: Text("${step.number}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PrimaryAccent)),
              ),
              const SizedBox(width: 15),
              Expanded(child: Text(step.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: TextColor))),
            ],
          ),
          
          const SizedBox(height: 25),
          
          // 2. Step Image (New Field)
          Center(
            child: Container(
              height: 180, // Fixed height for the step visual
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  step.imageAsset, // Use the new imageAsset field
                  fit: BoxFit.contain, // Ensure full illustration is visible
                  errorBuilder: (c, e, s) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      const SizedBox(height: 5),
                      Text("Image not found: ${step.imageAsset}", textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 25),
          
          // 3. Product/Color Code (New Field)
          const Text("Shade Used:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)), 
          const SizedBox(height: 10),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
              ]
            ),
            child: Row(
              children: [
                // Color Circle (The Swatch)
                Container(
                  width: 45, height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Dynamic color based on the text
                    color: _getColorForShade(step.colorCode),
                    border: Border.all(color: Colors.grey.shade300, width: 3), // White/Grey ring
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
                    ]
                  ),
                ),
                const SizedBox(width: 15),
                
                // Text Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.colorCode, // "BB Cream", "Ruby Red", etc.
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: TextColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Recommended Shade", 
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500)
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 40), 
        ],
      ),
    );
  }
}