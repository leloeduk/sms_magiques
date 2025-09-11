import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdEvent {}

// Événements pour les bannières
class LoadBannerAd extends AdEvent {
  final AdSize adSize;

  LoadBannerAd({this.adSize = AdSize.banner});
}

class ShowBannerAd extends AdEvent {}

class HideBannerAd extends AdEvent {}

// Événements pour les interstitielles
class LoadInterstitialAd extends AdEvent {}

class ShowInterstitialAd extends AdEvent {}

// Événements pour les récompensées
class LoadRewardedAd extends AdEvent {}

class ShowRewardedAd extends AdEvent {
  final Function(RewardItem) onReward;

  ShowRewardedAd({required this.onReward});
}

// Événements pour la configuration
class InitializeAds extends AdEvent {}

class SetTestDeviceIds extends AdEvent {
  final List<String> testDeviceIds;

  SetTestDeviceIds(this.testDeviceIds);
}

// Événements pour le statut
class AdConsentRequested extends AdEvent {}

class AdConsentGranted extends AdEvent {}

class AdConsentDenied extends AdEvent {}
