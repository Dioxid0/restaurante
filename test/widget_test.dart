import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/main.dart';

void main() {
  testWidgets('RestaurantApp muestra el texto inicial', (tester) async {
    await tester.pumpWidget(const RestaurantApp());
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
