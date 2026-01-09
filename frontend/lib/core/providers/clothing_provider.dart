import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final clothingProvider = NotifierProvider<ClothingNotifier, List<String>>(ClothingNotifier.new);

class ClothingNotifier extends Notifier<List<String>> {
  static const String _key = 'clothing_list';

  // Default list if nothing is saved
  final List<String> _defaults = [
    "https://upload.wikimedia.org/wikipedia/commons/2/24/Blue_Tshirt.jpg",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1a/24701-nature-natural-beauty.jpg/1280px-24701-nature-natural-beauty.jpg",
    "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a0/Circle_-_black_simple.svg/800px-Circle_-_black_simple.svg.png"
  ];

  @override
  List<String> build() {
    // Initial load
    _loadClothing();
    return [];
  }

  Future<void> _loadClothing() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? stored = prefs.getStringList(_key);
    if (stored != null && stored.isNotEmpty) {
      state = stored;
    } else {
      state = _defaults;
      // Save defaults so they persist if we want, or just keep in memory until modified
    }
  }

  Future<void> addClothing(String url) async {
    if (state.contains(url)) return;
    state = [...state, url];
    await _saveClothing();
  }

  Future<void> removeClothing(String url) async {
    state = state.where((item) => item != url).toList();
    await _saveClothing();
  }

  Future<void> resetToDefaults() async {
    state = _defaults;
    await _saveClothing();
  }

  Future<void> _saveClothing() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, state);
  }
}
