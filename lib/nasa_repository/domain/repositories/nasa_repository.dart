import '../entities/nasa_item.dart';

abstract class NasaRepository {
  Future<List<NasaItem>> fetchImages();
}