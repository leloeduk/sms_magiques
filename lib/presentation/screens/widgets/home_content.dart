// Contenu de la page d'accueil séparé
import 'package:flutter/material.dart';
import 'package:sms_magique/presentation/screens/category_screen.dart';
import 'package:sms_magique/presentation/screens/widgets/category_card.dart';

import 'background_paint.dart';

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.categories});
  final List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const BackgroundPaint(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Choisissez une catégorie de messages',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return CategoryCard(
                      category: category,
                      icon:
                          HomeContentState()._categoryIcons[category] ??
                          Icons.category,
                      color:
                          HomeContentState()._categoryColors[category] ??
                          const Color.fromARGB(255, 60, 5, 154),
                      title: HomeContentState()._getCategoryTitle(category),
                      onTap: () {
                        // Montrer une pub interstitielle avant la navigation
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CategoryScreen(category: category),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// État pour accéder aux méthodes
class HomeContentState {
  final Map<String, IconData> _categoryIcons = const {
    "drague": Icons.favorite,
    "pardon": Icons.heart_broken,
    "anniversaire": Icons.cake,
    "condoleances": Icons.emoji_people,
    "merci": Icons.thumb_up,
    "felicitations": Icons.celebration,
    "bonjour_bonne_nuit": Icons.wb_sunny,
    "motivation": Icons.rocket_launch,
    "fetes": Icons.party_mode,
    "amitie": Icons.people,
    "autres": Icons.chat,
  };

  final Map<String, Color> _categoryColors = {
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

  String _getCategoryTitle(String category) {
    final Map<String, String> titles = {
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
    return titles[category] ?? category;
  }
}
