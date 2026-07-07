import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xeza_gallery/presentation/bloc/favorite/favorites_bloc_bloc.dart';

class FavoriteButton extends StatefulWidget {
  final String imageUrl;

  const FavoriteButton({
    super.key,
    required this.imageUrl,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<FavoritesBlocBloc>().state;
      if (state is FavoritesBlocLoaded && state.isFavorite(widget.imageUrl)) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoritesBlocBloc, FavoritesBlocState>(
      listenWhen: (prev, curr) {
        if (curr is! FavoritesBlocLoaded) return false;
        return true;
      },
      listener: (context, state) {
        if (state is FavoritesBlocLoaded) {
          if (state.isFavorite(widget.imageUrl)) {
            _animationController.forward();
          } else {
            _animationController.reverse();
          }
        }
      },
      buildWhen: (prev, curr) {
        if (prev is FavoritesBlocLoaded && curr is FavoritesBlocLoaded) {
          return prev.isFavorite(widget.imageUrl) !=
              curr.isFavorite(widget.imageUrl);
        }
        return prev != curr;
      },
      builder: (context, state) {
        final isFavorite =
            state is FavoritesBlocLoaded && state.isFavorite(widget.imageUrl);

        return ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.15).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.elasticOut),
          ),
          child: Material(
            color: Colors.white.withValues(alpha: 0.9),
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              onPressed: () {
                context
                    .read<FavoritesBlocBloc>()
                    .add(ToggleFavorite(widget.imageUrl));
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
          ),
        );
      },
    );
  }
}
