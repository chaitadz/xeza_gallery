import 'package:xeza_gallery/core/storage/favorites_storage.dart';

class FavoriteViewModel {
  Set<String> _favorites = {};

  Set<String> get favorites => Set.unmodifiable(_favorites);

  Future<void> loadFavorites() async {
    final urls = await FavoritesStorage.getAllFavorites();
    _favorites = urls.toSet();
  }

  Future<void> toggleFavorite(String imageUrl) async {
    if (_favorites.contains(imageUrl)) {
      await FavoritesStorage.removeFavorite(imageUrl);
      _favorites.remove(imageUrl);
    } else {
      await FavoritesStorage.saveFavorite(imageUrl);
      _favorites.add(imageUrl);
    }
  }
}
