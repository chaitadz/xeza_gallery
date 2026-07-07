import 'package:xeza_gallery/repository/data/datasources/nasa_remote_data_source.dart';
import '../entities/nasa_item.dart';
import 'nasa_repository.dart';

class NasaRepositoryImpl implements NasaRepository {
  final NasaRemoteDataSource remoteDataSource;

  NasaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NasaItem>> fetchImages() async {
    return await remoteDataSource.fetchImages();
  }
}