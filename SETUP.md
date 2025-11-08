# MeatCut Scan - Setup Guide

คู่มือการติดตั้งและตั้งค่าโปรเจกต์

## ขั้นตอนการติดตั้ง

### 1. ติดตั้ง Dependencies

```bash
flutter pub get
```

### 2. ตั้งค่า Supabase

1. สร้างโปรเจกต์ใหม่ที่ [Supabase](https://supabase.com)
2. คัดลอก Project URL และ Anon Key
3. สร้างไฟล์ `lib/src/config/supabase_config.dart`:

```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### 3. สร้าง Database Schema ใน Supabase

รัน SQL นี้ใน Supabase SQL Editor:

```sql
-- Create samples table
CREATE TABLE samples (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  label TEXT NOT NULL,
  embedding FLOAT8[] NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE samples ENABLE ROW LEVEL SECURITY;

-- Create policy for users to access their own samples
CREATE POLICY "Users can access their own samples"
  ON samples
  FOR ALL
  USING (auth.uid() = user_id);

-- Create index for faster queries
CREATE INDEX idx_samples_user_id ON samples(user_id);
CREATE INDEX idx_samples_label ON samples(label);
```

### 4. เพิ่มโมเดล TensorFlow Lite

1. ดาวน์โหลด MobileNetV3 model (.tflite)
2. วางไฟล์ไว้ที่ `assets/models/mobilenet_v3.tflite`

หรือใช้คำสั่งนี้เพื่อดาวน์โหลดโมเดลตัวอย่าง:

```bash
# TODO: เพิ่ม URL สำหรับดาวน์โหลดโมเดล
```

### 5. Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6. รันแอป

```bash
flutter run
```

## การตั้งค่าเพิ่มเติม

### Android

แก้ไข `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // เพิ่มจาก 16 เป็น 21 สำหรับ TFLite
    }
}
```

### iOS

แก้ไข `ios/Podfile`:

```ruby
platform :ios, '12.0'  # เพิ่มจาก 9.0 เป็น 12.0
```

### Permissions

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>ต้องการใช้กล้องเพื่อถ่ายภาพเนื้อ</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>ต้องการเข้าถึงคลังภาพเพื่อเลือกรูปภาพ</string>
```

## การทดสอบ

### ทดสอบโดยไม่มี Supabase

หากยังไม่ได้ตั้งค่า Supabase สามารถใช้งานแบบออฟไลน์ได้:

1. Comment บรรทัด Supabase initialization ใน `lib/main.dart`
2. ข้ามขั้นตอน Sign In โดยแก้ไข router guard

### ทดสอบโดยไม่มี TFLite Model

แอปจะใช้ dummy embedding สำหรับทดสอบ ดูที่ `lib/src/services/ml_service.dart`

## Troubleshooting

### ปัญหา: Build runner ไม่ทำงาน

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### ปัญหา: TFLite ไม่ทำงานบน iOS

ตรวจสอบว่าได้เพิ่ม platform version ใน Podfile แล้ว

### ปัญหา: Camera ไม่ทำงาน

ตรวจสอบ permissions ใน AndroidManifest.xml และ Info.plist

## โครงสร้างโปรเจกต์

```
lib/
├── src/
│   ├── apis/          # Supabase API client
│   ├── config/        # Configuration (Supabase credentials)
│   ├── constants/     # App constants
│   ├── extensions/    # Dart extensions
│   ├── models/        # Data models (Freezed)
│   ├── providers/     # Riverpod providers
│   ├── routes/        # GoRouter configuration
│   ├── screens/       # UI screens
│   ├── services/      # Business logic (ML, Storage)
│   ├── theme/         # Theme configuration
│   └── widgets/       # Reusable widgets
├── app.dart           # App widget
└── main.dart          # Entry point
```

## ขั้นตอนถัดไป

1. เพิ่มโมเดล TensorFlow Lite จริง
2. ปรับปรุง UI/UX
3. เพิ่มฟีเจอร์ Cloud Sync
4. เพิ่มการแสดงผลสถิติ
5. เพิ่มการ Export/Import ข้อมูล
