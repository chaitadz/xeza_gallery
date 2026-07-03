import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../model/nasa_item.dart';

abstract class NasaRepository {
  Future<List<NasaItem>> fetchEarthImages();
}

class NasaRepositoryImpl implements NasaRepository {
  NasaRepositoryImpl(this._client);

  final Dio _client;

  @override
  Future<List<NasaItem>> fetchEarthImages() async {
    final response = await _client.get(ApiEndpoints.nasaSearchEarthImages);

    if (response.statusCode != 200) {
      throw Exception('เซิร์ฟเวอร์ตอบกลับผิดพลาด: ${response.statusCode}');
    }

    final List<dynamic> items = response.data['collection']['items'] ?? <dynamic>[];

    return items.map((dynamic item) {
      final Map<String, dynamic> data = (item['data'] as List<dynamic>).first as Map<String, dynamic>;
      final List<dynamic>? links = item['links'] as List<dynamic>?;

      final String imageUrl = _resolveImageUrl(links);

      return NasaItem.fromJson(<String, dynamic>{
        'title': data['title'],
        'center': data['center'],
        'dateCreated': data['date_created'],
        'description': data['description'],
        'imageUrl': imageUrl,
        'keywords': data['keywords'] ?? <String>[],
      });
    }).toList();
  }

  String _resolveImageUrl(List<dynamic>? links) {
    if (links == null || links.isEmpty) {
      return ApiEndpoints.fallbackImageUrl;
    }

    final dynamic href = links.first['href'];
    if (href is String && href.isNotEmpty) {
      return href;
    }

    return ApiEndpoints.fallbackImageUrl;
  }
}