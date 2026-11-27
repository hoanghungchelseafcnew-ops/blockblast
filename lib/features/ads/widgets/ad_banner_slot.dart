import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/log/gj_log.dart';
import '../services/ad_mediator.dart';
import '../services/ad_network_adapter.dart';

/// Vùng banner dưới cùng màn chơi (u3-banner, frontend-components.md).
///
/// - Cao 0 khi chưa có banner: không chừa chỗ lúc đang tải hay khi thất bại
///   (BR7.4, BR7.5).
/// - Thử tải đúng một lần mỗi lần vào màn chơi: sau khung hình đầu, hoặc khi
///   [AdsService.bannerChanges] báo điều kiện vừa thỏa (BR7.1, BR7.2).
/// - Giữ banner suốt lần vào màn chơi, kể cả khi đổi ván; giải phóng khi
///   đóng, kể cả banner tải xong muộn (BR7.7, NFR2.21).
class AdBannerSlot extends StatefulWidget {
  const AdBannerSlot({super.key, required this.ads});

  final AdsService ads;

  @override
  State<AdBannerSlot> createState() => _AdBannerSlotState();
}

class _AdBannerSlotState extends State<AdBannerSlot> {
  bool _tried = false;
  LoadedBanner? _banner;

  @override
  void initState() {
    super.initState();
    widget.ads.bannerChanges.addListener(_maybeLoad);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoad());
  }

  void _maybeLoad() {
    if (!mounted || _tried || !widget.ads.bannerEligible) return;
    _tried = true;
    final width = MediaQuery.sizeOf(context).width;
    unawaited(_load(width));
  }

  Future<void> _load(double width) async {
    BannerResult result;
    try {
      result = await widget.ads.banner(width);
    } catch (e) {
      GjLog.warn('Ads', 'banner slot failed', e);
      return;
    }
    final banner = result.banner;
    if (banner == null) return;
    if (!mounted) {
      banner.dispose();
      return;
    }
    setState(() => _banner = banner);
  }

  @override
  void dispose() {
    widget.ads.bannerChanges.removeListener(_maybeLoad);
    _banner?.dispose();
    _banner = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banner = _banner;
    if (banner == null) return const SizedBox.shrink();
    return SizedBox(
      key: const Key('ad-banner-slot'),
      width: double.infinity,
      height: banner.height,
      child: Center(child: banner.build()),
    );
  }
}
