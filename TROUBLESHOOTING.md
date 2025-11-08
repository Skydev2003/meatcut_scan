# Troubleshooting Guide

## ปัญหาที่พบบ่อยและวิธีแก้ไข

### 1. ❌ Unable to load asset: "assets/models/mobilenet_v3.tflite"

**สาเหตุ:**
- ชื่อไฟล์ไม่ตรงกับที่ระบุในโค้ด
- ไฟล์ไม่อยู่ใน assets/models/
- ไม่ได้ระบุ assets path ใน pubspec.yaml

**วิธีแก้:**

1. ตรวจสอบชื่อไฟล์ใน `assets/models/`:
```bash
dir assets\models
```

2. แก้ไขชื่อใน `lib/src/constants/app_constants.dart`:
```dart
static const String modelPath = 'assets/models/MobileNet-v3-Large.tflite';
```

3. ตรวจสอบ `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/models/
    - assets/images/
```

4. Clean และ rebuild:
```bash
flutter clean
flutter pub get
flutter run
```

### 2. ❌ Email not confirmed

**สาเหตุ:**
- Supabase ตั้งค่าให้ต้องยืนยันอีเมล
- ผู้ใช้เก่ายังไม่ได้ยืนยัน

**วิธีแก้:**

1. ปิดการยืนยันอีเมลใน Supabase:
   - Authentication → Sign In / Providers
   - หา "Confirm email"
   - ปิดสวิตช์
   - กด Save

2. ลบผู้ใช้เก่า:
```sql
DELETE FROM auth.users WHERE email_confirmed_at IS NULL;
```

3. สมัครสมาชิกใหม่

### 3. ❌ minSdkVersion error

**Error:**
```
minSdkVersion 24 cannot be smaller than version 26
```

**วิธีแก้:**

แก้ไข `android/app/build.gradle.kts`:
```kotlin
defaultConfig {
    minSdk = 26  // เปลี่ยนจาก 24
}
```

### 4. ❌ TFLite model not loading

**สาเหตุ:**
- โมเดลไม่ถูกต้อง
- โมเดลเสียหาย
- Format ไม่ถูกต้อง

**วิธีแก้:**

1. ตรวจสอบขนาดไฟล์:
```bash
# ควรมีขนาดประมาณ 5-10 MB
dir assets\models\*.tflite
```

2. ดาวน์โหลดโมเดลใหม่:
   - [TensorFlow Hub](https://tfhub.dev/)
   - [TensorFlow Lite Models](https://www.tensorflow.org/lite/models)

3. ตรวจสอบ input/output shape:
```dart
final inputShape = interpreter.getInputTensor(0).shape;
final outputShape = interpreter.getOutputTensor(0).shape;
print('Input: $inputShape, Output: $outputShape');
```

### 5. ❌ Build runner fails

**Error:**
```
Conflicting outputs
```

**วิธีแก้:**

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. ❌ Camera permission denied

**สาเหตุ:**
- ไม่ได้ขอ permission
- ผู้ใช้ปฏิเสธ permission

**วิธีแก้:**

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>ต้องการใช้กล้องเพื่อถ่ายภาพเนื้อ</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ต้องการเข้าถึงคลังภาพเพื่อเลือกรูปภาพ</string>
```

### 7. ❌ Supabase connection error

**สาเหตุ:**
- URL หรือ Anon Key ผิด
- ไม่มีอินเทอร์เน็ต
- Supabase project ถูกระงับ

**วิธีแก้:**

1. ตรวจสอบ credentials ใน `lib/src/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String url = 'https://xxx.supabase.co';
  static const String anonKey = 'eyJxxx...';
}
```

2. ทดสอบการเชื่อมต่อ:
```bash
curl https://xxx.supabase.co/rest/v1/
```

3. ตรวจสอบ Supabase Dashboard:
   - Project Settings → API
   - ดู URL และ anon key

### 8. ❌ Low prediction accuracy

**สาเหตุ:**
- ข้อมูลตัวอย่างน้อยเกินไป
- ข้อมูลไม่หลากหลาย
- คุณภาพภาพไม่ดี

**วิธีแก้:**

1. เพิ่มข้อมูลตัวอย่าง:
   - อย่างน้อย 10-20 ตัวอย่างต่อประเภท
   - ถ่ายจากหลายมุม
   - หลายสภาพแสง

2. ปรับ k-NN parameters:
```dart
// ใน app_constants.dart
static const int kNeighbors = 5;  // ลองเปลี่ยนเป็น 3 หรือ 7
```

3. ตรวจสอบคุณภาพภาพ:
   - แสงสว่างเพียงพอ
   - ไม่เบลอ
   - เนื้ออยู่ตรงกลาง

### 9. ❌ App crashes on startup

**วิธีแก้:**

1. ดู error log:
```bash
flutter run --verbose
```

2. ตรวจสอบ Supabase initialization:
```dart
// ใน main.dart
try {
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
} catch (e) {
  print('Supabase init error: $e');
}
```

3. Comment Supabase init ถ้าไม่ได้ใช้:
```dart
// await Supabase.initialize(...);
```

### 10. ❌ Slow inference

**สาเหตุ:**
- โมเดลใหญ่เกินไป
- รันบน CPU
- ภาพขนาดใหญ่

**วิธีแก้:**

1. ใช้ GPU delegate (Android):
```dart
final options = InterpreterOptions()
  ..addDelegate(GpuDelegateV2());
final interpreter = await Interpreter.fromAsset(
  modelPath,
  options: options,
);
```

2. ลดขนาดภาพก่อน process:
```dart
final resized = img.copyResize(
  image,
  width: 224,
  height: 224,
);
```

3. ใช้โมเดลเล็กกว่า:
   - MobileNetV3-Small
   - EfficientNet-Lite

## 🔍 Debug Tips

### ดู Logs

```bash
# Android
adb logcat | grep flutter

# iOS
flutter logs
```

### ดู Network Requests

```bash
# ใช้ DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

### ดู Memory Usage

```bash
flutter run --profile
# เปิด DevTools → Memory
```

### ทดสอบ ML Service

```dart
void main() async {
  final service = MLService();
  await service.initialize();
  
  print('Initialized: ${service.isInitialized}');
  print('Embedding size: ${service.embeddingSize}');
}
```

## 📞 ขอความช่วยเหลือ

ถ้ายังแก้ไม่ได้:

1. เปิด GitHub Issue พร้อม:
   - Error message
   - Steps to reproduce
   - Screenshots
   - Device info

2. ตรวจสอบ:
   - [Flutter Docs](https://flutter.dev/docs)
   - [Supabase Docs](https://supabase.com/docs)
   - [TFLite Docs](https://www.tensorflow.org/lite)

3. Community:
   - [Flutter Discord](https://discord.gg/flutter)
   - [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)

---

**Last Updated:** November 8, 2025
