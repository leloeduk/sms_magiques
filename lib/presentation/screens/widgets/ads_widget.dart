import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../bloc/ads/ads_bloc.dart';
import '../../bloc/ads/ads_state.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  final bool showWhenLoading;

  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.showWhenLoading = true,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    // Charger la bannière après un petit délai
    Future.delayed(const Duration(milliseconds: 500), _loadBannerAd);
  }

  void _loadBannerAd() {
    if (_bannerAd != null) {
      _bannerAd!.dispose();
    }

    _bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: _getAdUnitId(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('Banner ad loaded successfully.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('Banner ad failed to load: $error');
          ad.dispose();
          _isAdLoaded = false;
        },
        onAdOpened: (Ad ad) => print('Banner ad opened.'),
        onAdClosed: (Ad ad) => print('Banner ad closed.'),
        onAdImpression: (Ad ad) => print('Banner ad impression.'),
      ),
      request: const AdRequest(),
    )..load();
  }

  String _getAdUnitId() {
    // Utilisez le Bloc pour obtenir l'ID approprié selon l'environnement
    final bloc = context.read<AdBloc>();
    // Ici vous pouvez implémenter une logique pour choisir entre test et production
    return 'ca-app-pub-3940256099942544/6300978111'; // ID de test
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdBloc, AdState>(
      listener: (context, state) {
        // Recharger la bannière si le consentement change
        if (state is AdConsentState && state.consentGiven) {
          _loadBannerAd();
        }
      },
      builder: (context, state) {
        // Cacher les pubs si le consentement n'est pas donné
        if (state is AdConsentState && !state.consentGiven) {
          return const SizedBox.shrink();
        }

        // Cacher les pubs pendant le chargement si demandé
        if (state is AdLoading && !widget.showWhenLoading) {
          return const SizedBox.shrink();
        }

        // Afficher la bannière si elle est chargée
        if (_isAdLoaded && _bannerAd != null) {
          return Container(
            height: widget.adSize.height.toDouble(),
            width: double.infinity,
            margin: widget.margin ?? const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: AdWidget(ad: _bannerAd!),
          );
        }

        // Afficher un placeholder pendant le chargement
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.adSize.height.toDouble(),
      width: double.infinity,
      margin: widget.margin ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ads_click, size: 24, color: Colors.grey[500]),
          const SizedBox(height: 4),
          Text(
            'Publicité',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// Version alternative avec gestion d'erreur avancée
class SmartAdBannerWidget extends StatelessWidget {
  final AdSize adSize;
  final EdgeInsets? margin;

  const SmartAdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, state) {
        // États pour gérer différents scénarios
        if (state is BannerAdLoaded) {
          return _buildActiveBanner(state.bannerAd);
        } else if (state is BannerAdError) {
          return _buildErrorState(state.error);
        } else if (state is AdLoading) {
          return _buildLoadingState();
        } else if (state is AdConsentState && !state.consentGiven) {
          return _buildConsentRequired();
        } else {
          return _buildLoadingState();
        }
      },
    );
  }

  Widget _buildActiveBanner(BannerAd bannerAd) {
    return Container(
      height: adSize.height.toDouble(),
      width: double.infinity,
      margin: margin ?? const EdgeInsets.all(8.0),
      child: AdWidget(ad: bannerAd),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: adSize.height.toDouble(),
      margin: margin ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(height: 4),
            Text(
              'Erreur pub',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: adSize.height.toDouble(),
      margin: margin ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildConsentRequired() {
    return Container(
      height: adSize.height.toDouble(),
      margin: margin ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.privacy_tip, color: Colors.blue, size: 20),
            const SizedBox(height: 4),
            Text(
              'Consentement requis',
              style: TextStyle(color: Colors.blue[700], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget pour les bannières adaptatives
class AdaptiveAdBannerWidget extends StatelessWidget {
  final EdgeInsets? margin;

  const AdaptiveAdBannerWidget({super.key, this.margin});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final adSize = _getAdaptiveAdSize(width);

    return AdBannerWidget(adSize: adSize, margin: margin);
  }

  AdSize _getAdaptiveAdSize(double width) {
    if (width > 720) {
      return AdSize.mediumRectangle;
    } else if (width > 400) {
      return AdSize.largeBanner;
    } else {
      return AdSize.banner;
    }
  }
}
