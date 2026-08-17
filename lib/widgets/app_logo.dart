import 'package:flutter/material.dart';

const String kAppLogoAsset = 'assets/images/app_logo.png';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.borderRadius,
    this.shadows = const [],
  });

  final double size;
  final double? borderRadius;
  final List<BoxShadow> shadows;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? size * 0.24;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadows,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        kAppLogoAsset,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
