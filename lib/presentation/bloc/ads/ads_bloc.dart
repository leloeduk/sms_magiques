import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sms_magique/presentation/bloc/ads/ads_event.dart';
import 'package:sms_magique/presentation/bloc/ads/ads_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  AdBloc() : super(AdInitial()) {
    on<InitializeAdMob>(_initializeAdMob);
    on<LoadBannerAd>(_loadBannerAd);
    on<LoadInterstitialAd>(_loadInterstitialAd);
  }

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;

  // Initialisation AdMob
  Future<void> _initializeAdMob(
    InitializeAdMob event,
    Emitter<AdState> emit,
  ) async {
    emit(AdLoading());
    try {
      await MobileAds.instance.initialize();
      emit(AdInitial());
    } catch (e) {
      emit(AdErrorState('AdMob init failed: $e'));
    }
  }

  // Chargement bannière
  Future<void> _loadBannerAd(LoadBannerAd event, Emitter<AdState> emit) async {
    emit(AdLoading());
    _bannerAd = BannerAd(
      size: AdSize.banner,
      adUnitId: 'ca-app-pub-3010995346645294/1924309695', // Test ID
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => emit(AdLoaded(bannerAd: _bannerAd)),
        onAdFailedToLoad: (ad, error) =>
            emit(AdErrorState('Banner failed: ${error.message}')),
      ),
    );
    await _bannerAd?.load();
  }

  // Chargement interstitielle
  Future<void> _loadInterstitialAd(
    LoadInterstitialAd event,
    Emitter<AdState> emit,
  ) async {
    emit(AdLoading());
    await InterstitialAd.load(
      adUnitId: 'ca-app-pub-3010995346645294/8298146351', // Test ID
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          emit(AdLoaded(interstitialAd: ad));
        },
        onAdFailedToLoad: (error) =>
            emit(AdErrorState('Interstitial failed: ${error.message}')),
      ),
    );
  }

  @override
  Future<void> close() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    return super.close();
  }
}
