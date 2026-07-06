import 'package:flutter/material.dart';
import 'package:xeza_gallery/core/storage/favorites_storage.dart';

class FavoriteButton extends StatefulWidget {
  final String imageUrl;
  final VoidCallback? onChanged;

  const FavoriteButton({
    super.key,
    required this.imageUrl,
    this.onChanged,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late bool _isFavorite;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _checkFavoriteStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkFavoriteStatus() async {
    final isFav = await FavoritesStorage.isFavorite(widget.imageUrl);
    setState(() {
      _isFavorite = isFav;
      if (_isFavorite) {
        _animationController.forward();
      }
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      if (_isFavorite) {
        await FavoritesStorage.removeFavorite(widget.imageUrl);
        _animationController.reverse();
      } else {
        await FavoritesStorage.saveFavorite(widget.imageUrl);
        _animationController.forward();
      }

      setState(() => _isFavorite = !_isFavorite);
      widget.onChanged?.call();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isFavorite ? '⭐ Added' : '✓ Removed',
            ),
            duration: const Duration(milliseconds: 1200),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('❌ Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.15).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      ),
      child: Material(
        color: Colors.white.withValues(alpha: 0.9),
        shape: const CircleBorder(),
        elevation: 2,
        child: IconButton(
          onPressed: _isLoading ? null : _toggleFavorite,
          tooltip: _isFavorite ? 'Remove' : 'Add',
          icon: Icon(
            _isFavorite ? Icons.star : Icons.star_border,
            color: _isFavorite ? Colors.amber : Colors.amber.withValues(alpha: 0.5),
            size: 28,
          ),
        ),
      ),
    );
  }
}