import 'package:flutter/material.dart';
import 'package:xeza_gallery/features/nasa_gallery/presentation/widgets/favorite_button.dart';
import '../../domain/entities/nasa_item.dart';
import '../widgets/info_badge.dart';
import '../widgets/keyword_chip.dart';

class DetailScreen extends StatelessWidget {
  final NasaItem item;

  const DetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 400),
                  color: Colors.black,
                  child: Image.network(item.imageUrl, fit: BoxFit.contain),
                ),

                Positioned(
                  bottom: 16,
                  right: 16,
                  child: FavoriteButton(
                    imageUrl: item.imageUrl,
                    onChanged: () {
                      print('Favorite toggled');
                    },
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      InfoBadge(text: item.center, color: Colors.blue),
                      const SizedBox(width: 8),
                      InfoBadge(
                        text: item.dateCreated.split("T")[0],
                        color: Colors.green,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    item.description,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 8,
                    children: item.keywords
                        .map((e) => KeywordChip(keyword: e))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}