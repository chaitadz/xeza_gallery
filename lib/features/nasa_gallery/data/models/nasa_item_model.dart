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
      title: json['title'] ?? 'No Title',
      center: json['center'] ?? 'NASA',
      dateCreated: json['dateCreated'] ?? '',
      description: json['description'] ?? 'No description available.',
      imageUrl: json['imageUrl'] ??
          'https://play-lh.googleusercontent.com/ei29iYY5zisiQuJ-GfX3Qpe2BzsLYgJi5-yllcJt4ciYHdgdtWv62kf_v5zLW4wNHw=w7680-h4320-rw',
      keywords: List<String>.from(json['keywords'] ?? []),
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