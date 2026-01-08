import 'dart:io';
import 'package:flutter/material.dart';
import '../result/result_screen.dart';

class ClothingScreen extends StatelessWidget {
  final File personImage;
  final String? maskUrl;
  final String personId;

  const ClothingScreen({
    super.key,
    required this.personImage,
    required this.maskUrl,
    required this.personId,
  });

  final List<String> clothingSamples = const [
    "https://upload.wikimedia.org/wikipedia/commons/2/24/Blue_Tshirt.jpg", 
    "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/24701-nature-natural-beauty.jpg/1280px-24701-nature-natural-beauty.jpg", // Just a random image distinct from first
    "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Circle_-_black_simple.svg/800px-Circle_-_black_simple.svg.png" // distinct pattern
  ];

  void _onClothingSelected(BuildContext context, String clothingUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          personImage: personImage,
          maskUrl: maskUrl,
          personId: personId,
          clothingUrl: clothingUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Clothing")),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: clothingSamples.length,
        itemBuilder: (context, index) {
          final url = clothingSamples[index];
          return GestureDetector(
            onTap: () => _onClothingSelected(context, url),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Image.network(url, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => 
                  const Center(child: Icon(Icons.broken_image)),
              ),
            ),
          );
        },
      ),
    );
  }
}
