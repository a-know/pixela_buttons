import 'package:flutter/material.dart';

class AdaptiveFormScrollView extends StatelessWidget {
  const AdaptiveFormScrollView({
    required this.child,
    required this.contentKey,
    required this.scrollViewKey,
    this.padding = const EdgeInsets.all(24),
    this.maxContentWidth = 560,
    super.key,
  });

  final Widget child;
  final Key contentKey;
  final Key scrollViewKey;
  final EdgeInsetsGeometry padding;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: scrollViewKey,
      padding: padding,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          key: contentKey,
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}
