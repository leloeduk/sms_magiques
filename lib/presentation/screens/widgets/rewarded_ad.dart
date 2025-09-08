import 'package:google_mobile_ads/google_mobile_ads.dart';

class RewardedAdManager {
  static RewardedAd? _rewardedAd;

  static void loadRewarded() {
    RewardedAd.load(
      adUnitId:
          "ca-app-pub-3010995346645294/3216924653", // 🔥 Remplace par ton ID AdMob
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          print("Erreur chargement Rewarded: $error");
        },
      ),
    );
  }

  static void showRewarded() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          print("🎁 Récompense obtenue: ${reward.amount} ${reward.type}");
        },
      );
      _rewardedAd = null;
      loadRewarded(); // recharger pour la prochaine fois
    } else {
      print("Rewarded non prêt");
    }
  }
}
