import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/favorite/favorite_bloc.dart';
import '../bloc/favorite/favorite_event.dart';
import '../bloc/favorite/favorite_state.dart';
import 'widgets/message_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages Favoris'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple.shade900,
        foregroundColor: Colors.white,
        actions: [
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              if (state is FavoriteLoaded && state.favorites.isNotEmpty) {
                return IconButton(
                  icon: const Icon(
                    Icons.delete_sweep,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () => _showClearFavoritesDialog(context),
                  tooltip: 'Supprimer tous les favoris',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              if (state is FavoriteLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.deepPurple,
                    ),
                  ),
                );
              } else if (state is FavoriteLoaded) {
                final favorites = state.favorites;
                if (favorites.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 64),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun message favori',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Ajoutez des messages en favoris pour les retrouver ici',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: favorites.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final message = favorites[index];
                    return MessageCard(message: message);
                  },
                );
              } else if (state is FavoriteError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'Une erreur est survenue',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(),
                        onPressed: () {
                          context.read<FavoriteBloc>().add(LoadFavorites());
                        },
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  void _showClearFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer tous les favoris'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer tous vos messages favoris ? Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(),
            onPressed: () {
              context.read<FavoriteBloc>().add(ClearAllFavorites());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tous les favoris ont été supprimés'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
