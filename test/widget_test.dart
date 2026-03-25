// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter_iot/main.dart';
import 'package:mobile_flutter_iot/providers/auth_provider.dart';
import 'package:mobile_flutter_iot/providers/mqtt_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Auth screens load test', (WidgetTester tester) async {
    final authProvider = AuthProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<MqttProvider>(create: (_) => MqttProvider()),
        ],
        child: const SmartWorkspaceApp(),
      ),
    );

    expect(find.text('SMART WORKSPACE'), findsOneWidget);
    expect(find.text('INITIALIZE LOGIN'), findsOneWidget);

    expect(find.text('DASHBOARD'), findsNothing);

    final registerButton = find.text("Don't have an account? Register");
    expect(registerButton, findsOneWidget);

    await tester.tap(registerButton);
    await tester.pumpAndSettle();

    expect(find.text('CREATE ACCESS KEY'), findsOneWidget);
  });
}
