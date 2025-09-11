import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../bloc/category/category_state.dart';
import 'widgets/interstitial_ad.dart';
import 'widgets/message_card.dart';

class CategoryScreen extends StatefulWidget {
  final String category;
  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    InterstitialAdManager.loadInterstitial();
    _loadCategoryMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCategoryMessages() {
    context.read<CategoryBloc>().add(LoadCategoryMessages(widget.category));
  }

  String _getCategoryTitle(String category) {
    final Map<String, String> titles = {
      "drague": "Drague 💘",
      "pardon": "Pardon 🙏",
      "anniversaire": "Anniversaire 🎂",
      "condoleances": "Condoléances 💐",
      "merci": "Remerciement 🙌",
      "felicitations": "Félicitations 🎉",
      "bonjour_bonne_nuit": "Salutations ☀️🌙",
      "motivation": "Motivation 💪",
      "fetes": "Fêtes 🎄",
      "amitie": "Amitié 👫",
      "autres": "Autres 📝",
    };
    return titles[category] ?? category;
  }

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

  Future<void> _handleRefresh() async {
    _loadCategoryMessages();
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(widget.category);

    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // AppBar personnalisé
            SliverAppBar(
              expandedHeight: 100.0,
              floating: false,
              pinned: true,
              backgroundColor: categoryColor,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  _getCategoryTitle(widget.category),
                  style: const TextStyle(
                    fontSize: 16,
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
                        categoryColor.withOpacity(0.8),
                        // ignore: deprecated_member_use
                        categoryColor.withOpacity(0.6),
                      ],
                    ),
                  ),
                  child: const Icon(
                    Icons.message,
                    size: 20,
                    color: Colors.white30,
                  ),
                ),
              ),
            ),
          ];
        },
        body: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return _buildLoadingState();
            } else if (state is CategoryLoaded) {
              final messages = state.messages;

              if (messages.isEmpty) {
                return _buildEmptyState();
              }
              return LiquidPullToRefresh(
                onRefresh: _handleRefresh,
                color: categoryColor,
                backgroundColor: Colors.grey,
                height: 150,
                animSpeedFactor: 2,
                showChildOpacityTransition: false,
                child: _buildMessageList(messages.toList(), categoryColor),
              );
            } else if (state is CategoryError) {
              return _buildErrorState(state.message);
            }
            return const SizedBox();
          },
        ),
      ),

      // Bouton flottant pour remonter
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
        backgroundColor: categoryColor,
        child: const Icon(Icons.arrow_upward, color: Colors.white),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              _getCategoryColor(widget.category),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Chargement des messages...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 20),
          Text(
            'Aucun message disponible',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _loadCategoryMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getCategoryColor(widget.category),
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
          const SizedBox(height: 20),
          Text(
            'Erreur: $error',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadCategoryMessages,
            style: ElevatedButton.styleFrom(
              backgroundColor: _getCategoryColor(widget.category),
            ),
            child: const Text(
              'Réessayer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<dynamic> messages, Color categoryColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageCard(message: message, showCategory: false);
      },
    );
  }
}
