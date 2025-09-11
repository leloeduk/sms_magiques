import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../bloc/ads/ads_bloc.dart';
import '../../bloc/ads/ads_event.dart';

class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;

  static void showInterstitial(BuildContext context, AdBloc adBloc) {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      adBloc.add(LoadInterstitialAd()); // recharger pour la prochaine fois
    } else {
      print("Interstitial non prêt");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pub interstitielle non prête")),
      );
    }
  }

  static void setAd(InterstitialAd ad) {
    _interstitialAd = ad;
  }
}
