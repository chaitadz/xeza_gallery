import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xeza_gallery/presentation/bloc/favorite/favorites_bloc_bloc.dart';

class FavoriteButton extends StatelessWidget {
  final String imageUrl;

  const FavoriteButton({
    super.key,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesBlocBloc, FavoritesBlocState>(
      buildWhen: (prev, curr) {
        if (prev is FavoritesBlocLoaded && curr is FavoritesBlocLoaded) {
          return prev.isFavorite(imageUrl) != curr.isFavorite(imageUrl);
        }
        return prev != curr;
      },
      builder: (context, state) {
        final isFavorite =
            state is FavoritesBlocLoaded && state.isFavorite(imageUrl);

        return Material(
          color: Colors.white.withValues(alpha: 0.9),
          shape: const CircleBorder(),
          elevation: 2,
          child: IconButton(
            onPressed: () {
              context
                  .read<FavoritesBlocBloc>()
                  .add(ToggleFavorite(imageUrl));
            },
            tooltip: isFavorite ? 'Remove' : 'Add',
            icon: Icon(
              isFavorite ? Icons.star : Icons.star_border,
              color: isFavorite
                  ? Colors.amber
                  : Colors.amber.withValues(alpha: 0.5),
              size: 28,
            ),
          ),
        );
      },
    );
  }
}