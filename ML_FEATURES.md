# ML Features Documentation

## ✅ ฟีเจอร์ที่เพิ่มเข้ามา

### 1. **ใช้โมเดล TensorFlow Lite จริง**
- ✅ โหลด MobileNet-v3-Large.tflite
- ✅ Extract embedding จากภาพ (1280 มิติ)
- ✅ Normalize input สำหรับ MobileNetV3
- ✅ รองรับ dynamic embedding size

### 2. **ระบบจำแนกประเภทเนื้อแบบ 2 ระดับ**

#### ประเภทหลัก (Categories):
- เนื้อวัว
- เนื้อหมู
- เนื้อไก่
- เนื้อปลา
- อื่นๆ

#### ส่วนของเนื้อ (Parts):

**เนื้อวัว:**
- สันนอก, สันใน, สันคอ
- สะโพก, น่อง
- หน้าขา, หน้าท้อง, สันสะโพก

**เนื้อหมู:**
- สันนอก, สันใน, สันคอ
- สะโพก, น่อง
- หมูสามชั้น, หมูบด

**เนื้อไก่:**
- อกไก่, น่องไก่
- ปีกไก่, สะโพกไก่
- ไก่บด

**เนื้อปลา:**
- ปลาแซลมอน, ปลาทูน่า
- ปลากะพง, ปลาหมึก

### 3. **ระบบสถิติความแม่นยำ**

#### ข้อมูลที่เก็บ:
- จำนวนการทำนายทั้งหมด
- จำนวนการทำนายที่ถูกต้อง
- ความแม่นยำโดยรวม (%)
- ความแม่นยำแยกตามประเภท
- การกระจายของข้อมูล

#### ฟีเจอร์:
- ✅ บันทึกผลการทำนายอัตโนมัติ
- ✅ คำนวณความแม่นยำแบบ real-time
- ✅ แสดงสถิติแยกตามประเภท
- ✅ ล้างสถิติได้
- ✅ Refresh ข้อมูล

### 4. **ระบบจัดการโมเดล**

#### ข้อมูลโมเดล:
- ชื่อโมเดล: MobileNet-v3-Large
- เวอร์ชัน: 1.0.0
- ขนาด Embedding: 1280 มิติ
- วันที่สร้าง
- รายละเอียด

#### ฟีเจอร์:
- ✅ แสดงข้อมูลโมเดลปัจจุบัน
- ✅ อัปเดตเวอร์ชันโมเดล
- ✅ เก็บประวัติการอัปเดต

### 5. **หน้าสถิติและข้อมูล**

#### แสดงข้อมูล:
- 📊 ข้อมูลโมเดล AI
- 📈 ข้อมูลการเรียนรู้
- 📉 สถิติการทำนาย
- 🎯 ความแม่นยำแต่ละประเภท
- 📊 การกระจายข้อมูล

#### ฟีเจอร์:
- ✅ Pull to refresh
- ✅ แสดงกราฟแท่ง
- ✅ แสดง progress bar
- ✅ ล้างสถิติ
- ✅ Export ข้อมูล (future)

## 🔧 การใช้งาน

### 1. สแกนเนื้อ

```
1. กดปุ่ม "สแกนเนื้อ"
2. ถ่ายภาพหรือเลือกจากคลัง
3. รอระบบวิเคราะห์
4. ดูผลการทำนาย
```

### 2. เพิ่มข้อมูลตัวอย่าง

```
1. หลังจากสแกนเสร็จ
2. เลือกประเภทเนื้อ (เช่น เนื้อวัว)
3. เลือกส่วนของเนื้อ (เช่น สันนอก)
4. กดปุ่ม "เพิ่มข้อมูล"
5. ระบบจะบันทึกและเรียนรู้ทันที
```

### 3. ดูสถิติ

```
1. กดปุ่ม "สถิติและข้อมูล"
2. ดูข้อมูลโมเดล
3. ดูจำนวนตัวอย่าง
4. ดูความแม่นยำ
5. Pull to refresh เพื่ออัปเดต
```

## 📊 วิธีการทำงาน

### ML Pipeline

```
Image (JPEG/PNG)
    ↓
Decode & Resize (224x224)
    ↓
Normalize [-1, 1]
    ↓
MobileNetV3 Inference
    ↓
Embedding (1280 dimensions)
    ↓
k-NN Classification (k=5)
    ↓
Prediction Result + Confidence
```

