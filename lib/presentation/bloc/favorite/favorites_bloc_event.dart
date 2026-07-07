part of 'favorites_bloc_bloc.dart';

@immutable
sealed class FavoritesBlocEvent {}

final class LoadFavorites extends FavoritesBlocEvent {}

final class ToggleFavorite extends FavoritesBlocEvent {
  final String imageUrl;
  ToggleFavorite(this.imageUrl);
}
