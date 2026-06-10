import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:power_tool_tracking/app.dart';
import 'package:power_tool_tracking/core/dependency_injection/service_locator.dart';
import 'package:power_tool_tracking/core/services/firebase_service.dart';
import 'package:power_tool_tracking/flavors/app_flavor.dart';
import 'package:power_tool_tracking/flavors/environment_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await EnvironmentConfig.initialize(AppFlavor.dev);
    await FirebaseService.initialize();
    await configureDependencies();
  });

  group('End-to-End App Tests', () {
    testWidgets('app launches and shows splash screen', (tester) async {
      await tester.pumpWidget(const PowerToolTrackingApp());
      await tester.pump();

      expect(find.text('Power Tool Tracking'), findsOneWidget);
    });

    testWidgets('redirects to login when unauthenticated', (tester) async {
      await tester.pumpWidget(const PowerToolTrackingApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty login attempt', (tester) async {
      await tester.pumpWidget(const PowerToolTrackingApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      final signInButton = find.text('Sign In');
      expect(signInButton, findsOneWidget);

      await tester.tap(signInButton);
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
    });
  });
}