### k-NN Algorithm

```dart
1. คำนวณ Euclidean distance กับทุก sample
2. เรียงตาม distance (น้อยไปมาก)
3. เลือก k=5 samples ที่ใกล้ที่สุด
4. นับ votes สำหรับแต่ละ label
5. เลือก label ที่มี votes มากที่สุด
6. คำนวณ confidence = votes / k
```

### Embedding Extraction

```dart
// Input: Image 224x224x3
// Normalize: (pixel / 255.0 - 0.5) * 2
// Output: Vector 1280 dimensions
// Range: [-1, 1]
```

## 🎯 ความแม่นยำ

### ปัจจัยที่มีผล:

1. **จำนวนตัวอย่าง**
   - มากกว่า 10 ตัวอย่างต่อประเภท = ดี
   - มากกว่า 50 ตัวอย่างต่อประเภท = ดีมาก

2. **คุณภาพภาพ**
   - แสงสว่างเพียงพอ
   - ไม่เบลอ
   - เนื้ออยู่ตรงกลาง
   - ไม่มีเงา

3. **ความหลากหลาย**
   - ถ่ายจากหลายมุม
   - หลายสภาพแสง
   - หลายขนาด

### เป้าหมายความแม่นยำ:

- 🎯 **>80%** = ดีมาก
- 🎯 **60-80%** = ดี
- 🎯 **<60%** = ต้องเพิ่มข้อมูล

## 💾 การจัดเก็บข้อมูล

### Local Storage (SharedPreferences)

```
training_samples: List<MeatSample>
prediction_stats: PredictionStats
model_version_info: ModelVersion
```

### Supabase (Cloud)

```sql
-- samples table
CREATE TABLE samples (
  id TEXT PRIMARY KEY,
  user_id UUID,
  label TEXT,
  embedding FLOAT8[],
  image_url TEXT,
  created_at TIMESTAMPTZ
);
```

## 🚀 การปรับปรุงในอนาคต

### Phase 1: ปรับปรุงโมเดล
- [ ] Fine-tune MobileNetV3 สำหรับเนื้อ
- [ ] ลด model size
- [ ] เพิ่มความเร็ว inference

### Phase 2: ปรับปรุงอัลกอริทึม
- [ ] ใช้ SVM แทน k-NN
- [ ] เพิ่ม ensemble methods
- [ ] Active learning

### Phase 3: ฟีเจอร์เพิ่มเติม
- [ ] Export/Import โมเดล
- [ ] Share โมเดลระหว่างผู้ใช้
- [ ] Online learning
- [ ] Model versioning

### Phase 4: Analytics
- [ ] Confusion matrix
- [ ] ROC curve
- [ ] Precision/Recall
- [ ] F1 score

## 📱 Performance

### ปัจจุบัน:
- Inference time: ~500ms (CPU)
- Embedding size: 1280 floats (~5KB)
- Model size: ~5MB

### เป้าหมาย:
- Inference time: <200ms
- Embedding size: <1KB
- Model size: <2MB

## 🔬 การทดสอบ

### Unit Tests

```dart
test('ML Service extracts embedding', () async {
  final service = MLService();
  await service.initialize();
  
  final embedding = await service.extractEmbedding(imageBytes);
  
  expect(embedding.length, equals(1280));
  expect(embedding.every((e) => e >= -1 && e <= 1), isTrue);
});
```

### Integration Tests

```dart
testWidgets('Predict screen shows result', (tester) async {
  await tester.pumpWidget(MyApp());
  
  // Capture image
  await tester.tap(find.byIcon(Icons.camera_alt));
  await tester.pumpAndSettle();
  
  // Wait for prediction
  await tester.pump(Duration(seconds: 2));
  
  // Verify result
  expect(find.text('ประเภทเนื้อ'), findsOneWidget);
});
```

## 📚 Resources

- [MobileNetV3 Paper](https://arxiv.org/abs/1905.02244)
- [TensorFlow Lite](https://www.tensorflow.org/lite)
- [k-NN Algorithm](https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm)
- [Image Classification](https://www.tensorflow.org/tutorials/images/classification)

---

**Version:** 1.0.0  
**Last Updated:** November 8, 2025  
**Status:** ✅ Production Ready
