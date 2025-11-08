# API Reference

## Providers

### Auth Provider

```dart
final authProvider = StateNotifierProvider<AuthNotifier, AppAuthState>
```

**States:**
- `initial()` - สถานะเริ่มต้น
- `loading()` - กำลังโหลด
- `authenticated(userId, email)` - ล็อกอินสำเร็จ
- `unauthenticated()` - ยังไม่ได้ล็อกอิน
- `error(message)` - เกิดข้อผิดพลาด

**Methods:**
- `signIn(email, password)` - ล็อกอิน
- `signUp(email, password)` - สมัครสมาชิก
- `signOut()` - ออกจากระบบ

**Usage:**
```dart
// Watch state
final authState = ref.watch(authProvider);

// Sign in
await ref.read(authProvider.notifier).signIn(email, password);

// Sign out
await ref.read(authProvider.notifier).signOut();
```

### Samples Provider

```dart
final samplesNotifierProvider = StateNotifierProvider<SamplesNotifier, AsyncValue<List<MeatSample>>>
```

**Methods:**
- `addSample(sample)` - เพิ่มตัวอย่าง
- `clearSamples()` - ลบตัวอย่างทั้งหมด
- `refresh()` - รีเฟรชข้อมูล

**Usage:**
```dart
// Watch samples
final samplesAsync = ref.watch(samplesNotifierProvider);

samplesAsync.when(
  data: (samples) => Text('${samples.length} samples'),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);

// Add sample
await ref.read(samplesNotifierProvider.notifier).addSample(sample);
```

### ML Service Provider

```dart
final mlServiceProvider = Provider<MLService>
```

**Methods:**
- `initialize()` - เริ่มต้นโมเดล
- `extractEmbedding(imageBytes)` - สกัด embedding จากภาพ
- `predict(embedding, samples)` - ทำนายด้วย k-NN
- `dispose()` - ปิดโมเดล

**Usage:**
```dart
final mlService = ref.read(mlServiceProvider);

// Extract embedding
final embedding = await mlService.extractEmbedding(imageBytes);

// Predict
final result = mlService.predict(embedding, samples);
print('Label: ${result.label}');
print('Confidence: ${result.confidence}');
```

### Storage Service Provider

```dart
final storageServiceProvider = Provider<StorageService>
```

**Methods:**
- `initialize()` - เริ่มต้น storage
- `saveSamples(samples)` - บันทึกตัวอย่าง
- `loadSamples()` - โหลดตัวอย่าง
- `addSample(sample)` - เพิ่มตัวอย่าง
- `clearSamples()` - ลบตัวอย่างทั้งหมด
- `getModelVersion()` - ดูเวอร์ชันโมเดล
- `setModelVersion(version)` - ตั้งเวอร์ชันโมเดล

**Usage:**
```dart
final storage = ref.read(storageServiceProvider);

// Load samples
final samples = await storage.loadSamples();

// Add sample
await storage.addSample(sample);
```

### Supabase Provider

```dart
final supabaseProvider = Provider<SupabaseClient>
```

**Usage:**
```dart
final supabase = ref.read(supabaseProvider);

// Query data
final response = await supabase
    .from('samples')
    .select()
    .eq('user_id', userId);

// Insert data
await supabase.from('samples').insert(data);
```

## Models

### MeatSample

```dart
@freezed
class MeatSample with _$MeatSample {
  const factory MeatSample({
    required String id,
    required String label,
    required List<double> embedding,
    String? imageUrl,
    String? userId,
    DateTime? createdAt,
  }) = _MeatSample;

  factory MeatSample.fromJson(Map<String, dynamic> json);
}
```

**Properties:**
- `id` - รหัสตัวอย่าง
- `label` - ประเภทเนื้อ
- `embedding` - Vector 1280 มิติ
- `imageUrl` - URL รูปภาพ (optional)
- `userId` - รหัสผู้ใช้ (optional)
- `createdAt` - วันที่สร้าง (optional)

