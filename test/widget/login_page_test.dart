import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:power_tool_tracking/core/theme/app_theme.dart';
import 'package:power_tool_tracking/domain/entities/user_entity.dart';
import 'package:power_tool_tracking/presentation/blocs/auth/auth_bloc.dart';
import 'package:power_tool_tracking/presentation/pages/auth/login_page.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(const AuthInitial());
  });

  Widget buildTestWidget() => MaterialApp(
        theme: AppTheme.light,
        home: BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginPage(),
        ),
      );

  group('LoginPage', () {
    testWidgets('renders email and password fields', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('renders Sign In button', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('shows validation errors on empty submit', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid email', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'not-an-email',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('dispatches AuthLoginRequested on valid input', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthInitial());

      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@company.com',
      );
      await tester.enterText(
        find.byType(TextFormField).last,
        'Password123',
      );
      await tester.tap(find.text('Sign In'));
      await tester.pump();

      verify(() => mockAuthBloc.add(const AuthLoginRequested(
            email: 'test@company.com',
            password: 'Password123',
          ))).called(1);
    });

    testWidgets('shows loading indicator when AuthLoading', (tester) async {
      when(() => mockAuthBloc.state).thenReturn(const AuthLoading());

      await tester.pumpWidget(buildTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
