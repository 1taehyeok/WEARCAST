import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../core/providers/clothing_provider.dart';
import '../../core/widgets/clothing_image.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _urlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text("Enter URL"),
              onTap: () {
                Navigator.pop(context);
                _showAddUrlDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Pick from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUrlDialog() {
    _urlController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Clothing URL"),
        content: TextField(
          controller: _urlController,
          decoration: const InputDecoration(
            hintText: "https://example.com/image.jpg",
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final url = _urlController.text.trim();
              if (url.isNotEmpty) {
                ref.read(clothingProvider.notifier).addClothing(url);
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      // Persist the file by copying it to app documents
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(image.path);
      final savedImage = await File(image.path).copy('${directory.path}/$fileName');

      ref.read(clothingProvider.notifier).addClothing(savedImage.path);
    } catch (e) {
      debugPrint("Error picking image: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Error picking image: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final clothingList = ref.watch(clothingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Clothing Settings"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Reset to Defaults",
            onPressed: () {
               ref.read(clothingProvider.notifier).resetToDefaults();
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        child: const Icon(Icons.add),
      ),
      body: clothingList.isEmpty
          ? const Center(child: Text("No clothing items added."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: clothingList.length,
              itemBuilder: (context, index) {
                final url = clothingList[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[800],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ClothingImage(path: url, fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () {
                        ref.read(clothingProvider.notifier).removeClothing(url);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
