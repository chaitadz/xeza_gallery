class NasaItem {
  final String title;
  final String center;
  final String dateCreated;
  final String description;
  final String imageUrl;
  final List<String> keywords;

  NasaItem({
    required this.title,
    required this.center,
    required this.dateCreated,
    required this.description,
    required this.imageUrl,
    required this.keywords,
  });

  factory NasaItem.fromJson(Map<String, dynamic> json) {
    return NasaItem(
      title: json['title'] ?? 'No Title',
      center: json['center'] ?? 'NASA',
      dateCreated: json['dateCreated'] ?? '',
      description: json['description'] ?? 'No description available.',
      imageUrl: json['imageUrl'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? const <String>[]),
    );
  }
}