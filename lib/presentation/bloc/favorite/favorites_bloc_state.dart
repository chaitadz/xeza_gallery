part of 'favorites_bloc_bloc.dart';

@immutable
sealed class FavoritesBlocState {}

final class FavoritesBlocInitial extends FavoritesBlocState {}

final class FavoritesBlocLoaded extends FavoritesBlocState {
  final Set<String> favoriteUrls;

  FavoritesBlocLoaded(this.favoriteUrls);

  bool isFavorite(String imageUrl) => favoriteUrls.contains(imageUrl);
}
