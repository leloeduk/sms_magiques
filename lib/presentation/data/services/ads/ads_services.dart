import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../bloc/ads/ads_bloc.dart';
import '../../../bloc/ads/ads_event.dart';

class AdProvider {
  static AdBloc provideAdBloc(BuildContext context) {
    return BlocProvider.of<AdBloc>(context);
  }

  static void initializeAds(BuildContext context) {
    provideAdBloc(context).add(InitializeAds());
  }

  static void showBanner(BuildContext context) {
    provideAdBloc(context).add(ShowBannerAd());
  }

  static void hideBanner(BuildContext context) {
    provideAdBloc(context).add(HideBannerAd());
  }

  static void showInterstitial(BuildContext context) {
    provideAdBloc(context).add(ShowInterstitialAd());
  }

  static void showRewarded(
    BuildContext context, {
    required Function(RewardItem) onReward,
  }) {
    provideAdBloc(context).add(ShowRewardedAd(onReward: onReward));
  }

  static void requestConsent(BuildContext context) {
    provideAdBloc(context).add(AdConsentRequested());
  }
}
