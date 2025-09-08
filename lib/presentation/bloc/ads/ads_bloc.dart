import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:dio/dio.dart';
import 'ads_event.dart';
import 'ads_state.dart';

class AdBloc extends Bloc<AdEvent, AdState> {
  final Dio dio;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;
  bool _bannerVisible = true;

  static const String _bannerAdId = 'ca-app-pub-3010995346645294/1924309695';
  static const String _interstitialAdId =
      'ca-app-pub-3010995346645294/8298146351';
  static const String _rewardedAdId = 'ca-app-pub-3010995346645294/3216924653';

  AdBloc({required this.dio}) : super(AdInitial()) {
    on<InitializeAds>(_onInitializeAds);
    on<LoadBannerAd>(_onLoadBannerAd);
    on<ShowBannerAd>(_onShowBannerAd);
    on<HideBannerAd>(_onHideBannerAd);
    on<LoadInterstitialAd>(_onLoadInterstitialAd);
    on<ShowInterstitialAd>(_onShowInterstitialAd);
    on<LoadRewardedAd>(_onLoadRewardedAd);
    on<ShowRewardedAd>(_onShowRewardedAd);
    on<SetTestDeviceIds>(_onSetTestDeviceIds);
    on<AdConsentRequested>(_onAdConsentRequested);
    on<AdConsentGranted>(_onAdConsentGranted);
    on<AdConsentDenied>(_onAdConsentDenied);
  }

  // ---- Initialisation ----
  Future<void> _onInitializeAds(
    InitializeAds event,
    Emitter<AdState> emit,
  ) async {
    try {
      emit(AdLoading());

      await MobileAds.instance.initialize();
      _isInitialized = true;

      emit(AdInitialized(isInitialized: true));

      add(LoadBannerAd());
      add(LoadInterstitialAd());
      add(LoadRewardedAd());
    } catch (e) {
      emit(AdInitialized(isInitialized: false));
      print("Erreur init Ads: $e");
    }
  }

  // ---- Bannière ----
  Future<void> _onLoadBannerAd(
    LoadBannerAd event,
    Emitter<AdState> emit,
  ) async {
    if (!_isInitialized) return;

    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: _bannerAdId,
      size: event.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          emit(
            BannerAdLoaded(bannerAd: ad as BannerAd, isVisible: _bannerVisible),
          );
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          emit(BannerAdError(error: error.message));
        },
      ),
    );

    await _bannerAd!.load();
  }

  void _onShowBannerAd(ShowBannerAd event, Emitter<AdState> emit) {
    _bannerVisible = true;
    if (_bannerAd != null) {
      emit(BannerAdLoaded(bannerAd: _bannerAd!, isVisible: true));
    }
  }

  void _onHideBannerAd(HideBannerAd event, Emitter<AdState> emit) {
    _bannerVisible = false;
    if (_bannerAd != null) {
      emit(BannerAdLoaded(bannerAd: _bannerAd!, isVisible: false));
    }
  }

  // ---- Interstitielle ----
  Future<void> _onLoadInterstitialAd(
    LoadInterstitialAd event,
    Emitter<AdState> emit,
  ) async {
    if (!_isInitialized) return;

    await InterstitialAd.load(
      adUnitId: _interstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _setupInterstitialListeners(ad);
          emit(InterstitialAdLoaded(interstitialAd: ad));
        },
        onAdFailedToLoad: (error) {
          emit(InterstitialAdError(error: error.message));
          // 🔄 Retry après 30s
          Future.delayed(const Duration(seconds: 30), () {
            add(LoadInterstitialAd());
          });
        },
      ),
    );
  }

  void _setupInterstitialListeners(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        add(LoadInterstitialAd());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        add(LoadInterstitialAd());
      },
    );
  }

  void _onShowInterstitialAd(ShowInterstitialAd event, Emitter<AdState> emit) {
    if (_interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null; // 🔄 reload auto après use
      add(LoadInterstitialAd());
    } else {
      print("⚠️ Interstitial pas prêt");
    }
  }

  // ---- Récompensée ----
  Future<void> _onLoadRewardedAd(
    LoadRewardedAd event,
    Emitter<AdState> emit,
  ) async {
    if (!_isInitialized) return;

    await RewardedAd.load(
      adUnitId: _rewardedAdId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _setupRewardedListeners(ad);
          emit(RewardedAdLoaded(rewardedAd: ad));
        },
        onAdFailedToLoad: (error) {
          emit(RewardedAdError(error: error.message));
          Future.delayed(const Duration(seconds: 30), () {
            add(LoadRewardedAd());
          });
        },
      ),
    );
  }

  void _setupRewardedListeners(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        add(LoadRewardedAd());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        add(LoadRewardedAd());
      },
    );
  }

  void _onShowRewardedAd(ShowRewardedAd event, Emitter<AdState> emit) {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          event.onReward(reward);
        },
      );
      _rewardedAd = null;
      add(LoadRewardedAd());
    } else {
      print("⚠️ Rewarded pas prêt");
    }
  }

  // ---- Divers ----
  void _onSetTestDeviceIds(SetTestDeviceIds event, Emitter<AdState> emit) {
    MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: event.testDeviceIds),
    );
  }

  void _onAdConsentRequested(AdConsentRequested event, Emitter<AdState> emit) {
    emit(AdConsentState(consentGiven: false, consentRequested: true));
  }

  void _onAdConsentGranted(AdConsentGranted event, Emitter<AdState> emit) {
    emit(AdConsentState(consentGiven: true, consentRequested: false));
    add(InitializeAds());
  }

  void _onAdConsentDenied(AdConsentDenied event, Emitter<AdState> emit) {
    emit(AdConsentState(consentGiven: false, consentRequested: false));
  }

  @override
  Future<void> close() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    return super.close();
  }
}
