import 'package:flutter_test/flutter_test.dart';
import 'package:nereye_harcadim/main.dart';

void main() {
  testWidgets('Ana ekran açılıyor', (WidgetTester tester) async {
    await tester.pumpWidget(const NereyeHarcadimApp());

    await tester.pumpAndSettle();

    expect(find.text('Harcamalarım'), findsOneWidget);
  });
}
