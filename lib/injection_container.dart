import 'package:xeza_gallery/repository/data/datasources/nasa_remote_data_source_impl.dart';
import 'package:xeza_gallery/repository/domain/repositories/nasa_repository_impl.dart';
import 'package:xeza_gallery/presentation/bloc/nasa/nasa_bloc_bloc.dart';
import 'package:xeza_gallery/presentation/bloc/favorite/favorites_bloc_bloc.dart';
import 'package:xeza_gallery/presentation/view_model/favorite_view_model.dart';

class InjectionContainer {
  static NasaBlocBloc createNasaBlocBloc() {
    //get api
    final remoteDataSource = NasaRemoteDataSourceImpl();
    final repository = NasaRepositoryImpl(remoteDataSource);
    return NasaBlocBloc(repository);
  }

  static FavoritesBlocBloc createFavoritesBlocBloc() {
    return FavoritesBlocBloc(FavoriteViewModel())..add(LoadFavorites());
  }
}