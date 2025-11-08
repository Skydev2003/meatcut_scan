# Quick Start Guide

เริ่มต้นใช้งาน MeatCut Scan ภายใน 5 นาที!

## ขั้นตอนที่ 1: ติดตั้ง Dependencies

```bash
flutter pub get
```

## ขั้นตอนที่ 2: Generate Code

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## ขั้นตอนที่ 3: ตั้งค่า Supabase (Optional)

หากต้องการใช้งาน Cloud Sync:

1. สร้างโปรเจกต์ที่ [supabase.com](https://supabase.com)
2. คัดลอก `lib/src/config/supabase_config.example.dart` เป็น `lib/src/config/supabase_config.dart`
3. ใส่ URL และ Anon Key ของคุณ
4. รัน SQL schema จากไฟล์ `supabase_schema.sql`

## ขั้นตอนที่ 4: รันแอป

```bash
flutter run
```

## การใช้งานแบบออฟไลน์

หากยังไม่ได้ตั้งค่า Supabase:

1. Comment บรรทัดนี้ใน `lib/main.dart`:

```dart
// await Supabase.initialize(
//   url: SupabaseConfig.url,
//   anonKey: SupabaseConfig.anonKey,
// );
```

2. แก้ไข `lib/src/routes/app_router.dart` ให้ข้าม authentication:

```dart
initialLocation: '/home',  // เปลี่ยนจาก '/signin'
```

## การทดสอบ

1. เปิดแอป
2. ไปที่หน้า Capture
3. ถ่ายภาพหรือเลือกรูป
4. ดูผลการทำนาย (จะใช้ dummy embedding)
5. เพิ่มข้อมูลตัวอย่างโดยเลือกประเภทเนื้อ
6. ทดสอบถ่ายภาพใหม่เพื่อดูการเรียนรู้

## ปัญหาที่พบบ่อย

### Build runner ไม่ทำงาน

```bash
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Camera ไม่ทำงาน

ตรวจสอบ permissions:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

### Supabase connection error

ตรวจสอบว่า URL และ Anon Key ถูกต้อง

## ขั้นตอนถัดไป

1. เพิ่มโมเดล TensorFlow Lite จริง
2. ตั้งค่า Supabase สำหรับ Cloud Sync
3. เพิ่มข้อมูลตัวอย่างมากขึ้น
4. ปรับแต่ง UI ตามต้องการ

## ต้องการความช่วยเหลือ?

- อ่าน [SETUP.md](SETUP.md) สำหรับคำแนะนำโดยละเอียด
- อ่าน [ARCHITECTURE.md](ARCHITECTURE.md) เพื่อเข้าใจโครงสร้าง
- ดู [TODO.md](TODO.md) สำหรับฟีเจอร์ที่กำลังพัฒนา
