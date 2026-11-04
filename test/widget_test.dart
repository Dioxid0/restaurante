import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_app/features/hello/hello_providers.dart';
import 'package:restaurant_app/main.dart';

void main() {
  testWidgets('HelloScreen muestra el mensaje del provider', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [helloMessageProvider.overrideWith((ref) async => 'Hola test')],
        child: const RestaurantApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Hola test'), findsOneWidget);
  });
}
