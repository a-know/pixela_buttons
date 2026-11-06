import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixela_buttons/widgets/responsive_svg_picture.dart';

const _sizedSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="600" height="120">
  <rect width="600" height="120" />
</svg>
''';

void main() {
  test('parseSvgIntrinsicSize reads explicit dimensions', () {
    expect(parseSvgIntrinsicSize(_sizedSvg), const Size(600, 120));
  });

  test('parseSvgIntrinsicSize falls back to viewBox', () {
    const svg = '''
      <svg width="100%" height="100%" viewBox="0 0 720 135"></svg>
    ''';

    expect(parseSvgIntrinsicSize(svg), const Size(720, 135));
  });

  testWidgets('ResponsiveSvgPicture preserves its ratio as width changes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 800);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    Future<void> pumpAtWidth(double width) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: const ResponsiveSvgPicture(svg: _sizedSvg),
            ),
          ),
        ),
      );
      await tester.pump();
    }

    await pumpAtWidth(300);
    expect(
      tester.getSize(find.byType(ResponsiveSvgPicture)),
      const Size(300, 60),
    );

    await pumpAtWidth(900);
    expect(
      tester.getSize(find.byType(ResponsiveSvgPicture)),
      const Size(900, 180),
    );
    expect(tester.takeException(), isNull);
  });
}
