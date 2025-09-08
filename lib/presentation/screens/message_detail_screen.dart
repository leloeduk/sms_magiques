import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';
import '../../data/models/message_model.dart';
import '../bloc/favorite/favorite_bloc.dart';
import '../bloc/favorite/favorite_event.dart';
import '../bloc/favorite/favorite_state.dart';

class MessageDetailScreen extends StatelessWidget {
  final MessageModel message;
  const MessageDetailScreen({super.key, required this.message});

  Color _getCategoryColor(String category) {
    final colors = {
      "drague": Colors.pink.shade900,
      "pardon": Colors.blue.shade900,
      "anniversaire": Colors.orange.shade900,
      "condoleances": Colors.grey.shade900,
      "merci": Colors.green.shade900,
      "felicitations": Colors.yellow.shade900,
      "bonjour_bonne_nuit": Colors.lightBlue.shade900,
      "motivation": Colors.deepPurple.shade900,
      "fetes": Colors.red.shade900,
      "amitie": Colors.teal.shade900,
      "autres": Colors.brown.shade900,
    };
    return colors[category] ?? Colors.deepPurple.shade900;
  }

  String _getCategoryName(String category) {
    final names = {
      "drague": "Drague",
      "pardon": "Pardon",
      "anniversaire": "Anniversaire",
      "condoleances": "Condoléances",
      "merci": "Merci",
      "felicitations": "Félicitations",
      "bonjour_bonne_nuit": "Salutations",
      "motivation": "Motivation",
      "fetes": "Fêtes",
      "amitie": "Amitié",
      "autres": "Autres",
    };
    return names[category] ?? category;
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(message.category);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // AppBar personnalisé avec effet de parallaxe
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: categoryColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _getCategoryName(message.category),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 10.0,
                      color: Colors.black45,
                      offset: Offset(2.0, 2.0),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      categoryColor.withOpacity(0.9),
                      categoryColor.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.format_quote,
                  size: 80,
                  color: Colors.white30,
                ),
              ),
            ),
            actions: [
              BlocBuilder<FavoriteBloc, FavoriteState>(
                builder: (context, state) {
                  final isFavorite =
                      state is FavoriteLoaded &&
                      state.favorites.any((m) => m.id == message.id);

                  return IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFavorite),
                        color: isFavorite ? Colors.red : Colors.grey,
                        size: 28,
                      ),
                    ),
                    onPressed: () {
                      final bloc = context.read<FavoriteBloc>();
                      if (isFavorite) {
                        bloc.add(RemoveFavorite(message));
                        _showSnackBar(context, 'Retiré des favoris ❤️');
                      } else {
                        bloc.add(AddFavorite(message));
                        _showSnackBar(context, 'Ajouté aux favoris 💖');
                      }
                    },
                  );
                },
              ),
            ],
          ),

          // Contenu du message
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Carte du message
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    shadowColor: categoryColor.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(28.0),
                      child: SelectableText(
                        message.text,
                        style: TextStyle(
                          fontSize: 20,
                          height: 1.6,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[800],
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Badge de catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: categoryColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getCategoryName(message.category).toUpperCase(),
                      style: TextStyle(
                        color: categoryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Copier
                      _ActionButton(
                        icon: Icons.content_copy,
                        label: 'Copier',
                        color: Colors.blue,
                        onPressed: () {
                          FlutterClipboard.copy(message.text).then((value) {
                            _showSnackBar(context, 'Message copié 📋');
                          });
                        },
                      ),

                      // Bouton Partager
                      _ActionButton(
                        icon: Icons.share,
                        label: 'Partager',
                        color: Colors.green,
                        onPressed: () {
                          Share.share(
                            message.text,
                            subject:
                                'Message Magique - ${_getCategoryName(message.category)}',
                          );
                          _showSnackBar(context, 'Partage en cours... 📤');
                        },
                      ),

                      // Bouton SMS
                      _ActionButton(
                        icon: Icons.sms,
                        label: 'SMS',
                        color: Colors.purple,
                        onPressed: () {
                          _showSmsDialog(context, message.text);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Statistiques (optionnel)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          icon: Icons.text_fields,
                          value: '${message.text.length}',
                          label: 'caractères',
                        ),
                        _StatItem(
                          icon: Icons.article,
                          value: '${message.text.split(' ').length}',
                          label: 'mots',
                        ),
                        _StatItem(
                          icon: Icons.access_time,
                          value: '${(message.text.length / 15).ceil()}',
                          label: 'secondes',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bouton flottant pour les actions rapides
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showActionSheet(context, message.text, categoryColor);
        },
        backgroundColor: categoryColor,
        child: const Icon(Icons.more_vert, color: Colors.white, size: 28),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _showSmsDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer par SMS'),
        content: const Text('Fonctionnalité SMS à implémenter'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Envoi SMS simulé 📱');
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(BuildContext context, String text, Color color) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Poignée
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),

              // Options
              _ActionSheetItem(
                icon: Icons.content_copy,
                title: 'Copier le message',
                color: color,
                onTap: () {
                  Navigator.pop(context);
                  FlutterClipboard.copy(text);
                  _showSnackBar(context, 'Message copié 📋');
                },
              ),

              _ActionSheetItem(
                icon: Icons.share,
                title: 'Partager le message',
                color: color,
                onTap: () {
                  Navigator.pop(context);
                  Share.share(text);
                },
              ),

              _ActionSheetItem(
                icon: Icons.edit,
                title: 'Modifier le message',
                color: color,
                onTap: () {
                  Navigator.pop(context);
                  _showEditDialog(context, text);
                },
              ),

              _ActionSheetItem(
                icon: Icons.translate,
                title: 'Traduire le message',
                color: color,
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar(context, 'Traduction à implémenter 🌍');
                },
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier le message'),
        content: TextField(
          controller: TextEditingController(text: text),
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Modifiez votre message...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar(context, 'Modification enregistrée ✏️');
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}

// Composant Bouton d'Action
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3), width: 2),
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Composant Item de Statistique
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }
}

// Composant Item de ActionSheet
class _ActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _ActionSheetItem({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
