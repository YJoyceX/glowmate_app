import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import 'makeup.dart'; // Access MakeupLook class

class SimpleMakeupDetail extends StatelessWidget {
  final MakeupLook look;

  const SimpleMakeupDetail({super.key, required this.look});

  @override
  Widget build(BuildContext context) {
    List<String> instructionLines = look.description.split(RegExp(r'/n|\n'));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios, color: TextColor), onPressed: () => Navigator.of(context).pop()),
        title: Text(look.title, style: const TextStyle(color: TextColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: look.bgColor.withOpacity(0.3), borderRadius: BorderRadius.circular(20)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(look.imageAsset, fit: BoxFit.contain, errorBuilder: (c, e, s) => const Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Align(alignment: Alignment.centerLeft, child: Text("How to draw:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: TextColor))),
            const SizedBox(height: 10),

            
            ...instructionLines.map((line) {
                    final trimmed = line.trim();
                    if (trimmed.isEmpty) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20.0), 
                      child: Text(
                        trimmed,
                        // Explicitly set alignment to left
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontSize: 15,
                          color: TextColor.withOpacity(0.85),
                          height: 1.7, // Increased line height for readability
                          letterSpacing: 0.2,
                        ),
                      ),
                    );
                  }).toList(),
                  
                  const SizedBox(height: 30),
                  
                  // TIP BOX
                  Container(
                    width: double.infinity, // Ensures box takes full width to allow left alignment inside
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: PrimaryAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: PrimaryAccent.withOpacity(0.1)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align icon and text to top-left
                      children: [
                        const Icon(Icons.lightbulb_outline, color: PrimaryAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pro Tip: Use a light hand and build color gradually for the most natural result.",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 13, 
                              fontStyle: FontStyle.italic, 
                              color: TextColor.withOpacity(0.7),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        );
  }
}