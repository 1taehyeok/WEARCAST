import 'dart:io';
import 'package:flutter/material.dart';

class ClothingImage extends StatelessWidget {
  final String path;
  final BoxFit fit;

  const ClothingImage({
    super.key,
    required this.path,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    } else {
      return Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }
  }
}
