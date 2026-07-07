import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../nasa_repository/domain/entities/nasa_item.dart';
import '../../bloc/favorite/favorites_bloc_bloc.dart';

class NasaImageCard extends StatelessWidget {
  final NasaItem item;
  final VoidCallback onTap;

  const NasaImageCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        key: ValueKey('onTap_card'),
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.black,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(child: Icon(Icons.broken_image)),
                    ),
                  ),
                  BlocBuilder<FavoritesBlocBloc, FavoritesBlocState>(
                    buildWhen: (prev, curr) {
                      if (prev is FavoritesBlocLoaded &&
                          curr is FavoritesBlocLoaded) {
                        return prev.isFavorite(item.imageUrl) !=
                            curr.isFavorite(item.imageUrl);
                      }
                      return prev != curr;
                    },
                    builder: (context, state) {
                      final isFavorite = state is FavoritesBlocLoaded &&
                          state.isFavorite(item.imageUrl);
                      if (!isFavorite) return const SizedBox.shrink();
                      return Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.center.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
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
