import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../bloc/ads/ads_bloc.dart';
import '../../bloc/ads/ads_state.dart';
import '../../bloc/ads/ads_event.dart';

class AdBannerWidget extends StatefulWidget {
  final AdSize adSize;
  final EdgeInsets? margin;
  final bool showWhenLoading;

  const AdBannerWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.margin,
    this.showWhenLoading = true,
  });

  @override
  State<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends State<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    final adBloc = context.read<AdBloc>();
    adBloc.add(LoadBannerAd()); // Demande de chargement au démarrage
    adBloc.stream.listen((state) {
      if (state is AdLoaded && state.bannerAd != null) {
        setState(() {
          _bannerAd = state.bannerAd;
          _isAdLoaded = true;
        });
      } else if (state is AdErrorState) {
        setState(() => _isAdLoaded = false);
      }
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdBloc, AdState>(
      builder: (context, state) {
        if (_isAdLoaded && _bannerAd != null) {
          return Container(
            height: widget.adSize.height.toDouble(),
            width: double.infinity,
            margin: widget.margin ?? const EdgeInsets.all(8.0),
            alignment: Alignment.center,
            child: AdWidget(ad: _bannerAd!),
          );
        }

        if (state is AdLoading && !widget.showWhenLoading) {
          return const SizedBox.shrink();
        }

        if (state is AdErrorState) {
          return _buildErrorState(state.message);
        }

        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: widget.adSize.height.toDouble(),
      width: double.infinity,
      margin: widget.margin ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.ads_click, size: 24, color: Colors.grey[500]),
          const SizedBox(height: 4),
          Text(
            'Publicité',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      height: widget.adSize.height.toDouble(),
      margin: widget.margin ?? const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 20),
            const SizedBox(height: 4),
            Text(
              'Erreur pub',
              style: TextStyle(color: Colors.red[700], fontSize: 12),
            ),
            Text(
              message,
              style: TextStyle(color: Colors.red[700], fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
