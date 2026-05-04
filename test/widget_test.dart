import 'package:app_nawaa/app_state.dart';
import 'package:app_nawaa/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('shows account type choice screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MyApp(),
      ),
    );

    expect(find.text('نواة'), findsOneWidget);
    expect(find.text('تسجيل أفراد'), findsOneWidget);
    expect(find.text('تسجيل شركات'), findsOneWidget);
  });
}
