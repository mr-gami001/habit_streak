import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../l10n/app_strings.dart';
import '../../services/ad_helper.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class BannerAdWidget extends StatefulWidget {
  final int refreshIntervalSeconds;

  const BannerAdWidget({
    super.key,
    this.refreshIntervalSeconds = 3,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> with WidgetsBindingObserver {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _refreshTimer;
  int _mockAdIndex = 0;

  static const List<Map<String, dynamic>> _mockAds = [
    {
      'title': '⚡ Supercharge Your Daily Habits!',
      'cta': 'Learn More',
      'icon': Icons.bolt,
      'color': Colors.deepOrange,
    },
    {
      'title': '🌊 Stay Hydrated Today - Water Tracker',
      'cta': 'Try Now',
      'icon': Icons.water_drop,
      'color': Colors.blueAccent,
    },
    {
      'title': '🎯 Reach 100-Day Streak with Pro Features',
      'cta': 'Upgrade',
      'icon': Icons.emoji_events,
      'color': Colors.amber,
    },
    {
      'title': '🧘 5-Min Daily Mindfulness & Focus',
      'cta': 'Start Free',
      'icon': Icons.self_improvement,
      'color': Colors.teal,
    },
  ];

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
      (_) => _refreshAd(),
    );
  }

  void _stopAutoRefreshTimer() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  void _refreshAd() {
    if (!mounted) return;

    if (!kIsWeb && Platform.isAndroid) {
      _loadBannerAd();
    } else {
      setState(() {
        _mockAdIndex = (_mockAdIndex + 1) % _mockAds.length;
      });
    }
  }

  void _loadBannerAd() {
    if (kIsWeb || !Platform.isAndroid) return;

    _bannerAd?.dispose();
    _bannerAd = null;

    final newAd = BannerAd(
      adUnitId: AdHelper.bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) {
            setState(() {
              _bannerAd = ad as BannerAd;
              _isLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
          if (mounted) {
            setState(() {
              _isLoaded = false;
              _bannerAd = null;
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
    final theme = Theme.of(context);
    final isAndroid = !kIsWeb && Platform.isAndroid;

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
        child: isAndroid && _isLoaded && _bannerAd != null
            ? Center(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              )
            : _buildFallbackBanner(theme),
      ),
    );
  }

  Widget _buildFallbackBanner(ThemeData theme) {
    final currentAd = _mockAds[_mockAdIndex];
    final color = currentAd['color'] as Color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          // Ad Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.adBadgeBg,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              AppStrings.adBadge,
              style: AppTextStyles.adBadgeText,
            ),
          ),
          const SizedBox(width: 10),

          // Icon
          Icon(
            currentAd['icon'] as IconData,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),

          // Ad Headline
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                currentAd['title'] as String,
                key: ValueKey<int>(_mockAdIndex),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Call to Action
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppStrings.openingSponsorLinkPrefix}${currentAd['title']}'),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Text(
                currentAd['cta'] as String,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
