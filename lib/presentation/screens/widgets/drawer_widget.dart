import 'package:flutter/material.dart';
import 'package:sms_magique/presentation/screens/settings_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import '../favorite_screen.dart';
import 'about_screen.dart';

class DrawerWidget extends StatelessWidget {
  final VoidCallback onHomePressed;
  final VoidCallback onUpdatePressed;
  final VoidCallback onSharePressed;

  const DrawerWidget({
    super.key,
    required this.onHomePressed,
    required this.onUpdatePressed,
    required this.onSharePressed,
  });

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.deepPurple.shade900, Colors.deepPurple.shade400],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Header du Drawer
            _buildDrawerHeader(),

            // Items de navigation
            _buildDrawerItem(context, Icons.home, 'Accueil', onHomePressed),
            _buildDrawerItem(context, Icons.favorite, 'Favoris', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            }),
            _buildDrawerItem(
              context,
              Icons.update,
              'Mettre à jour',
              onUpdatePressed,
            ),
            _buildDrawerItem(
              context,
              Icons.share,
              'Partager l\'app',
              onSharePressed,
            ),
            _buildDrawerItem(context, Icons.info, 'À propos', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            }),

            const Divider(color: Colors.white54),

            // Section supplémentaire
            _buildDrawerItem(context, Icons.settings, 'Paramètres', () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            }),
            _buildDrawerItem(
              context,
              Icons.star,
              'Noter l\'app',
              () => _launchURL(
                'https://play.google.com/store/apps/details?id=com.votre.app',
              ),
            ),
            _buildDrawerItem(
              context,
              Icons.help,
              'Aide & Support',
              () => _launchURL('mailto:leloeduk2025@gmail.com'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade900,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 30, color: Colors.white),
          SizedBox(height: 10),
          Text(
            'SMS Magiques',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Messages pour toutes les occasions',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
