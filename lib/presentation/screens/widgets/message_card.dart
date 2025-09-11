import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../data/models/message_model.dart';
import '../../bloc/ads/ads_bloc.dart';
import '../../bloc/favorite/favorite_bloc.dart';
import '../../bloc/favorite/favorite_event.dart';
import '../../bloc/favorite/favorite_state.dart';
import '../message_detail_screen.dart';
import 'interstitial_ad.dart';

class MessageCard extends StatefulWidget {
  final MessageModel message;
  final VoidCallback? onFavoriteChanged;
  final bool showCategory;

  const MessageCard({
    super.key,
    required this.message,
    this.onFavoriteChanged,
    this.showCategory = false,
  });

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  void initState() {
    super.initState();
    InterstitialAdManager.showInterstitial(context, context.read<AdBloc>());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FavoriteBloc, FavoriteState>(
      listener: (context, state) {
        if (widget.onFavoriteChanged != null && state is FavoriteLoaded) {
          widget.onFavoriteChanged!();
        }
      },
      builder: (context, state) {
        bool isFav = false;
        if (state is FavoriteLoaded) {
          isFav = state.favorites.any((m) => m.id == widget.message.id);
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () async {
              InterstitialAdManager.showInterstitial(
                context,
                context.read<AdBloc>(),
              );
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MessageDetailScreen(message: widget.message),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec catégorie (si activée)
                  if (widget.showCategory)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(widget.message.category),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getCategoryName(widget.message.category),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Contenu du message
                  Text(
                    widget.message.text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,

                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // Barre d'actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bouton Favori avec animation
                      _FavoriteButton(
                        isFavorite: isFav,
                        onPressed: () {
                          final bloc = BlocProvider.of<FavoriteBloc>(context);
                          if (isFav) {
                            bloc.add(RemoveFavorite(widget.message));
                            _showSnackBar(context, 'Retiré des favoris ❤️');
                          } else {
                            bloc.add(AddFavorite(widget.message));
                            _showSnackBar(context, 'Ajouté aux favoris 💖');
                          }
                        },
                      ),

                      // Boutons d'action secondaires
                      Row(
                        children: [
                          // Bouton Copier
                          IconButton(
                            icon: const Icon(Icons.content_copy, size: 20),
                            color: Colors.blue,
                            onPressed: () {
                              _copyToClipboard(context, widget.message.text);
                            },
                            tooltip: 'Copier le message',
                          ),

                          // Bouton Partager
                          IconButton(
                            icon: const Icon(Icons.share, size: 20),
                            color: Colors.green,
                            onPressed: () {
                              _shareMessage(context, widget.message.text);
                            },
                            tooltip: 'Partager le message',
                          ),

                          // Bouton Voir plus
                          IconButton(
                            icon: const Icon(Icons.visibility, size: 20),
                            color: Colors.deepPurple,
                            onPressed: () async {
                              InterstitialAdManager.showInterstitial(
                                context,
                                context.read<AdBloc>(),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MessageDetailScreen(
                                    message: widget.message,
                                  ),
                                ),
                              );
                            },
                            tooltip: 'Voir les détails',
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Méthodes utilitaires
  Color _getCategoryColor(String category) {
    final colors = {
      "drague": Colors.pink,
      "pardon": Colors.blue,
      "anniversaire": Colors.orange,
      "condoleances": Colors.grey,
      "merci": Colors.green,
      "felicitations": Colors.yellow,
      "bonjour_bonne_nuit": Colors.lightBlue,
      "motivation": Colors.deepPurple,
      "fetes": Colors.red,
      "amitie": Colors.teal,
      "autres": Colors.brown,
    };
    return colors[category] ?? Colors.deepPurple;
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

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(context, 'Message copié 📋');
  }

  void _shareMessage(BuildContext context, String text) {
    Share.share(text);
    _showSnackBar(context, 'Partage en cours... 📤');
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// Bouton Favori avec animation
class _FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  @override
  __FavoriteButtonState createState() => __FavoriteButtonState();
}

class __FavoriteButtonState extends State<_FavoriteButton> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: widget.isFavorite
            ? Colors.red.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            key: ValueKey<bool>(widget.isFavorite),
            color: widget.isFavorite ? Colors.red : Colors.grey,
            size: 24,
          ),
        ),
        onPressed: () {
          setState(() {});
          widget.onPressed();
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {});
          });
        },
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// Variante compacte pour les listes denses
class CompactMessageCard extends StatelessWidget {
  final MessageModel message;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const CompactMessageCard({
    super.key,
    required this.message,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onShare,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Text(
          message.text,
          style: const TextStyle(fontSize: 14),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: onFavoriteToggle,
            ),
            IconButton(
              icon: const Icon(Icons.share, size: 20, color: Colors.green),
              onPressed: onShare,
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageDetailScreen(message: message),
            ),
          );
        },
      ),
    );
  }
}

// Variante pour la grille
class GridMessageCard extends StatelessWidget {
  final MessageModel message;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const GridMessageCard({
    super.key,
    required this.message,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MessageDetailScreen(message: message),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  message.text,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey,
                    size: 20,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
