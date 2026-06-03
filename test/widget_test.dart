import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:super_motos/main.dart';

void main() {
  testWidgets('MyApp renders the dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('MotoRuta Pro'), findsOneWidget);
    expect(find.byIcon(Icons.two_wheeler), findsOneWidget);
  });
}

