// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter_iot/cubits/auth_cubit.dart';
import 'package:mobile_flutter_iot/cubits/mqtt_cubit.dart';
import 'package:mobile_flutter_iot/main.dart';
import 'package:mobile_flutter_iot/repository/local_user_repository.dart';
import 'package:mobile_flutter_iot/services/api_service.dart';

void main() {
  testWidgets('Auth screens load test', (WidgetTester tester) async {
    final apiService = ApiService();
    final localUserRepository = LocalUserRepository();

    await tester.pumpWidget(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider.value(value: apiService),
          RepositoryProvider.value(value: localUserRepository),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => AuthCubit(
                apiService: context.read<ApiService>(),
                userRepository: context.read<LocalUserRepository>(),
              ),
            ),
            BlocProvider(
              create: (context) => MqttCubit(
                apiService: context.read<ApiService>(),
              ),
            ),
          ],
          child: const SmartWorkspaceApp(initialRoute: '/login'),
        ),
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
