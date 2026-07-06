import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:xeza_gallery/features/nasa_gallery/presentation/view_model/favorite_view_model.dart';

part 'favorites_bloc_event.dart';
part 'favorites_bloc_state.dart';

class FavoritesBlocBloc extends Bloc<FavoritesBlocEvent, FavoritesBlocState> {
  final FavoriteViewModel _viewModel;

  FavoritesBlocBloc(this._viewModel) : super(FavoritesBlocInitial()) {
    on<LoadFavorites>((event, emit) async {
      await _viewModel.loadFavorites();
      emit(FavoritesBlocLoaded(_viewModel.favorites));
    });

    on<ToggleFavorite>((event, emit) async {
      await _viewModel.toggleFavorite(event.imageUrl);
      emit(FavoritesBlocLoaded(_viewModel.favorites));
    });
  }
}
