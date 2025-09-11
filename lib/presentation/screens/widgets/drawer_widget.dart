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

  Future<void> launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'leloeduk2025@gmail.com',
      queryParameters: {
        'subject': 'Support SMS Magique',
        'body': 'Bonjour, je souhaite vous contacter…',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      // Pas de client email trouvé
      debugPrint('Impossible d’ouvrir l’email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header du Drawer
          _buildDrawerHeader(theme),

          // Items de navigation
          _buildDrawerItem(
            context,
            Icons.home,
            'Accueil',
            onHomePressed,
            theme,
          ),
          _buildDrawerItem(context, Icons.favorite, 'Favoris', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesScreen()),
            );
          }, theme),
          _buildDrawerItem(
            context,
            Icons.update,
            'Mettre à jour',
            onUpdatePressed,
            theme,
          ),
          _buildDrawerItem(
            context,
            Icons.share,
            'Partager l\'app',
            onSharePressed,
            theme,
          ),
          _buildDrawerItem(context, Icons.info, 'À propos', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutScreen()),
            );
          }, theme),

          Divider(color: theme.dividerColor),

          // Section supplémentaire
          _buildDrawerItem(context, Icons.settings, 'Paramètres', () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          }, theme),
          _buildDrawerItem(
            context,
            Icons.star,
            'Noter l\'app',
            () => _launchURL(
              'https://play.google.com/store/apps/details?id=com.leloeduk.app',
            ),
            theme,
          ),
          _buildDrawerItem(
            context,
            Icons.help,
            'Aide & Support',
            () => launchEmail,
            theme,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(ThemeData theme) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: theme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message, size: 30, color: theme.colorScheme.onPrimary),
          const SizedBox(height: 10),
          Text(
            'SMS Magiques',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Messages pour toutes les occasions',
            style: TextStyle(
              color: theme.colorScheme.onPrimary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
    ThemeData theme,
  ) {
    return ListTile(
      leading: Icon(icon, color: theme.iconTheme.color),
      title: Text(
        title,
        style: TextStyle(color: theme.textTheme.bodyLarge?.color),
      ),
      onTap: onTap,
      hoverColor: theme.hoverColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}
