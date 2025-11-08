# Supabase Setup Guide

## ปัญหา: ล็อกอินไม่ได้หลังสมัครสมาชิก

### สาเหตุ
Supabase ตั้งค่าเริ่มต้นให้ต้องยืนยันอีเมลก่อนล็อกอิน

### วิธีแก้ไข (สำหรับ Development)

#### ขั้นตอนที่ 1: ปิดการยืนยันอีเมล

1. ไปที่ [Supabase Dashboard](https://supabase.com/dashboard)
2. เลือกโปรเจกต์ของคุณ
3. ไปที่ **Authentication** → **Settings** (หรือ **Providers**)
4. เลื่อนลงหา **Email** section
5. ปิด **"Enable email confirmations"** หรือ **"Confirm email"**
6. กด **Save**

#### ขั้นตอนที่ 2: ลบผู้ใช้เก่าที่ยังไม่ได้ยืนยัน (สำคัญ!)

**วิธีที่ 1: ผ่าน Dashboard**
1. ไปที่ **Authentication** → **Users**
2. คลิกที่ผู้ใช้แต่ละคน
3. กดปุ่ม **Delete user**
4. ยืนยันการลบ

**วิธีที่ 2: ผ่าน SQL (เร็วกว่า)**
1. ไปที่ **SQL Editor**
2. รัน SQL นี้:
```sql
-- ลบผู้ใช้ที่ยังไม่ได้ยืนยันอีเมล
DELETE FROM auth.users WHERE email_confirmed_at IS NULL;

-- หรือลบผู้ใช้ทั้งหมด (ระวัง!)
-- DELETE FROM auth.users;
```
3. กด **Run**
4. สมัครสมาชิกใหม่อีกครั้ง

#### ขั้นตอนที่ 3: ทดสอบ

1. สมัครสมาชิกใหม่
2. ควรจะล็อกอินได้ทันทีโดยไม่ต้องยืนยันอีเมล

## การตั้งค่าเพิ่มเติม

### 1. ตั้งค่า Email Templates (Optional)

ถ้าต้องการใช้การยืนยันอีเมล:

1. ไปที่ **Authentication** → **Email Templates**
2. แก้ไข template สำหรับ:
   - Confirm signup
   - Magic Link
   - Change Email Address
   - Reset Password

### 2. ตั้งค่า Redirect URLs

1. ไปที่ **Authentication** → **URL Configuration**
2. เพิ่ม Redirect URLs:
   ```
   http://localhost:3000/*
   your-app-scheme://**
   ```

### 3. ตั้งค่า Rate Limiting

1. ไปที่ **Authentication** → **Rate Limits**
2. ปรับค่าตามต้องการ:
   - Email signups per hour
   - Password signins per hour
   - Password recovery per hour

## การตั้งค่าสำหรับ Production

### 1. เปิดการยืนยันอีเมล

1. เปิด **"Enable email confirmations"**
2. ตั้งค่า Email Templates
3. ตั้งค่า SMTP (optional, ใช้ Supabase SMTP ได้)

### 2. ตั้งค่า Custom SMTP (Optional)

1. ไปที่ **Project Settings** → **Auth**
2. เลื่อนลงหา **SMTP Settings**
3. กรอกข้อมูล:
   - SMTP Host
   - SMTP Port
   - SMTP User
   - SMTP Password
   - Sender Email
   - Sender Name

### 3. ตั้งค่า OAuth Providers (Optional)

เพิ่ม Social Login:

1. ไปที่ **Authentication** → **Providers**
2. เปิดใช้งาน providers ที่ต้องการ:
   - Google
   - Facebook
   - GitHub
   - Apple
   - etc.

## Troubleshooting

### ปัญหา: ยังล็อกอินไม่ได้

**ตรวจสอบ:**
1. Email confirmation ปิดแล้วหรือยัง?
2. ลบผู้ใช้เก่าแล้วหรือยัง?
3. รหัสผ่านถูกต้องหรือไม่?
4. Supabase URL และ Anon Key ถูกต้องหรือไม่?

**ดู Error Message:**
```dart
// ใน SignInScreen จะแสดง SnackBar สีแดงพร้อม error message
```

### ปัญหา: "Invalid login credentials"

**สาเหตุ:**
- รหัสผ่านผิด
- อีเมลยังไม่ได้ยืนยัน (ถ้าเปิด email confirmation)
- ผู้ใช้ถูกลบหรือ banned

**วิธีแก้:**
1. ตรวจสอบรหัสผ่าน
2. ปิด email confirmation
3. สมัครสมาชิกใหม่

### ปัญหา: "Email not confirmed"

**วิธีแก้:**
1. ปิด email confirmation ใน Supabase
2. หรือไปยืนยันอีเมลจาก inbox

### ปัญหา: "User already registered"

**วิธีแก้:**
1. ใช้อีเมลอื่น
2. หรือล็อกอินด้วยอีเมลเดิม
3. หรือลบผู้ใช้เก่าใน Supabase Dashboard

## Database Schema

ตรวจสอบว่ารัน SQL schema แล้ว:

```sql
-- ดูที่ไฟล์ supabase_schema.sql
```

รัน SQL ใน Supabase SQL Editor:
1. ไปที่ **SQL Editor**
2. สร้าง New Query
3. Copy SQL จาก `supabase_schema.sql`
4. กด **Run**

## Testing

### ทดสอบ Authentication

```dart
// ใน Dart/Flutter
final supabase = Supabase.instance.client;

// Sign up
final response = await supabase.auth.signUp(
  email: 'test@example.com',
  password: 'password123',
);

// Sign in
final response = await supabase.auth.signInWithPassword(
  email: 'test@example.com',
  password: 'password123',
);

// Check session
final session = supabase.auth.currentSession;
print('User: ${session?.user.email}');
```

### ทดสอบใน Supabase Dashboard

1. ไปที่ **Authentication** → **Users**
2. ดูรายชื่อผู้ใช้
3. ตรวจสอบ status (Confirmed/Unconfirmed)

## Best Practices

### Development
- ✅ ปิด email confirmation
- ✅ ใช้ test emails
- ✅ ใช้ Supabase local development (optional)

### Production
- ✅ เปิด email confirmation
- ✅ ตั้งค่า custom SMTP
- ✅ ตั้งค่า rate limiting
- ✅ เพิ่ม OAuth providers
- ✅ ตั้งค่า password policies

## Resources

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Email Templates](https://supabase.com/docs/guides/auth/auth-email-templates)
- [OAuth Providers](https://supabase.com/docs/guides/auth/social-login)
- [Rate Limiting](https://supabase.com/docs/guides/auth/rate-limits)

---

**หมายเหตุ:** สำหรับ development แนะนำให้ปิด email confirmation เพื่อความสะดวก แต่สำหรับ production ควรเปิดเพื่อความปลอดภัย
