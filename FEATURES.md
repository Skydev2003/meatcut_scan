# Features Documentation

## 🎯 Core Features

### 1. AI-Powered Meat Classification

แอปใช้ Machine Learning เพื่อจำแนกประเภทของเนื้อ

**เทคโนโลยี:**
- TensorFlow Lite สำหรับ on-device inference
- MobileNetV3 สำหรับ feature extraction
- k-NN algorithm สำหรับ classification

**ประเภทเนื้อที่รองรับ:**
- สันนอก
- สันใน
- สันคอ
- สะโพก
- น่อง
- อื่นๆ

**วิธีการทำงาน:**
1. ผู้ใช้ถ่ายภาพเนื้อ
2. แอปแปลงภาพเป็น embedding (vector 1280 มิติ)
3. เปรียบเทียบกับข้อมูลตัวอย่างที่มีอยู่
4. ใช้ k-NN หา 5 ตัวอย่างที่ใกล้เคียงที่สุด
5. นับ votes และแสดงผลพร้อม confidence score

### 2. On-Device Learning

ผู้ใช้สามารถสอนแอปให้ฉลาดขึ้นได้เอง

**ข้อดี:**
- ไม่ต้องรีเทรนโมเดลบนเซิร์ฟเวอร์
- เรียนรู้ได้ทันที
- ทำงานออฟไลน์ได้
- ข้อมูลเก็บไว้ในเครื่อง

**วิธีการใช้งาน:**
1. ถ่ายภาพเนื้อ
2. เลือกประเภทที่ถูกต้อง
3. กดเพิ่มข้อมูล
4. แอปจะจำและใช้ในการทำนายครั้งต่อไป

### 3. Smart k-NN Classification

ใช้ k-Nearest Neighbors algorithm

**พารามิเตอร์:**
- k = 5 (จำนวน neighbors)
- Distance metric: Euclidean distance
- Confidence threshold: 60%

**การคำนวณ Confidence:**
```
confidence = votes_for_winner / k
```

ตัวอย่าง: ถ้า 4 จาก 5 neighbors เป็น "สันนอก"
```
confidence = 4 / 5 = 0.8 (80%)
```

### 4. Cloud Sync with Supabase

เก็บข้อมูลบนคลาวด์และซิงค์ระหว่างอุปกรณ์

**ข้อมูลที่เก็บ:**
- Training samples (embedding + label)
- รูปภาพ (Supabase Storage)
- User profile
- Model version

**ความปลอดภัย:**
- Row Level Security (RLS)
- User-specific data isolation
- Secure authentication

### 5. User Authentication

ระบบยืนยันตัวตนด้วย Supabase Auth

**รองรับ:**
- Email/Password
- (ขยายได้: Google, Facebook, etc.)

**ฟีเจอร์:**
- Sign up
- Sign in
- Sign out
- Session management

### 6. Offline-First Architecture

ทำงานได้แม้ไม่มีอินเทอร์เน็ต

**Local Storage:**
- SharedPreferences สำหรับ training samples
- Cache สำหรับรูปภาพ
- Model files ใน assets

**Sync Strategy:**
- เก็บข้อมูลใน local ก่อน
- Sync ไปยัง cloud เมื่อมีอินเทอร์เน็ต
- Conflict resolution (last-write-wins)

## 🎨 UI/UX Features

### Modern Material 3 Design

- สีหลัก: Blue (#1D4ED8)
- สีรอง: Green (#10B981)
- Typography: Roboto
- Rounded corners
- Elevation และ shadows

### Responsive Layout

- รองรับหน้าจอทุกขนาด
- Adaptive UI สำหรับ tablet
- Portrait และ landscape mode

### Smooth Animations

- Page transitions
- Loading states
- Success/Error feedback

## 📊 Statistics & Analytics

### User Statistics

- จำนวนตัวอย่างทั้งหมด
- จำนวนประเภทเนื้อที่เรียนรู้
- ตัวอย่างล่าสุด
- Accuracy over time

### Sample Distribution

- แสดงจำนวนตัวอย่างแต่ละประเภท
- Visualization ด้วย charts
- Export เป็น CSV

## 🔒 Security Features

### Data Privacy

- ข้อมูลแยกตาม user
- ไม่แชร์ข้อมูลระหว่าง users
- Local encryption (optional)

### Authentication Security

- Secure password hashing
- JWT tokens
- Session timeout
- Refresh tokens

## 🚀 Performance Optimizations

### Image Processing

- Resize ภาพก่อน process
- Compress ก่อน upload
- Cache processed images

### ML Inference

- Lazy loading model
- Reuse interpreter
- Batch processing (future)

### Database

- Index สำหรับ queries ที่ใช้บ่อย
- Pagination สำหรับรายการยาว
- Lazy loading

## 🔧 Developer Features

### Clean Architecture

- Separation of concerns
- Testable code
- Maintainable structure

### State Management

- Riverpod 2.x
- Type-safe providers
- Automatic disposal

### Code Generation

- Freezed สำหรับ models
- JSON serialization
- Riverpod generators

### Error Handling

- Try-catch blocks
- User-friendly error messages
- Logging system

## 📱 Platform Support

### Android

- Minimum SDK: 21 (Android 5.0)
- Target SDK: 34 (Android 14)
- Permissions: Camera, Storage

### iOS

- Minimum version: 12.0
- Permissions: Camera, Photo Library

### Web (Future)

- Progressive Web App
- Camera API
- IndexedDB storage

## 🎯 Future Features

### Planned

- [ ] Batch prediction
- [ ] Model versioning
- [ ] A/B testing
- [ ] Push notifications
- [ ] Social sharing
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Export/Import data
- [ ] Advanced statistics
- [ ] Custom model training

### Under Consideration

- [ ] AR visualization
- [ ] Voice commands
- [ ] Barcode scanning
- [ ] Recipe suggestions
- [ ] Price comparison
- [ ] Nutrition information
