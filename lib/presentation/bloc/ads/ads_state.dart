import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdState {}

class AdInitial extends AdState {}

class AdLoading extends AdState {}

class AdInitialized extends AdState {
  final bool isInitialized;

  AdInitialized({required this.isInitialized});
}

class BannerAdLoaded extends AdState {
  final BannerAd bannerAd;
  final bool isVisible;

  BannerAdLoaded({required this.bannerAd, this.isVisible = true});
}

class BannerAdError extends AdState {
  final String error;

  BannerAdError({required this.error});
}

class InterstitialAdLoaded extends AdState {
  final InterstitialAd interstitialAd;

  InterstitialAdLoaded({required this.interstitialAd});
}

class InterstitialAdError extends AdState {
  final String error;

  InterstitialAdError({required this.error});
}

class RewardedAdLoaded extends AdState {
  final RewardedAd rewardedAd;

  RewardedAdLoaded({required this.rewardedAd});
}

class RewardedAdError extends AdState {
  final String error;

  RewardedAdError({required this.error});
}

class AdConsentState extends AdState {
  final bool consentGiven;
  final bool consentRequested;

  AdConsentState({required this.consentGiven, required this.consentRequested});
}

class AdRevenue extends AdState {
  final double revenue;
  final String currency;

  AdRevenue({required this.revenue, required this.currency});
}
