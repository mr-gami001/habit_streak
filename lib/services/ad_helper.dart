import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  static Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await MobileAds.instance.initialize();
    AppOpenAdManager.instance.loadAd();
  }

  /// Android Google AdMob Test Banner Unit ID
  static String get bannerAdUnitId {
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  /// Android Google AdMob Test Rewarded Video Unit ID
  static String get rewardedAdUnitId {
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  /// Android Google AdMob Test App Open Unit ID
  static String get appOpenAdUnitId {
    return 'ca-app-pub-3940256099942544/9257395921';
  }

  /// Helper function to load and present a Rewarded Video Ad safely
  static void showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdFailedToLoad,
    VoidCallback? onAdDismissed,
  }) {
    if (kIsWeb || !Platform.isAndroid) {
      onRewardEarned();
      return;
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (RewardedAd ad) {
              ad.dispose();
              onAdDismissed?.call();
            },
            onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
              ad.dispose();
              onAdFailedToLoad?.call();
            },
          );

          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
              onRewardEarned();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          onAdFailedToLoad?.call();
        },
      ),
    );
  }
}

/// Manager class to handle loading and showing App Open Ads for Android platform.
class AppOpenAdManager {
  static final AppOpenAdManager instance = AppOpenAdManager._internal();
  AppOpenAdManager._internal();

  AppOpenAd? _appOpenAd;
  bool _isShowingAd = false;
  DateTime? _loadTime;

  bool get isAdAvailable {
    return _appOpenAd != null &&
        _loadTime != null &&
        DateTime.now().difference(_loadTime!).inHours < 4;
  }

  void loadAd() {
    if (kIsWeb || !Platform.isAndroid) return;
    if (isAdAvailable) return;

    AppOpenAd.load(
      adUnitId: AdHelper.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _loadTime = DateTime.now();
        },
        onAdFailedToLoad: (error) {
          _appOpenAd = null;
        },
      ),
    );
  }

  void showAdIfAvailable({VoidCallback? onAdComplete}) {
    if (kIsWeb || !Platform.isAndroid) {
      onAdComplete?.call();
      return;
    }

    if (_isShowingAd) {
      onAdComplete?.call();
      return;
    }

    if (!isAdAvailable) {
      loadAd();
      onAdComplete?.call();
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdComplete?.call();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        onAdComplete?.call();
        loadAd();
      },
    );

    _appOpenAd!.show();
  }
}
