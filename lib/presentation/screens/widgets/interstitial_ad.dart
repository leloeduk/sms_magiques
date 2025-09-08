import 'package:google_mobile_ads/google_mobile_ads.dart';

class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;

  static void loadInterstitial() {
    InterstitialAd.load(
      adUnitId:
          "ca-app-pub-3010995346645294/8298146351", // 🔥 Remplace par ton ID AdMob
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialAd?.setImmersiveMode(true);
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          print("Erreur chargement Interstitial: $error");
        },
      ),
    );
  }

  static void showInterstitial() {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      loadInterstitial(); // recharger pour la prochaine fois
    } else {
      print("Interstitial non prêt");
    }
  }
}
