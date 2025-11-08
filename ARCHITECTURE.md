# Architecture Documentation

## Overview

MeatCut Scan ใช้ Clean Architecture pattern ร่วมกับ Riverpod สำหรับ state management

## Layers

### 1. Presentation Layer (UI)

- **Screens**: หน้าจอหลักของแอป
  - `SignInScreen`: หน้า login/register
  - `HomeScreen`: หน้าหลัก แสดงสถิติและเมนู
  - `CaptureScreen`: หน้าถ่ายภาพ/เลือกรูป
  - `PredictScreen`: หน้าแสดงผลการทำนายและเพิ่มข้อมูล

- **Widgets**: Component ที่ใช้ซ้ำได้
  - `LoadingOverlay`: แสดง loading state

- **Theme**: การตั้งค่า theme และสี

### 2. Domain Layer (Business Logic)

- **Models**: Data models ที่ใช้ Freezed
  - `MeatSample`: ข้อมูลตัวอย่างเนื้อ (embedding + label)
  - `PredictionResult`: ผลการทำนาย
  - `AuthState`: สถานะการ authentication

- **Services**: Business logic
  - `MLService`: การทำงานของ ML (embedding extraction, k-NN)
  - `StorageService`: การจัดเก็บข้อมูลใน local storage

### 3. Data Layer

- **APIs**: การเชื่อมต่อกับ backend
  - `SupabaseApi`: API client สำหรับ Supabase

- **Providers**: Riverpod providers
  - `authProvider`: จัดการ authentication state
  - `samplesProvider`: จัดการข้อมูลตัวอย่าง
  - `mlServiceProvider`: จัดการ ML service
  - `storageServiceProvider`: จัดการ storage service

### 4. Infrastructure

- **Config**: Configuration files
  - `SupabaseConfig`: Supabase credentials

- **Constants**: ค่าคงที่
  - `AppConstants`: ค่าคงที่ต่างๆ ของแอป

- **Routes**: Navigation
  - `AppRouter`: GoRouter configuration

## Data Flow

```
User Action
    ↓
Screen (UI)
    ↓
Provider (State Management)
    ↓
Service (Business Logic)
    ↓
API/Storage (Data Layer)
    ↓
Backend/Local Storage
```

## State Management

ใช้ Riverpod 2.x สำหรับ state management:

- **Provider**: สำหรับ dependencies ที่ไม่เปลี่ยนแปลง
- **StateNotifierProvider**: สำหรับ state ที่เปลี่ยนแปลงได้
- **FutureProvider**: สำหรับ async data

## ML Pipeline

```
Image (Uint8List)
    ↓
Preprocessing (resize to 224x224)
    ↓
TFLite Model (MobileNetV3)
    ↓
Embedding (1280 dimensions)
    ↓
k-NN Classifier
    ↓
Prediction Result (label + confidence)
```

## k-NN Algorithm

1. คำนวณ Euclidean distance ระหว่าง embedding ใหม่กับทุก sample
2. เลือก k samples ที่ใกล้ที่สุด (k=5)
3. นับ votes สำหรับแต่ละ label
4. เลือก label ที่มี votes มากที่สุด
5. คำนวณ confidence จากสัดส่วนของ votes

## Storage Strategy

### Local Storage (SharedPreferences)

- Training samples (JSON)
- Model version
- User preferences

### Cloud Storage (Supabase)

- Training samples (with user_id)
- Images (Supabase Storage)
- User authentication

## Security

- Row Level Security (RLS) ใน Supabase
- User-specific data isolation
- Secure authentication with Supabase Auth

## Performance Considerations

- Lazy loading สำหรับรายการตัวอย่าง
- Image compression ก่อน upload
- Caching embeddings
- Offline-first approach

## Testing Strategy

- Unit tests สำหรับ services
- Widget tests สำหรับ UI components
- Integration tests สำหรับ user flows
- Mock providers สำหรับ testing

## Future Improvements

- Add repository pattern
- Implement use cases
- Add dependency injection
- Improve error handling
- Add logging system
