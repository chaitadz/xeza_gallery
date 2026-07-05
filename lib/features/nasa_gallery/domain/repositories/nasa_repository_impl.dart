import 'package:xeza_gallery/features/nasa_gallery/data/datasources/nasa_remote_data_source.dart';
import '../../domain/entities/nasa_item.dart';
import '../../domain/repositories/nasa_repository.dart';

class NasaRepositoryImpl implements NasaRepository {
  final NasaRemoteDataSource remoteDataSource;

  NasaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NasaItem>> fetchImages() async {
    return await remoteDataSource.fetchImages();
  }
}