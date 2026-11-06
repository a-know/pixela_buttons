import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const double _defaultSvgAspectRatio = 16 / 3;

Size? parseSvgIntrinsicSize(String svg) {
  double? parseDimension(String name) {
    final match = RegExp(
      '\\b$name\\s*=\\s*["\\\']([^"\\\']+)["\\\']',
      caseSensitive: false,
    ).firstMatch(svg);
    final value = match?.group(1)?.trim();
    if (value == null || value.endsWith('%')) return null;

    final number = RegExp(
      r'^([0-9]+(?:\.[0-9]+)?)(?:px)?$',
      caseSensitive: false,
    ).firstMatch(value);
    return double.tryParse(number?.group(1) ?? '');
  }

  final width = parseDimension('width');
  final height = parseDimension('height');
  if (width != null && height != null && width > 0 && height > 0) {
    return Size(width, height);
  }

  final viewBox = RegExp(
    r'''\bviewBox\s*=\s*["']\s*[-+\d.eE]+[\s,]+[-+\d.eE]+[\s,]+([-+\d.eE]+)[\s,]+([-+\d.eE]+)\s*["']''',
    caseSensitive: false,
  ).firstMatch(svg);
  final viewBoxWidth = double.tryParse(viewBox?.group(1) ?? '');
  final viewBoxHeight = double.tryParse(viewBox?.group(2) ?? '');
  if (viewBoxWidth != null &&
      viewBoxHeight != null &&
      viewBoxWidth > 0 &&
      viewBoxHeight > 0) {
    return Size(viewBoxWidth, viewBoxHeight);
  }

  return null;
}

class ResponsiveSvgPicture extends StatelessWidget {
  const ResponsiveSvgPicture({
    required this.svg,
    this.fallbackAspectRatio = _defaultSvgAspectRatio,
    super.key,
  });

  final String svg;
  final double fallbackAspectRatio;

  @override
  Widget build(BuildContext context) {
    final size = parseSvgIntrinsicSize(svg);
    final aspectRatio = size == null
        ? fallbackAspectRatio
        : size.width / size.height;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: SvgPicture.string(
        svg,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.contain,
        placeholderBuilder: (_) => const SizedBox.shrink(),
      ),
    );
  }
}
