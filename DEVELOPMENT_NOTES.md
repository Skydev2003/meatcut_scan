# Development Notes

บันทึกสำหรับนักพัฒนา

## 🔨 Development Workflow

### การเริ่มต้นพัฒนา

```bash
# 1. Pull latest code
git pull origin main

# 2. Install dependencies
flutter pub get

# 3. Generate code (ถ้ามีการเปลี่ยนแปลง models)
flutter pub run build_runner build --delete-conflicting-outputs

# 4. Run app
flutter run
```

### การเพิ่ม Model ใหม่

1. สร้างไฟล์ใน `lib/src/models/`
2. เพิ่ม Freezed annotations
3. Run build_runner
4. สร้าง provider ใน `lib/src/providers/`

ตัวอย่าง:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_model.freezed.dart';
part 'my_model.g.dart';

@freezed
class MyModel with _$MyModel {
  const factory MyModel({
    required String id,
    required String name,
  }) = _MyModel;

  factory MyModel.fromJson(Map<String, dynamic> json) =>
      _$MyModelFromJson(json);
}
```

### การเพิ่ม Screen ใหม่

1. สร้างไฟล์ใน `lib/src/screens/`
2. เพิ่ม route ใน `lib/src/routes/app_router.dart`
3. เพิ่ม navigation logic

### การเพิ่ม Service ใหม่

1. สร้างไฟล์ใน `lib/src/services/`
2. สร้าง provider ใน `lib/src/providers/`
3. ใช้งานผ่าน `ref.read()` หรือ `ref.watch()`

## 🧪 Testing

### Unit Tests

```bash
flutter test
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter test integration_test/
```

## 🐛 Debugging

### Debug Mode

```bash
flutter run --debug
```

### Profile Mode

```bash
flutter run --profile
```

### Release Mode

```bash
flutter run --release
```

### Logging

ใช้ `print()` หรือ `debugPrint()` สำหรับ logging:

```dart
debugPrint('Debug message: $value');
```

### Riverpod DevTools

เปิด DevTools เพื่อดู provider states:

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

## 📦 Build & Release

### Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

## 🔧 Common Issues

### Issue: Build runner fails

**Solution:**
```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Issue: Supabase connection error

**Solution:**
1. ตรวจสอบ URL และ Anon Key
2. ตรวจสอบ internet connection
3. ตรวจสอบ Supabase project status

### Issue: Camera not working

**Solution:**
1. ตรวจสอบ permissions ใน AndroidManifest.xml / Info.plist
2. ทดสอบบนอุปกรณ์จริง (ไม่ใช่ emulator)
3. ตรวจสอบ camera package version

### Issue: TFLite model not loading

**Solution:**
1. ตรวจสอบว่าไฟล์อยู่ใน `assets/models/`
2. ตรวจสอบ pubspec.yaml ว่ามี assets path
3. Run `flutter clean` และ `flutter pub get`

## 🎯 Code Style

### Naming Conventions

- Classes: PascalCase (`MyClass`)
- Variables: camelCase (`myVariable`)
- Constants: camelCase (`myConstant`)
- Files: snake_case (`my_file.dart`)
- Folders: snake_case (`my_folder/`)

### Import Order

1. Dart SDK
2. Flutter SDK
3. External packages
4. Internal packages

```dart
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:riverpod/riverpod.dart';

import '../models/my_model.dart';
```

### Code Formatting

```bash
# Format all files
flutter format .

# Format specific file
flutter format lib/main.dart
```

### Linting

```bash
flutter analyze
```

## 🔐 Environment Variables

### Development

สร้างไฟล์ `.env.development`:

```
SUPABASE_URL=your_dev_url
SUPABASE_ANON_KEY=your_dev_key
```

### Production

สร้างไฟล์ `.env.production`:

```
SUPABASE_URL=your_prod_url
SUPABASE_ANON_KEY=your_prod_key
```

## 📝 Git Workflow

### Branch Naming

- Feature: `feature/feature-name`
- Bug fix: `fix/bug-name`
- Hotfix: `hotfix/issue-name`

### Commit Messages

```
feat: Add new feature
fix: Fix bug
docs: Update documentation
style: Format code
refactor: Refactor code
test: Add tests
chore: Update dependencies
```

### Pull Request

1. สร้าง branch ใหม่
2. Commit changes
3. Push to remote
4. สร้าง PR
5. รอ review
6. Merge

## 🚀 Deployment

### Android (Google Play)

1. Update version ใน `pubspec.yaml`
2. Build app bundle: `flutter build appbundle --release`
3. Upload to Play Console
4. Fill in store listing
5. Submit for review

### iOS (App Store)

1. Update version ใน `pubspec.yaml`
2. Build iOS: `flutter build ios --release`
3. Open Xcode
4. Archive app
5. Upload to App Store Connect
6. Submit for review

## 📊 Performance Monitoring

### Flutter DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Performance Profiling

```bash
flutter run --profile
```

### Memory Profiling

ใช้ DevTools Memory tab

### Network Profiling

ใช้ DevTools Network tab

## 🔄 CI/CD

### GitHub Actions

สร้างไฟล์ `.github/workflows/main.yml`:

```yaml
name: CI

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test
      - run: flutter build apk
```

## 📚 Resources

### Documentation

- [Flutter Docs](https://flutter.dev/docs)
- [Riverpod Docs](https://riverpod.dev)
- [Supabase Docs](https://supabase.com/docs)
- [TFLite Docs](https://www.tensorflow.org/lite)

### Community

- [Flutter Discord](https://discord.gg/flutter)
- [Riverpod Discord](https://discord.gg/riverpod)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

## 💡 Tips & Tricks

### Hot Reload

กด `r` ใน terminal เพื่อ hot reload

### Hot Restart

กด `R` ใน terminal เพื่อ hot restart

### Clear Cache

```bash
flutter clean
flutter pub get
```

### Update Dependencies

```bash
flutter pub upgrade
```

### Check Outdated Packages

```bash
flutter pub outdated
```

## 🎓 Learning Resources

### Beginner

- [Flutter Codelabs](https://flutter.dev/docs/codelabs)
- [Flutter YouTube Channel](https://www.youtube.com/c/flutterdev)

### Intermediate

- [Flutter Architecture Samples](https://github.com/brianegan/flutter_architecture_samples)
- [Riverpod Examples](https://github.com/rrousselGit/riverpod/tree/master/examples)

### Advanced

- [Flutter Engine](https://github.com/flutter/engine)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---

**Last Updated:** November 8, 2025
