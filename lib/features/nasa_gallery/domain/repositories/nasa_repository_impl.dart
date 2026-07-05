// lib/features/nasa_gallery/data/repositories/nasa_repository_impl.dart
import 'package:xeza_gallery/features/nasa_gallery/data/datasources/nasa_remote_data_source.dart';
import '../../domain/entities/nasa_item.dart';
import '../../domain/repositories/nasa_repository.dart';

class NasaRepositoryImpl implements NasaRepository {
  final NasaRemoteDataSource remoteDataSource;

  // ✅ Constructor - รับ DataSource จากข้างนอก
  NasaRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<NasaItem>> fetchImages() async {
    // ✅ เรียก DataSource
    // - DataSource return List<NasaItemModel> (ซึ่ง extends NasaItem)
    // - Repository return List<NasaItem> (Entity for Domain)
    // - Dart รู้ว่า NasaItemModel is-a NasaItem ดังนั้น auto-cast ได้
    return await remoteDataSource.fetchImages();
  }
}