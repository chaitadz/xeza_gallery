// lib/features/nasa_gallery/data/datasources/nasa_remote_data_source.dart
import '../models/nasa_item_model.dart';

abstract class NasaRemoteDataSource {
  // ✅ สัญญาเท่านั้น - implementation อยู่ใน _impl.dart
  Future<List<NasaItemModel>> fetchImages();
}