**Usage:**
```dart
// Create
final sample = MeatSample(
  id: '123',
  label: 'สันนอก',
  embedding: [0.1, 0.2, ...],
  createdAt: DateTime.now(),
);

// To JSON
final json = sample.toJson();

// From JSON
final sample = MeatSample.fromJson(json);

// Copy with
final updated = sample.copyWith(label: 'สันใน');
```

### PredictionResult

```dart
@freezed
class PredictionResult with _$PredictionResult {
  const factory PredictionResult({
    required String label,
    required double confidence,
    required List<double> embedding,
  }) = _PredictionResult;

  factory PredictionResult.fromJson(Map<String, dynamic> json);
}
```

**Properties:**
- `label` - ประเภทเนื้อที่ทำนาย
- `confidence` - ความมั่นใจ (0.0 - 1.0)
- `embedding` - Vector ที่ใช้ทำนาย

### AppAuthState

```dart
@freezed
class AppAuthState with _$AppAuthState {
  const factory AppAuthState.initial() = _Initial;
  const factory AppAuthState.loading() = _Loading;
  const factory AppAuthState.authenticated({
    required String userId,
    required String email,
  }) = _Authenticated;
  const factory AppAuthState.unauthenticated() = _Unauthenticated;
  const factory AppAuthState.error(String message) = _Error;
}
```

**Usage:**
```dart
authState.when(
  initial: () => Text('Initializing...'),
  loading: () => CircularProgressIndicator(),
  authenticated: (userId, email) => Text('Welcome $email'),
  unauthenticated: () => Text('Please sign in'),
  error: (message) => Text('Error: $message'),
);

// Or use maybeWhen
authState.maybeWhen(
  authenticated: (userId, email) => Text('Logged in'),
  orElse: () => Text('Not logged in'),
);
```

## Services

### MLService

```dart
class MLService {
  Future<void> initialize();
  Future<List<double>> extractEmbedding(Uint8List imageBytes);
  PredictionResult predict(List<double> embedding, List<MeatSample> samples);
  void dispose();
}
```

**extractEmbedding:**
- Input: `Uint8List imageBytes` - ภาพในรูปแบบ bytes
- Output: `List<double>` - Embedding vector (1280 มิติ)
- Throws: `Exception` ถ้าไม่สามารถ decode ภาพได้

**predict:**
- Input:
  - `embedding` - Vector ที่ต้องการทำนาย
  - `samples` - รายการตัวอย่างสำหรับเทรน
- Output: `PredictionResult` - ผลการทำนาย
- Throws: `Exception` ถ้าไม่มีตัวอย่าง

**Algorithm:**
1. คำนวณ Euclidean distance กับทุก sample
2. เรียงตาม distance
3. เลือก k=5 samples ที่ใกล้ที่สุด
4. นับ votes สำหรับแต่ละ label
5. เลือก label ที่มี votes มากที่สุด
6. คำนวณ confidence = votes / k

### StorageService

```dart
class StorageService {
  Future<void> initialize();
  Future<void> saveSamples(List<MeatSample> samples);
  Future<List<MeatSample>> loadSamples();
  Future<void> addSample(MeatSample sample);
  Future<void> clearSamples();
  Future<String?> getModelVersion();
  Future<void> setModelVersion(String version);
}
```

**Storage Keys:**
- `training_samples` - รายการตัวอย่าง (JSON)
- `model_version` - เวอร์ชันโมเดล (String)

## APIs

### SupabaseApi

```dart
class SupabaseApi {
  String? get currentUserId;
  Future<AuthResponse> signIn(String email, String password);
  Future<AuthResponse> signUp(String email, String password);
  Future<void> signOut();
  Future<void> uploadSample(MeatSample sample);
  Future<List<MeatSample>> fetchSamples();
  Future<void> deleteSample(String sampleId);
  Future<void> syncSamples(List<MeatSample> samples);
}
```

**Database Schema:**

