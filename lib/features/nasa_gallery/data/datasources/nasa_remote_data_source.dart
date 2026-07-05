import '../models/nasa_item_model.dart';

abstract class NasaRemoteDataSource {
  Future<List<NasaItemModel>> fetchImages();
}