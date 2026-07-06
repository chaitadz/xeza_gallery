import 'package:xeza_gallery/core/storage/favorites_storage.dart';

class FavoriteViewModel {
  Future<Set<String>> loadFavorites() async {
    final urls = await FavoritesStorage.getAllFavorites();
    return urls.toSet();
  }

  Future<Set<String>> toggleFavorite(
      Set<String> currentUrls, String imageUrl) async {
    final urls = Set<String>.from(currentUrls);
    if (urls.contains(imageUrl)) {
      await FavoritesStorage.removeFavorite(imageUrl);
      urls.remove(imageUrl);
    } else {
      await FavoritesStorage.saveFavorite(imageUrl);
      urls.add(imageUrl);
    }
    return urls;
  }
}