```sql
CREATE TABLE samples (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  label TEXT NOT NULL,
  embedding FLOAT8[] NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

## Constants

### AppConstants

```dart
class AppConstants {
  // App Info
  static const String appName = 'MeatCut Scan';
  static const String appVersion = '0.1.0';
  
  // AI Model
  static const String modelPath = 'assets/models/mobilenet_v3.tflite';
  static const int embeddingSize = 1280;
  static const int imageSize = 224;
  
  // k-NN
  static const int kNeighbors = 5;
  static const double confidenceThreshold = 0.6;
  
  // Storage Keys
  static const String samplesKey = 'training_samples';
  static const String modelVersionKey = 'model_version';
  
  // Meat Types
  static const List<String> meatTypes = [
    'สันนอก',
    'สันใน',
    'สันคอ',
    'สะโพก',
    'น่อง',
    'อื่นๆ',
  ];
}
```

## Theme

### AppTheme

```dart
class AppTheme {
  // Colors
  static const Color primaryColor = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E40AF);
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color backgroundColor = Color(0xFFF9FAFB);
  static const Color surfaceColor = Colors.white;
  
  // Theme
  static ThemeData get lightTheme;
}
```

## Router

### AppRouter

```dart
final appRouterProvider = Provider<GoRouter>
```

**Routes:**
- `/signin` - หน้า Sign In
- `/home` - หน้าหลัก
- `/capture` - หน้าถ่ายภาพ
- `/predict` - หน้าแสดงผล (รับ `List<int>` imageBytes ผ่าน extra)

**Navigation:**
```dart
// Push
context.push('/capture');

// Push with data
context.push('/predict', extra: imageBytes);

// Pop
context.pop();

// Replace
context.replace('/home');
```

**Guard:**
- ถ้ายังไม่ได้ล็อกอิน จะ redirect ไป `/signin`
- ถ้าล็อกอินแล้วและอยู่ที่ `/signin` จะ redirect ไป `/home`

## Widgets

### LoadingOverlay

```dart
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;
}
```

**Usage:**
```dart
LoadingOverlay(
  isLoading: isLoading,
  message: 'กำลังโหลด...',
  child: YourWidget(),
)
```

## Extensions

### ListExtensions

```dart
extension ListExtensions<T> on List<T> {
  T? getOrNull(int index);
}
```

**Usage:**
```dart
final list = [1, 2, 3];
final item = list.getOrNull(5); // null instead of error
```

## Error Handling

### Common Errors

**AuthException:**
```dart
try {
  await ref.read(authProvider.notifier).signIn(email, password);
} catch (e) {
  if (e is AuthException) {
    print('Auth error: ${e.message}');
  }
}
```

**MLException:**
```dart
try {
  final embedding = await mlService.extractEmbedding(imageBytes);
} catch (e) {
  print('ML error: $e');
}
```

**StorageException:**
```dart
try {
  await storage.saveSamples(samples);
} catch (e) {
  print('Storage error: $e');
}
```

## Best Practices

### Provider Usage

```dart
// ✅ Good - Watch in build method
@override
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authProvider);
  return Text(authState.toString());
}

// ✅ Good - Read in event handler
onPressed: () {
  ref.read(authProvider.notifier).signOut();
}

// ❌ Bad - Watch in event handler
onPressed: () {
  final state = ref.watch(authProvider); // Don't do this
}
```

### Async Operations

```dart
// ✅ Good - Handle loading and error states
samplesAsync.when(
  data: (samples) => ListView(...),
  loading: () => CircularProgressIndicator(),
  error: (e, _) => Text('Error: $e'),
);

// ❌ Bad - Assume data is always available
final samples = samplesAsync.value!; // Can be null
```

### State Management

```dart
// ✅ Good - Immutable state
final newState = state.copyWith(name: 'New Name');

// ❌ Bad - Mutate state
state.name = 'New Name'; // Don't do this with Freezed
```

---

**Version:** 0.1.0
**Last Updated:** November 8, 2025
