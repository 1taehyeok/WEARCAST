import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/api/api_client.dart';
import '../clothing/clothing_screen.dart';

class SegmentationScreen extends ConsumerStatefulWidget {
  final File image;
  const SegmentationScreen({super.key, required this.image});

  @override
  ConsumerState<SegmentationScreen> createState() => _SegmentationScreenState();
}

class _SegmentationScreenState extends ConsumerState<SegmentationScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _segmentationResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _performSegmentation();
  }

  Future<void> _performSegmentation() async {
    try {
      final result = await ref.read(apiClientProvider).segmentImage(widget.image);
      setState(() {
        _segmentationResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _proceedToClothing() {
    if (_segmentationResult == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClothingScreen(
          personImage: widget.image,
          maskUrl: _segmentationResult!['mask_url'],
          personId: _segmentationResult!['selected_person_id'].toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Segmentation")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text("Error: $_error"))
              : Column(
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(widget.image, fit: BoxFit.contain),
                          // Overlay for bounding boxes
                          if (_segmentationResult != null)
                            CustomPaint(
                              painter: BBoxPainter(
                                persons: _segmentationResult!['persons'],
                                selectedId: _segmentationResult!['selected_person_id'],
                                imgWidth: _segmentationResult!['image_width'],
                                imgHeight: _segmentationResult!['image_height'],
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: _proceedToClothing,
                        child: const Text("Select Clothing"),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class BBoxPainter extends CustomPainter {
  final List<dynamic> persons;
  final int? selectedId;
  final int imgWidth;
  final int imgHeight;

  BBoxPainter({
    required this.persons,
    required this.selectedId,
    required this.imgWidth,
    required this.imgHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / imgWidth;
    final double scaleY = size.height / imgHeight;
    // Fit containment usually preserves aspect ratio. 
    // Image.file(fit: BoxFit.contain) centers the image.
    // Determining exact paint rect is tricky without LayoutBuilder details.
    // Simplifying assumption: Image fills width or height.
    
    // For robust rendering, we'd calculate the actual rect of the image within the container.
    // Here we'll just try to scale normalized to the View size assuming it fills or verify logic later.
    // Actually, getting correct overlay coordinates on different aspect ratios is painful.
    // Let's implement a simple "scale to fit" logic.
    
    double renderScale = 1.0;
    double dx = 0.0;
    double dy = 0.0;

    double screenAspect = size.width / size.height;
    double imageAspect = imgWidth / imgHeight;

    if (screenAspect > imageAspect) {
      // Screen is wider than image. Image fits height.
      renderScale = size.height / imgHeight;
      dx = (size.width - (imgWidth * renderScale)) / 2;
    } else {
      // Screen is taller. Image fits width.
      renderScale = size.width / imgWidth;
      dy = (size.height - (imgHeight * renderScale)) / 2;
    }

    final paintNormal = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintSelected = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    for (var person in persons) {
      final id = person['id'];
      final bbox = person['bbox']; // [x1, y1, x2, y2]
      final x1 = bbox[0] * renderScale + dx;
      final y1 = bbox[1] * renderScale + dy;
      final w = (bbox[2] - bbox[0]) * renderScale;
      final h = (bbox[3] - bbox[1]) * renderScale;

      canvas.drawRect(
        Rect.fromLTWH(x1, y1, w, h),
        id == selectedId ? paintSelected : paintNormal,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
