import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_helper.dart';

class BannerAdWidget extends StatefulWidget {
  final int refreshIntervalSeconds;

  const BannerAdWidget({
    super.key,
    this.refreshIntervalSeconds = 5,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> with WidgetsBindingObserver {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  bool _isLoadingAd = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadBannerAd();
    _startAutoRefreshTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startAutoRefreshTimer();
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _stopAutoRefreshTimer();
    }
  }

  void _startAutoRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      Duration(seconds: widget.refreshIntervalSeconds),
      (_) => _loadBannerAd(),
    );
  }

  void _stopAutoRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _loadBannerAd() {
    if (kIsWeb || !Platform.isAndroid || _isLoadingAd) return;
    _isLoadingAd = true;

    final BannerAd newAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            final oldAd = _bannerAd;
            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoaded = true;
              _isLoadingAd = false;
            });
            oldAd?.dispose();
          } else {
            ad.dispose();
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          AdHelper.logError('Banner Ad Failed To Load', err);
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _bannerAd = null;
              _isLoadingAd = false;
            });
          }
        },
      ),
    );

    newAd.load();
  }

  @override
  void dispose() {
    _stopAutoRefreshTimer();
    WidgetsBinding.instance.removeObserver(this);
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb || !Platform.isAndroid || !_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Container(
        height: 56,
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
        ),
        child: Center(
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      ),
    );
  }
}
