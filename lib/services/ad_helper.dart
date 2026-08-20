import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../constants/app_secrets.dart';

class AdHelper {
  static Future<void> initialize() async {
    if (kIsWeb || !Platform.isAndroid) return;
    await MobileAds.instance.initialize();
  }

  /// Android Google AdMob Banner Unit ID
  static String get bannerAdUnitId {
    return AppSecrets.bannerAdUnitId;
  }

  /// Android Google AdMob Rewarded Video Unit ID
  static String get rewardedAdUnitId {
    return AppSecrets.rewardedAdUnitId;
  }

  /// Android Google AdMob App Open Unit ID
  static String get appOpenAdUnitId {
    return AppSecrets.appOpenAdUnitId;
  }

  /// Prints error details beautifully in the console with formatted boxes and ANSI colors
  static void logError(String tag, Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;

    const String red = '\x1B[31m';
    const String yellow = '\x1B[33m';
    const String cyan = '\x1B[36m';
    const String reset = '\x1B[0m';
    const String bold = '\x1B[1m';

    final StringBuffer buffer = StringBuffer();
    buffer.writeln('\n$red╔══════════════════════════════════════════════════════════════════════════════╗$reset');
    buffer.writeln('$red║ ⚠️  [AD ERROR] $bold$tag$reset');
    buffer.writeln('$red╠══════════════════════════════════════════════════════════════════════════════╣$reset');

    if (error is LoadAdError) {
      buffer.writeln('$yellow║  • Code:    $reset${error.code}');
      buffer.writeln('$yellow║  • Domain:  $reset${error.domain}');
      buffer.writeln('$yellow║  • Message: $reset${error.message}');
      if (error.responseInfo != null) {
        buffer.writeln('$cyan║  • Response:$reset ${error.responseInfo?.responseId}');
      }
    } else if (error is AdError) {
      buffer.writeln('$yellow║  • Code:    $reset${error.code}');
      buffer.writeln('$yellow║  • Domain:  $reset${error.domain}');
      buffer.writeln('$yellow║  • Message: $reset${error.message}');
    } else {
      buffer.writeln('$yellow║  • Details: $reset$error');
    }

    if (stackTrace != null) {
      buffer.writeln('$cyan║  • StackTrace: $reset$stackTrace');
    }

    buffer.writeln('$red╚══════════════════════════════════════════════════════════════════════════════╝$reset\n');

    debugPrint(buffer.toString());
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
              logError('Rewarded Ad Failed To Show', error);
              ad.dispose();
              onAdFailedToLoad?.call();
            },
          );
          ad.setImmersiveMode(true);
          ad.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
              onRewardEarned();
            },
          );
        },
        onAdFailedToLoad: (LoadAdError error) {
          logError('Rewarded Ad Failed To Load', error);
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
          AdHelper.logError('App Open Ad Failed To Load', error);
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
        AdHelper.logError('App Open Ad Failed To Show', error);
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
