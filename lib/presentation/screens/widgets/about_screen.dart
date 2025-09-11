import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('À Propos')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.message, size: 60, color: Colors.deepPurple),
              const SizedBox(height: 16),

              const Text(
                'SMS Magique',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 24),

              const Text(
                'Découvrez des milliers de messages classés par catégories pour toutes les occasions.\n'
                'Partagez, copiez et enregistrez vos messages favoris.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.4),
              ),

              const SizedBox(height: 32),

              const Text(
                'Développé par LeloEduk',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.code, size: 40),
                    onPressed: () => _launchURL('https://github.com/leloeduk'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.email, size: 50),
                    onPressed: () =>
                        _launchURL('mailto:leloeduk2025@gmail.com'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.public, size: 50),
                    onPressed: () =>
                        _launchURL('https://www.youtube.com/@LeloEduk'),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              const Text(
                '© 2025 SMS Magiques. Tous droits réservés.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
