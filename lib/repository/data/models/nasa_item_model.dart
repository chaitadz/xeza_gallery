import '../../domain/entities/nasa_item.dart';

class NasaItemModel extends NasaItem {
  NasaItemModel({
     required super.title,
    required super.center,
    required super.dateCreated,
    required super.description,
    required super.imageUrl,
    required super.keywords,
  });

  factory NasaItemModel.fromJson(Map<String, dynamic> json) {
    return NasaItemModel(
      title: json['title'] as String? ?? 'No Title',
      center: json['center'] as String? ?? 'NASA',
      dateCreated: json['dateCreated'] as String? ?? '',
      description: json['description'] as String? ?? 'No description available.',
      imageUrl: json['imageUrl'] as String? ??
          'https://play-lh.googleusercontent.com/ei29iYY5zisiQuJ-GfX3Qpe2BzsLYgJi5-yllcJt4ciYHdgdtWv62kf_v5zLW4wNHw=w7680-h4320-rw',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'center': center,
      'dateCreated': dateCreated,
      'description': description,
      'imageUrl': imageUrl,
      'keywords': keywords,
    };
  }
}
