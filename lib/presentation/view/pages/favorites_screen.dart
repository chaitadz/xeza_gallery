import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xeza_gallery/presentation/bloc/favorite/favorites_bloc_bloc.dart';
import 'package:xeza_gallery/presentation/bloc/nasa/nasa_bloc_bloc.dart';
import 'package:xeza_gallery/presentation/view/widgets/nasa_image_card.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NasaBlocBloc>().add(FetchNasaImages());
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(
          'My Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<FavoritesBlocBloc, FavoritesBlocState>(
        builder: (context, favoriteState) {
          return BlocBuilder<NasaBlocBloc, NasaBlocState>(
            builder: (context, nasaState) {
              if (nasaState is NasaBlocLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (nasaState is NasaBlocError) {
                return Center(child: Text(nasaState.message));
              }

              if (nasaState is NasaBlocLoaded &&
                  favoriteState is FavoritesBlocLoaded) {
                final allItems = nasaState.items;
                final favoriteUrls = favoriteState.favoriteUrls;

                final favorites = allItems
                    .where((item) => favoriteUrls.contains(item.imageUrl))
                    .toList();

                if (favorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No favorites yet',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start adding images to your favorites',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.builder(
                    itemCount: favorites.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.7,
                    ),
                    itemBuilder: (context, index) {
                      final item = favorites[index];
                      return NasaImageCard(
                        item: item,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(
                                item: item,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }
}
