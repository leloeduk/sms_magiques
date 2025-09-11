import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sms_magique/data/models/category_list.dart';
import '../bloc/ads/ads_bloc.dart';
import '../bloc/ads/ads_event.dart';
import '../bloc/ads/ads_state.dart';
import 'category_screen.dart';
import 'favorite_screen.dart';
import 'widgets/about_screen.dart';
import 'widgets/ads_widget.dart';
import 'widgets/background_paint.dart';
import 'widgets/drawer_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  Future<void> checkForUpdate(BuildContext context) async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        // Affiche le dialog pour mettre à jour
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Nouvelle mise à jour disponible'),
            content: const Text(
              'Une nouvelle version est disponible sur le Play Store. Voulez-vous mettre à jour ?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Plus tard'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  // Lance la mise à jour flexible
                  await InAppUpdate.performImmediateUpdate();
                },
                child: const Text('Mettre à jour'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text('Application à jour !')));
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la vérification : $e')),
      );
    }
  }

  Future<void> shareApk(BuildContext context) async {
    try {
      // Récupérer le dossier temporaire
      final tempDir = await getTemporaryDirectory();
      final apkFile = File('${tempDir.path}/sms_magique.apk');

      // Vérifie si le fichier existe
      if (!await apkFile.exists()) {
        ScaffoldMessenger.of(
          // ignore: use_build_context_synchronously
          context,
        ).showSnackBar(const SnackBar(content: Text('Partage échoué')));
        return;
      }

      // Partager le fichier
      await Share.shareXFiles(
        [XFile(apkFile.path)],
        text: 'Découvrez l\'application SMS Magique !',
        subject: 'SMS Magique',
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erreur partage APK : $e')));
    }
  }

  // Pages du BottomNavigationBar
  final List<Widget> _pages = [
    const _HomeContent(), // Page d'accueil principale
    const FavoritesScreen(),
    const AboutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Initialiser les ADS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdBloc>().add(InitializeAds());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdBloc, AdState>(
      listener: (context, state) {
        if (state is AdConsentState && state.consentRequested) {
          _showConsentDialog(context);
        }
        if (state is InterstitialAdLoaded) {
          print('Interstitielle prête à être affichée');
        }
        if (state is InterstitialAdError) {
          print('Erreur interstitielle: ${state.error}');
        }
      },
      child: Scaffold(
        drawer: DrawerWidget(
          onHomePressed: () {
            Navigator.pop(context);
            setState(() {
              _currentIndex = 0;
              _pageController.jumpToPage(0);
            });
          },
          onUpdatePressed: () {
            Navigator.pop(context);
            checkForUpdate(context);
          },
          onSharePressed: () {
            Navigator.pop(context);
            shareApk(context);
          },
        ),
        appBar: _currentIndex == 0
            ? AppBar(
                centerTitle: true,
                title: const Text(
                  'Catégories',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: Colors.deepPurple.shade900,
              )
            : null,
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: _pages,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
            ),
            // Bannière pub en bas
            const AdBannerWidget(),
          ],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              _pageController.jumpToPage(index);
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurple.shade900,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          elevation: 10,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoris',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.info), label: 'À Propos'),
          ],
        ),
      ),
    );
  }

  void _showConsentDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Personnalisation des publicités'),
        content: const Text(
          'Nous utilisons des publicités pour offrir cette application gratuitement. '
          'Souhaitez-vous voir des publicités personnalisées pour une meilleure expérience ?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.read<AdBloc>().add(AdConsentDenied());
              Navigator.pop(context);
            },
            child: const Text('Refuser'),
          ),
          TextButton(
            onPressed: () {
              context.read<AdBloc>().add(AdConsentGranted());
              Navigator.pop(context);
            },
            child: const Text('Accepter'),
          ),
        ],
      ),
    );
  }
}

// Contenu de la page d'accueil séparé
class _HomeContent extends StatelessWidget {
  const _HomeContent();

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
                    return _CategoryCard(
                      category: category,
                      icon:
                          _HomeContentState()._categoryIcons[category] ??
                          Icons.category,
                      color:
                          _HomeContentState()._categoryColors[category] ??
                          const Color.fromARGB(255, 60, 5, 154),
                      title: _HomeContentState()._getCategoryTitle(category),
                      onTap: () {
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
class _HomeContentState {
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

// Carte de catégorie
class _CategoryCard extends StatelessWidget {
  final String category;
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.8), color.withOpacity(0.6)],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
