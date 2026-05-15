import 'dart:math' as math;

import 'package:customer_app/core/theem/coler.dart';
import 'package:flutter/material.dart';

class ResponsiveKeyboardPage extends StatelessWidget {
  const ResponsiveKeyboardPage({
    super.key,
    required this.child,
    this.appBar,
    this.padding = const EdgeInsets.all(24),
    this.maxWidth = 480,
    this.backgroundColor = AppColors.background,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final EdgeInsets padding;
  final double maxWidth;
  final Color backgroundColor;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: appBar,
        backgroundColor: backgroundColor,
        resizeToAvoidBottomInset: false,
        body: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth > 600
                    ? math
                          .max((constraints.maxWidth - maxWidth) / 2, 24)
                          .toDouble() // تحويل إلى double
                    : padding.horizontal / 2;

                return AnimatedPadding(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.only(bottom: keyboardHeight),
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      padding.top,
                      horizontalPadding,
                      padding.bottom,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - padding.vertical,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: crossAxisAlignment,
                        children: [child],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
