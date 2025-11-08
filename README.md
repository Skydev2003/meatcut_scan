# MeatCut Scan — แอปสแกนและเรียนรู้ประเภทเนื้อด้วย AI

MeatCut Scan คือแอปพลิเคชัน Flutter ที่ใช้ปัญญาประดิษฐ์ (AI) ในการวิเคราะห์และจำแนกประเภทของเนื้อ เช่น สันนอก, สันใน, สันคอ, หรือส่วนอื่น ๆ

## 🔧 ฟีเจอร์หลัก

- **AI Scan & Predict** — ถ่ายภาพหรือเลือกรูปจากเครื่อง แล้วให้โมเดลวิเคราะห์ว่าเป็นเนื้อประเภทใด
- **On-device Learning** — ผู้ใช้สามารถเพิ่มข้อมูลตัวอย่างใหม่ ("สอนแอป") เพื่อให้แอปเรียนรู้เพิ่มได้ทันที
- **Smart k-NN Classification** — ใช้เทคนิคคำนวณความใกล้เคียงของ embedding เพื่อทำนายผลอย่างรวดเร็ว
- **Cloud Sync with Supabase** — เก็บข้อมูลตัวอย่าง (embedding, label, รูปภาพ) และเวอร์ชันของโมเดลไว้บนคลาวด์
- **User Authentication** — ลงชื่อเข้าใช้งานด้วย Supabase Auth
- **Clean Architecture + Riverpod** — ใช้สถาปัตยกรรมที่จัดระเบียบชัดเจน
- **Beautiful & Modern UI** — ออกแบบด้วย Material 3 และโทนสีฟ้าน้ำเงิน (#1D4ED8)

## 🧠 เทคโนโลยีหลัก

- Flutter 3.x
- Riverpod + Freezed
- GoRouter
- TensorFlow Lite (MobileNetV3)
- Supabase

## 🚀 การติดตั้ง

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📝 การตั้งค่า Supabase

1. สร้างโปรเจกต์ใน [Supabase](https://supabase.com)
2. คัดลอก URL และ Anon Key
3. สร้างไฟล์ `lib/src/config/supabase_config.dart` และใส่ค่า:

```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

## 🎯 โครงสร้างโปรเจกต์

```
lib/
├── src/
│   ├── apis/          # API clients
│   ├── config/        # Configuration
│   ├── constants/     # Constants
│   ├── database/      # Local database
│   ├── extensions/    # Extensions
│   ├── models/        # Data models
│   ├── providers/     # Riverpod providers
│   ├── routes/        # GoRouter configuration
│   ├── screens/       # UI screens
│   ├── services/      # Business logic
│   ├── theme/         # Theme configuration
│   └── widgets/       # Reusable widgets
├── app.dart           # App widget
└── main.dart          # Entry point
```
