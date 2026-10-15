import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:qbyt/core/presentation/misc/grid_background_painter.dart';
import 'package:qbyt/core/theme/constants/styles.dart' as style;
import 'package:qbyt/core/widgets/brand_badge.dart';
import 'package:qbyt/core/usescases/use_case.dart';
import 'package:qbyt/features/website/domain/usecases/get_saved_website.dart';
import 'package:qbyt/features/website/presentation/routes/website_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.getSavedWebsite});

  final GetSavedWebsite getSavedWebsite;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _continueAfterStartup();
  }

  Future<void> _continueAfterStartup() async {
    final stopwatch = Stopwatch()..start();
    final result = await widget.getSavedWebsite(NoParams());
    final remaining = const Duration(milliseconds: 900) - stopwatch.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    if (!mounted) return;
    final address = result.getOrElse(() => null);
    if (address == null) {
      context.goNamed(WebsiteRoutes.entryName);
    } else {
      context.goNamed(WebsiteRoutes.browserName, extra: address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: GridBackgroundPainter(
          backgroundColor: style.scaffoldBackgroundColor,
          lineColor: style.gridLineColor,
          gridSize: 48.0,
        ),
        child: const Center(child: BrandBadge()),
      ),
    );
  }
}
