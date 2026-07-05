// lib/features/nasa_gallery/data/datasources/nasa_remote_data_source_impl.dart
import 'package:dio/dio.dart';
import '../models/nasa_item_model.dart';
import 'nasa_remote_data_source.dart';

class NasaRemoteDataSourceImpl implements NasaRemoteDataSource {
  final Dio _dio;

  // ✅ Constructor - รับ Dio instance จากข้างนอก (Dependency Injection)
  NasaRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NasaItemModel>> fetchImages() async {
    try {
      final response = await _dio.get(
        'https://images-api.nasa.gov/search?q=earth&media_type=image',
      );

      if (response.statusCode == 200) {
        final List<dynamic> items =
            response.data['collection']['items'] ?? [];

        // ✅ Parse JSON → NasaItemModel (ตรงนี้เป็นที่เดียวที่ทำ JSON parsing)
        final List<NasaItemModel> nasaItems = items.map((item) {
          final data = (item['data'] as List).first;
          final links = item['links'] as List?;

          String imageUrl =
              'https://play-lh.googleusercontent.com/ei29iYY5zisiQuJ-GfX3Qpe2BzsLYgJi5-yllcJt4ciYHdgdtWv62kf_v5zLW4wNHw=w7680-h4320-rw';

          if (links != null && links.isNotEmpty) {
            imageUrl = links.first['href'] ?? imageUrl;
          }

          return NasaItemModel.fromJson({
            'title': data['title'],
            'center': data['center'],
            'dateCreated': data['date_created'],
            'description': data['description'],
            'imageUrl': imageUrl,
            'keywords': data['keywords'] ?? [],
          });
        }).toList();

        return nasaItems;
      } else {
        throw Exception(
          'เซิร์ฟเวอร์ตอบกลับผิดพลาด: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }
}