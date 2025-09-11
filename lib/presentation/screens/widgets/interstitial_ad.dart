import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;

  /// Charge un nouvel interstitial
  static void loadInterstitial() {
    InterstitialAd.load(
      adUnitId: "ca-app-pub-3010995346645294/8298146351", // 🔥 Ton ID AdMob
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd?.setImmersiveMode(true);
          print("Interstitial chargé ✅");
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          print("Erreur chargement Interstitial: $error");
        },
      ),
    );
  }

  /// Affiche l'interstitial et exécute [onAdClosed] après fermeture
  static void showInterstitial({VoidCallback? onAdClosed}) {
    if (_interstitialAd == null) {
      print("Interstitial non prêt, navigation directe");
      if (onAdClosed != null) onAdClosed();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        print("Interstitial fermé");
        if (onAdClosed != null) onAdClosed();
        loadInterstitial(); // Recharger pour la prochaine fois
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        print("Erreur affichage Interstitial: $error");
        if (onAdClosed != null) onAdClosed();
        loadInterstitial();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  /// Vérifie si l'interstitial est prêt
  static bool get isReady => _interstitialAd != null;
}
