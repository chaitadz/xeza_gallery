
import 'package:xeza_gallery/nasa_repository/data/models/nasa_item_model.dart';

abstract class NasaRemoteDataSource {
  Future<List<NasaItemModel>> fetchImages();
}