import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/message_model.dart';
import '../bloc/favorite/favorite_bloc.dart';
import '../bloc/favorite/favorite_event.dart';
import '../bloc/favorite/favorite_state.dart';
import 'widgets/action_button.dart';
import 'widgets/ads_widget.dart';
import 'widgets/stat_item.dart';

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
                      // ignore: deprecated_member_use
                      categoryColor.withOpacity(0.9),
                      // ignore: deprecated_member_use
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

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: IconButton(
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          key: ValueKey(isFavorite),
                          color: isFavorite ? Colors.red : Colors.grey,
                          size: 40,
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
                    ),
                  );
                },
              ),
            ],
          ),

          // Contenu du message
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Carte du message
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    // ignore: deprecated_member_use
                    shadowColor: categoryColor.withOpacity(0.3),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SelectableText(
                        message.text,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Badge de catégorie
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: categoryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        // ignore: deprecated_member_use
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

                  const SizedBox(height: 30),

                  // Boutons d'action
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bouton Copier
                      ActionButton(
                        icon: Icons.content_copy,
                        label: 'Copier',
                        color: Colors.blue,
                        onPressed: () {
                          FlutterClipboard.copy(message.text).then((value) {
                            // ignore: use_build_context_synchronously
                            _showSnackBar(context, 'Message copié 📋');
                          });
                        },
                      ),

                      // Bouton Partager
                      ActionButton(
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
                      ActionButton(
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
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StatItem(
                          icon: Icons.text_fields,
                          value: '${message.text.length}',
                          label: 'caractères',
                        ),
                        StatItem(
                          icon: Icons.article,
                          value: '${message.text.split(' ').length}',
                          label: 'mots',
                        ),
                        StatItem(
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
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 80),
            sliver: const SliverToBoxAdapter(child: AdBannerWidget()),
          ),
        ],
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
      ),
    );
  }

  void _showSmsDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Envoyer par SMS'),
        content: Text('Voulez-vous envoyer ce message par SMS ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              final Uri smsUri = Uri(
                scheme: 'sms',
                queryParameters: <String, String>{'body': text},
              );

              if (await canLaunchUrl(smsUri)) {
                await launchUrl(smsUri);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Ouverture de l’application SMS 📱'),
                  ),
                );
              } else {
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Impossible d’ouvrir l’application SMS ❌'),
                  ),
                );
              }
            },
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }
}
