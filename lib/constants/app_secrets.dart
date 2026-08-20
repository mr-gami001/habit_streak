import 'package:flutter/foundation.dart';

class AppSecrets {
  AppSecrets._();

  /// Google AdMob Application ID
  static const String admobAppId = 'ca-app-pub-3209745027183448~2323038553';

  /// Google AdMob Banner Ad Unit ID
  static const String bannerAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3209745027183448/6023611114';

  /// Google AdMob Rewarded Video Ad Unit ID
  static const String rewardedAdUnitId = kDebugMode
      ? "ca-app-pub-3940256099942544/5224354917"
      : 'ca-app-pub-3209745027183448/6100361685';

  /// Google AdMob App Open Ad Unit ID
  static const String appOpenAdUnitId = kDebugMode
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-3940256099942544/9257395921';

  /// Test Device ID for debug mode
  static const String testDeviceId = 'ac387401-2df6-41d9-9611-8b1cdb6f6eb8';
}
