import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:nyiha_society/nyiha_app.dart';
import 'package:nyiha_society/providers/app_state.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const NyihaApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(NyihaApp), findsOneWidget);
  });
}
