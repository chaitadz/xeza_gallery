import 'package:get_storage/get_storage.dart';

class FavoritesStorage {
  static final _box = GetStorage();
  static const String _key = 'nasa_favorites';

  static Future<void> saveFavorite(String imageUrl) async {
    try {
      final list = _getAllSync();
      if (!list.contains(imageUrl)) {
        list.add(imageUrl);
        await _box.write(_key, list);
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<void> removeFavorite(String imageUrl) async {
    try {
      final list = _getAllSync();
      list.removeWhere((url) => url == imageUrl);
      await _box.write(_key, list);
    } catch (e) {
      print('Error: $e');
    }
  }

  static Future<bool> isFavorite(String imageUrl) async {
    return _getAllSync().contains(imageUrl);
  }

  static Future<List<String>> getAllFavorites() async {
    return _getAllSync();
  }

  static List<String> _getAllSync() {
    final list = _box.read<List>(_key);
    return list?.cast<String>() ?? [];
  }
}