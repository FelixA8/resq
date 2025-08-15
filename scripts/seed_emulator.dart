import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../lib/firebase_options.dart';

Future<void> main() async {
  // Initialize Firebase with emulator settings
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Connect to emulators
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseDatabase.instance.useDatabaseEmulator('localhost', 9000);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);

  try {
    // Create demo user
    final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: 'demo@todo.app',
      password: 'Demo1234!',
    );

    final user = userCredential.user!;
    await user.updateDisplayName('Demo User');

    print('✅ Demo user created: ${user.email}');

    // Create user profile in Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'displayName': 'Demo User',
      'email': 'demo@todo.app',
      'photoURL': null,
      'createdAt': FieldValue.serverTimestamp(),
      'ownerId': user.uid,
    });

    print('✅ User profile created in Firestore');

    // Create demo todos
    final todos = [
      {
        'title': 'Complete project documentation',
        'note': 'Write comprehensive documentation for the Flutter Todo app project',
        'completed': false,
        'dueAt': DateTime.now().add(const Duration(days: 3)),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': user.uid,
        'attachments': [],
      },
      {
        'title': 'Review code changes',
        'note': 'Go through all recent commits and ensure code quality standards are met',
        'completed': true,
        'dueAt': DateTime.now().subtract(const Duration(days: 1)),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': user.uid,
        'attachments': [],
      },
      {
        'title': 'Setup CI/CD pipeline',
        'note': 'Configure GitHub Actions for automated testing and deployment',
        'completed': false,
        'dueAt': DateTime.now().add(const Duration(days: 7)),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': user.uid,
        'attachments': [],
      },
      {
        'title': 'Write unit tests',
        'note': 'Create comprehensive test coverage for all repository and service classes',
        'completed': false,
        'dueAt': DateTime.now().add(const Duration(days: 2)),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': user.uid,
        'attachments': [],
      },
      {
        'title': 'Design system implementation',
        'note': 'Implement consistent design tokens and component library',
        'completed': false,
        'dueAt': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'ownerId': user.uid,
        'attachments': [
          {
            'name': 'design_mockup.png',
            'path': 'users/${user.uid}/todos/placeholder/design_mockup.png',
            'downloadURL': 'https://example.com/placeholder.png',
            'size': 1024000,
            'contentType': 'image/png',
          }
        ],
      },
    ];

    for (final todoData in todos) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('todos')
          .add(todoData);
    }

    print('✅ ${todos.length} demo todos created');

    // Set online status in Realtime Database
    await FirebaseDatabase.instance
        .ref('status/${user.uid}')
        .set({
      'state': 'online',
      'last_changed': ServerValue.timestamp,
    });

    print('✅ User presence status set to online');

    print('\n🎉 Emulator seeding completed successfully!');
    print('📱 You can now sign in with:');
    print('   Email: demo@todo.app');
    print('   Password: Demo1234!');

  } catch (e) {
    print('❌ Error seeding emulator: $e');
  } finally {
    exit(0);
  }
}
