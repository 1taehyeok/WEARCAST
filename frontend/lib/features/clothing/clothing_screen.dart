import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/clothing_provider.dart';
import '../../core/widgets/clothing_image.dart';
import '../result/result_screen.dart';

class ClothingScreen extends ConsumerWidget {
  final File personImage;
  final String? maskUrl;
  final String personId;

  const ClothingScreen({
    super.key,
    required this.personImage,
    required this.maskUrl,
    required this.personId,
  });

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
  Widget build(BuildContext context, WidgetRef ref) {
    final clothingSamples = ref.watch(clothingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Select Clothing")),
      body: clothingSamples.isEmpty
          ? const Center(
              child: Text(
                "No clothing available.\nGo to Settings to add clothing.",
                textAlign: TextAlign.center,
              ),
            )
          : GridView.builder(
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
                    child: ClothingImage(path: url),
                  ),
                );
              },
            ),
    );
  }
}

