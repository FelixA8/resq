import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:resqapp/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Todo App Integration Tests', () {
    testWidgets('Complete todo flow test', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Wait for the app to load
      await tester.pump(const Duration(seconds: 2));

      // Verify we're on the sign-in screen
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Sign in with demo credentials
      await tester.enterText(find.byType(TextFormField).first, 'demo@todo.app');
      await tester.enterText(find.byType(TextFormField).last, 'Demo1234!');
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      // Wait for authentication and navigation
      await tester.pump(const Duration(seconds: 3));

      // Verify we're on the todo list screen
      expect(find.text('My Todos'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Create a new todo
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify todo editor is open
      expect(find.text('New Todo'), findsOneWidget);
      expect(find.text('Title *'), findsOneWidget);

      // Fill in todo details
      await tester.enterText(find.byType(TextFormField).first, 'Test Todo');
      await tester.enterText(find.byType(TextFormField).last, 'This is a test todo');
      await tester.tap(find.text('Create Todo'));
      await tester.pumpAndSettle();

      // Verify todo was created and we're back to the list
      expect(find.text('My Todos'), findsOneWidget);
      expect(find.text('Test Todo'), findsOneWidget);

      // Toggle todo completion
      final checkbox = find.byType(Checkbox).first;
      await tester.tap(checkbox);
      await tester.pumpAndSettle();

      // Verify todo is marked as completed
      expect(tester.widget<Checkbox>(checkbox).value, isTrue);

      // Edit the todo
      await tester.tap(find.text('Test Todo'));
      await tester.pumpAndSettle();

      // Verify editor is open with existing data
      expect(find.text('Edit Todo'), findsOneWidget);
      expect(find.text('Test Todo'), findsOneWidget);

      // Update the todo
      await tester.enterText(find.byType(TextFormField).first, 'Updated Test Todo');
      await tester.tap(find.text('Update Todo'));
      await tester.pumpAndSettle();

      // Verify todo was updated
      expect(find.text('Updated Test Todo'), findsOneWidget);

      // Delete the todo by swiping
      final todoTile = find.text('Updated Test Todo');
      await tester.drag(todoTile, const Offset(-300, 0));
      await tester.pumpAndSettle();

      // Verify delete confirmation dialog
      expect(find.text('Delete Todo'), findsOneWidget);
      expect(find.text('Are you sure you want to delete "Updated Test Todo"?'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      // Verify todo was deleted
      expect(find.text('Updated Test Todo'), findsNothing);
    });
  });
}
