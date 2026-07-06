import 'package:dio/dio.dart';
import '../models/nasa_item_model.dart';
import 'nasa_remote_data_source.dart';

class NasaRemoteDataSourceImpl implements NasaRemoteDataSource {
  final Dio _dio;

  NasaRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NasaItemModel>> fetchImages() async {
    try {
      final response = await _dio.get(
        'https://images-api.nasa.gov/search?q=earth&media_type=image',
      );

      if (response.statusCode == 200) {
        final List<dynamic> items =
            response.data['collection']['items'] as List<dynamic>? ?? [];

        final List<NasaItemModel> nasaItems = items.map((raw) {
          final item = raw as Map<String, dynamic>;
          final data =
              (item['data'] as List<dynamic>).first as Map<String, dynamic>;
          final links = item['links'] as List<dynamic>?;

          String imageUrl =
              'https://play-lh.googleusercontent.com/ei29iYY5zisiQuJ-GfX3Qpe2BzsLYgJi5-yllcJt4ciYHdgdtWv62kf_v5zLW4wNHw=w7680-h4320-rw';

          if (links != null && links.isNotEmpty) {
            final firstLink = links.first as Map<String, dynamic>;
            imageUrl = firstLink['href'] as String? ?? imageUrl;
          }

          return NasaItemModel.fromJson({
            'title': data['title'] as String?,
            'center': data['center'] as String?,
            'dateCreated': data['date_created'] as String?,
            'description': data['description'] as String?,
            'imageUrl': imageUrl,
            'keywords': data['keywords'] as List<dynamic>? ?? [],
          });
        }).toList();

        return nasaItems;
      } else {
        throw Exception('เซิร์ฟเวอร์ตอบกลับผิดพลาด: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }
}
