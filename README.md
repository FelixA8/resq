# ResQ Todo App

A production-ready Flutter Todo application with Firebase integration, featuring real-time updates, offline support, file attachments, and user presence tracking.

## 🚀 Features

- **Authentication**: Email/password and Google Sign-In
- **Real-time Todos**: Create, read, update, delete with Firestore
- **Offline Support**: Works offline with automatic sync when reconnected
- **File Attachments**: Upload images and files to todos
- **User Presence**: Real-time online/offline status
- **Cross-platform**: iOS, Android, Web, Desktop
- **Modern UI**: Material Design 3 with dark/light theme support

## 🛠 Tech Stack

- **Frontend**: Flutter 3.7+ with null safety
- **State Management**: Riverpod
- **Backend**: Firebase
  - Authentication (Email/Password + Google)
  - Firestore (NoSQL database)
  - Realtime Database (presence tracking)
  - Storage (file uploads)
- **Development**: Firebase Emulators for local development

## 📋 Prerequisites

- Flutter SDK 3.7.2 or higher
- Dart SDK 3.0.0 or higher
- Firebase CLI
- FlutterFire CLI
- Git

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd resq-app
flutter pub get
```

### 2. Firebase Configuration

```bash
# Install FlutterFire CLI if not already installed
dart pub global activate flutterfire_cli

# Configure Firebase for your project
flutterfire configure

# This will create/update firebase_options.dart
```

### 3. Start Firebase Emulators

```bash
# Start all emulators
firebase emulators:start

# Or start specific services
firebase emulators:start --only auth,firestore,database,storage
```

The emulators will be available at:
- **Auth**: http://localhost:9099
- **Firestore**: http://localhost:8080
- **Realtime Database**: http://localhost:9000
- **Storage**: http://localhost:9199
- **Emulator UI**: http://localhost:4000

### 4. Seed Demo Data

```bash
# Run the seed script to populate emulators with demo data
dart run scripts/seed_emulator.dart
```

This creates:
- Demo user: `demo@todo.app` / `Demo1234!`
- 5 sample todos (mix of completed/open, with due dates and attachments)

### 5. Run the App

```bash
# Run against emulators
flutter run

# For specific platform
flutter run -d chrome  # Web
flutter run -d macos   # macOS
flutter run -d windows # Windows
```

## 🏗 Project Structure

```
lib/
├── main.dart                 # App entry point, Firebase init
├── firebase_options.dart     # Firebase configuration
├── features/
│   ├── auth/                # Authentication
│   │   ├── data/
│   │   │   └── auth_repository.dart
│   │   └── ui/
│   │       └── sign_in_screen.dart
│   ├── todos/               # Todo management
│   │   ├── data/
│   │   │   ├── todo_model.dart
│   │   │   └── todo_repository.dart
│   │   ├── logic/
│   │   │   └── todo_controller.dart
│   │   └── ui/
│   │       ├── todo_list_screen.dart
│   │       ├── todo_editor_sheet.dart
│   │       └── todo_item_tile.dart
│   ├── presence/            # User presence
│   │   └── data/
│   │       └── presence_service.dart
│   └── storage/             # File attachments
│       └── data/
│           └── attachment_service.dart
└── common/
    └── theme/
        └── app_theme.dart
```

## 🔐 Security Rules

### Firestore Rules
- Users can only access their own data
- Todo titles limited to 120 characters
- Server-side timestamps for audit trail

### Storage Rules
- File size limit: 10MB
- Users can only upload to their own paths
- Secure file naming and validation

### Database Rules
- Presence data restricted to authenticated users
- State validation (online/offline only)

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

### Widget Tests
```bash
flutter test test/
```

## 📱 App Behavior

### Offline Support
- Firestore offline persistence enabled
- Todos created offline sync when reconnected
- Optimistic UI updates

### Real-time Updates
- Live todo list updates
- Presence indicators in real-time
- Automatic sync across devices

### File Attachments
- Support for images and documents
- Automatic file type detection
- Secure storage with user isolation

## 🚀 Deployment

### 1. Deploy Security Rules

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Deploy Database rules
firebase deploy --only database
```

### 2. Deploy Indexes

```bash
# Deploy Firestore indexes
firebase deploy --only firestore:indexes
```

### 3. Build and Deploy App

```bash
# Build for production
flutter build web
flutter build apk --release
flutter build ios --release

# Deploy to Firebase Hosting (web)
firebase deploy --only hosting
```

## 🔧 Configuration

### Environment Variables
- `FIREBASE_PROJECT_ID`: Your Firebase project ID
- `FIREBASE_EMULATOR_HOST`: Emulator host (default: localhost)

### Firebase Configuration
The app automatically detects emulator vs production:
- **Development**: Uses emulator endpoints
- **Production**: Uses live Firebase services

## 📊 Performance

### Optimizations
- Lazy loading of todo lists
- Efficient Firestore queries with composite indexes
- Optimized file uploads with compression
- Minimal network requests with offline caching

### Monitoring
- Firebase Performance Monitoring integration ready
- Crashlytics setup for production builds
- Analytics events for user interactions

## 🐛 Troubleshooting

### Common Issues

1. **Emulator Connection Failed**
   ```bash
   # Ensure emulators are running
   firebase emulators:start
   
   # Check ports are available
   lsof -i :8080,9099,9000,9199
   ```

2. **Authentication Errors**
   - Verify Firebase project configuration
   - Check emulator is running on correct ports
   - Ensure `firebase_options.dart` is up to date

3. **Build Errors**
   ```bash
   # Clean and rebuild
   flutter clean
   flutter pub get
   flutter run
   ```

### Debug Mode
```bash
# Enable verbose logging
flutter run --verbose

# Check Firebase emulator status
firebase emulators:start --debug
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the robust backend services
- Riverpod for excellent state management
- The Flutter community for inspiration and support

## 📞 Support

For questions or issues:
- Create an issue in the repository
- Check the troubleshooting section above
- Review Firebase documentation
- Consult Flutter documentation

---

**Happy Coding! 🎉**
