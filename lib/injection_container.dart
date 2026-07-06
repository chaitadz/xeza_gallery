import 'package:dio/dio.dart';
import 'package:xeza_gallery/features/nasa_gallery/data/datasources/nasa_remote_data_source_impl.dart';
import 'package:xeza_gallery/features/nasa_gallery/domain/repositories/nasa_repository_impl.dart';
import 'package:xeza_gallery/features/nasa_gallery/presentation/view_model/bloc/nasa/nasa_bloc_bloc.dart';
import 'package:xeza_gallery/features/nasa_gallery/presentation/view_model/bloc/favorite/favorites_bloc_bloc.dart';
import 'package:xeza_gallery/features/nasa_gallery/presentation/view_model/favorite_view_model.dart';

class InjectionContainer {
  static NasaBlocBloc createNasaBlocBloc() {
    final dio = Dio();
    final remoteDataSource = NasaRemoteDataSourceImpl(dio);
    final repository = NasaRepositoryImpl(remoteDataSource);
    return NasaBlocBloc(repository);
  }

  static FavoritesBlocBloc createFavoritesBlocBloc() {
    return FavoritesBlocBloc(FavoriteViewModel())..add(LoadFavorites());
  }
}