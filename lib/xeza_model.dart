class XezaItem {
  final String title;
  final String center;
  final String dateCreated;
  final String description;
  final String imageUrl;
  final List<String> keywords;

  XezaItem({
    required this.title,
    required this.center,
    required this.dateCreated,
    required this.description,
    required this.imageUrl,
    required this.keywords,
  });

  factory XezaItem.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>?;
    final linksList = json['links'] as List<dynamic>?;
    final data = dataList != null && dataList.isNotEmpty ? dataList[0] : {};

    String imgUrl = 'https://via.placeholder.com/150';
    if (linksList != null && linksList.isNotEmpty) {
      final firstLink = linksList[0];
      if (firstLink is Map && firstLink.containsKey('href')) {
        imgUrl = firstLink['href'] ?? imgUrl;
        if (imgUrl.startsWith('http://')) {
          imgUrl = imgUrl.replaceFirst('http://', 'https://');
        }
      }
    }

    return XezaItem(
      title: data['title'] ?? 'No Title',
      center: data['center'] ?? 'NASA',
      dateCreated: data['date_created'] ?? '',
      description: data['description'] ?? 'No description available.',
      imageUrl: imgUrl,
      keywords: List<String>.from(data['keywords'] ?? []),
    );
  }
}
