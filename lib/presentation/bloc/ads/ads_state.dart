// États
import 'package:google_mobile_ads/google_mobile_ads.dart';

abstract class AdState {}

class AdInitial extends AdState {}

class AdLoading extends AdState {}

class AdLoaded extends AdState {
  final BannerAd? bannerAd;
  final InterstitialAd? interstitialAd;
  AdLoaded({this.bannerAd, this.interstitialAd});
}

class AdErrorState extends AdState {
  final String message;
  AdErrorState(this.message);
}
