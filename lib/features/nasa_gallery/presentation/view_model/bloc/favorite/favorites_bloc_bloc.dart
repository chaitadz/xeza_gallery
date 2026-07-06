import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xeza_gallery/features/nasa_gallery/presentation/view_model/favorite_view_model.dart';

part 'favorites_bloc_event.dart';
part 'favorites_bloc_state.dart';

class FavoritesBlocBloc extends Bloc<FavoritesBlocEvent, FavoritesBlocState> {
  final FavoriteViewModel _viewModel;

  FavoritesBlocBloc(this._viewModel) : super(FavoritesBlocInitial()) {
    on<LoadFavorites>((event, emit) async {
      final urls = await _viewModel.loadFavorites();
      emit(FavoritesBlocLoaded(urls));
    });

    on<ToggleFavorite>((event, emit) async {
      final current = state;
      if (current is! FavoritesBlocLoaded) return;
      final urls = await _viewModel.toggleFavorite(
          current.favoriteUrls, event.imageUrl);
      emit(FavoritesBlocLoaded(urls));
    });
  }
}
