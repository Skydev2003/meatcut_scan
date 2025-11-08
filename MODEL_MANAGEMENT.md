# Model Management Features

## ✅ ฟีเจอร์ที่เพิ่มเข้ามา

### 1. **ทดสอบโมเดล (Model Testing)**

ทดสอบความแม่นยำของโมเดลด้วย Cross-Validation

**วิธีการทำงาน:**
```
1. แบ่งข้อมูลเป็น train/test
2. สำหรับแต่ละตัวอย่าง:
   - ใช้ตัวอย่างอื่นๆ เป็น training set
   - ทำนายตัวอย่างนั้น
   - เปรียบเทียบกับ label จริง
3. คำนวณความแม่นยำโดยรวม
```

**ผลลัพธ์:**
- จำนวนตัวอย่างที่ทดสอบ
- จำนวนที่ทำนายถูก
- ความแม่นยำ (%)
- การกระจายข้อมูล
- คำแนะนำ

**ตัวอย่างผลลัพธ์:**
```
✅ ทดสอบเสร็จสิ้น

📊 ผลการทดสอบ:
• ทดสอบทั้งหมด: 50 ตัวอย่าง
• ทำนายถูก: 42 ตัวอย่าง
• ความแม่นยำ: 84.0%

📈 การกระจายข้อมูล:
• สันนอก: 15 ตัวอย่าง
• สันใน: 20 ตัวอย่าง
• สันคอ: 15 ตัวอย่าง

🎉 ความแม่นยำดีมาก!
```

### 2. **Export โมเดล (Model Export)**

Export ข้อมูลโมเดลเป็นไฟล์ JSON

**ข้อมูลที่ Export:**
- ข้อมูลโมเดล (version, name, embedding size)
- สถิติการทำนาย
- ข้อมูลตัวอย่างทั้งหมด (embeddings + labels)
- วันที่ export

**รูปแบบไฟล์:**
```json
{
  "version": {
    "version": "1.0.0",
    "modelName": "MobileNet-v3-Large",
    "embeddingSize": 1280,
    "createdAt": "2025-11-08T...",
    "description": "..."
  },
  "stats": {
    "totalPredictions": 100,
    "correctPredictions": 85,
    "accuracy": 0.85,
    "labelCounts": {...},
    "labelAccuracies": {...}
  },
  "samples": [
    {
      "id": "...",
      "label": "สันนอก",
      "embedding": [0.1, 0.2, ...],
      "createdAt": "..."
    }
  ],
  "exported_at": "2025-11-08T..."
}
```

**ฟีเจอร์:**
- ✅ Export เป็นไฟล์ JSON
- ✅ แสดงขนาดไฟล์
- ✅ แชร์ไฟล์ผ่าน Share dialog
- ✅ บันทึกใน Documents folder

### 3. **Import โมเดล (Model Import)**

Import ข้อมูลโมเดลจากไฟล์ JSON

**ขั้นตอน:**
1. เลือกไฟล์ .json
2. แสดงข้อมูลโมเดล
3. ยืนยันการ import
4. แทนที่ข้อมูลเดิม
5. Refresh providers

**การตรวจสอบ:**
- ✅ ตรวจสอบรูปแบบไฟล์
- ✅ ตรวจสอบ version
- ✅ ตรวจสอบ embedding size
- ✅ แสดงคำเตือนก่อน import

**คำเตือน:**
```
⚠️ การ import จะแทนที่ข้อมูลเดิมทั้งหมด
```

### 4. **ล้างข้อมูลทั้งหมด (Clear All Data)**

ลบข้อมูลตัวอย่างและสถิติทั้งหมด

**ข้อมูลที่ลบ:**
- ข้อมูลตัวอย่างทั้งหมด
- สถิติการทำนาย
- ประวัติการใช้งาน

**คำเตือน:**
```
⚠️ การดำเนินการนี้จะลบข้อมูลตัวอย่างและสถิติทั้งหมด
ไม่สามารถกู้คืนได้
```

### 5. **แก้ไข Embedding Size Mismatch**

ตรวจสอบและแจ้งเตือนเมื่อ embedding size ไม่ตรงกัน

**ปัญหา:**
```
❌ Invalid argument(s): Embeddings must have same length
```

**สาเหตุ:**
- โมเดลเปลี่ยน
- ข้อมูลเก่าใช้โมเดลต่างกัน
- Embedding size ไม่ตรงกัน

**วิธีแก้:**
```
1. ตรวจสอบ embedding size
2. แสดง error message ที่ชัดเจน
3. แนะนำให้ลบข้อมูลเก่า
4. เพิ่มข้อมูลใหม่
```

**Error Message ใหม่:**
```
ขนาด embedding ไม่ตรงกัน: 
ภาพใหม่ 1280 มิติ, ข้อมูลเก่า 1000 มิติ
กรุณาลบข้อมูลเก่าและเพิ่มใหม่
```

## 🎯 การใช้งาน

### ทดสอบโมเดล

```
1. ไปที่ "สถิติและข้อมูล"
2. กดไอคอน ⚙️ (Settings)
3. กดปุ่ม "เริ่มทดสอบ"
4. รอผลการทดสอบ
5. ดูความแม่นยำ
```

### Export โมเดล

```
1. ไปที่ "จัดการโมเดล"
2. กดปุ่ม "Export โมเดล"
3. รอการ export
4. เลือก "แชร์" หรือ "ปิด"
5. ไฟล์จะถูกบันทึกใน Documents
```

### Import โมเดล

```
1. ไปที่ "จัดการโมเดล"
2. กดปุ่ม "Import โมเดล"
3. เลือกไฟล์ .json
4. ตรวจสอบข้อมูล
5. ยืนยันการ import
6. รอการ import เสร็จ
```

### แชร์โมเดล

```
1. Export โมเดล
2. กดปุ่ม "แชร์"
3. เลือกแอปที่ต้องการแชร์
4. ส่งไฟล์ให้เพื่อน
5. เพื่อนสามารถ import ได้
```

## 📁 โครงสร้างไฟล์

### Export File

```
Documents/
└── meatcut_model_1699999999999.json
```

### File Naming

```
meatcut_model_{timestamp}.json
```

ตัวอย่าง:
```
meatcut_model_1699456789123.json
```

## 🔒 ความปลอดภัย

### ข้อมูลที่เก็บ

- ✅ Embeddings (ไม่มีรูปภาพ)
- ✅ Labels
- ✅ Statistics
- ✅ Model version

### ข้อมูลที่ไม่เก็บ

- ❌ รูปภาพต้นฉบับ
- ❌ ข้อมูลส่วนตัว
- ❌ API keys

### การแชร์

- ✅ ปลอดภัย - ไม่มีข้อมูลส่วนตัว
- ✅ สามารถแชร์ได้
- ✅ Import ได้หลายเครื่อง

## 📊 ขนาดไฟล์

### ประมาณการ

```
10 samples   = ~50 KB
50 samples   = ~250 KB
100 samples  = ~500 KB
500 samples  = ~2.5 MB
1000 samples = ~5 MB
```

### ปัจจัยที่มีผล

- จำนวนตัวอย่าง
- Embedding size (1280 floats)
- Metadata

## 🚀 Use Cases

### 1. Backup & Restore

```
Export → Save to cloud → Import when needed
```

### 2. Share with Team

```
Export → Share file → Team imports → Same model
```

### 3. Transfer Between Devices

```
Phone 1: Export → Transfer → Phone 2: Import
```

### 4. Version Control

```
Export v1.0 → Train more → Export v1.1 → Compare
```

### 5. Collaboration

```
Person A: 50 samples → Export
Person B: 50 samples → Export
Merge → 100 samples total
```

## 🔧 Technical Details

### Cross-Validation

```dart
for (final testSample in samples) {
  final trainSamples = samples.where((s) => s.id != testSample.id);
  final prediction = mlService.predict(testSample.embedding, trainSamples);
  
  if (prediction.label == testSample.label) {
    correct++;
  }
  total++;
}

accuracy = correct / total;
```

### Export Format

```dart
final data = {
  'version': version.toJson(),
  'stats': stats.toJson(),
  'samples': samples.map((s) => s.toJson()).toList(),
  'exported_at': DateTime.now().toIso8601String(),
};

final jsonString = JsonEncoder.withIndent('  ').convert(data);
```

### Import Validation

```dart
// Check version
if (data['version'] == null) throw Exception('Invalid format');

// Check samples
if (data['samples'] is! List) throw Exception('Invalid samples');

// Check embedding size
final firstSample = samples.first;
if (firstSample.embedding.length != expectedSize) {
  throw Exception('Embedding size mismatch');
}
```

## 📝 Best Practices

### Export

1. ✅ Export ก่อนลบข้อมูล
2. ✅ Export เป็นประจำ (backup)
3. ✅ ตั้งชื่อไฟล์ให้เข้าใจ
4. ✅ เก็บไฟล์ไว้หลายที่

### Import

1. ✅ ตรวจสอบข้อมูลก่อน import
2. ✅ Export ข้อมูลเดิมก่อน
3. ✅ ทดสอบหลัง import
4. ✅ ตรวจสอบความแม่นยำ

### Testing

1. ✅ ทดสอบเป็นประจำ
2. ✅ ทดสอบหลังเพิ่มข้อมูล
3. ✅ เปรียบเทียบผลลัพธ์
4. ✅ บันทึกผลการทดสอบ

## 🐛 Troubleshooting

### Error: Embedding size mismatch

**วิธีแก้:**
1. ลบข้อมูลเก่าทั้งหมด
2. เพิ่มข้อมูลใหม่
3. ทดสอบอีกครั้ง

### Error: Import failed

**วิธีแก้:**
1. ตรวจสอบรูปแบบไฟล์
2. ตรวจสอบ JSON syntax
3. ลองไฟล์อื่น

### Error: Export failed

**วิธีแก้:**
1. ตรวจสอบพื้นที่ว่าง
2. ตรวจสอบ permissions
3. ลองอีกครั้ง

---

**Version:** 1.0.0  
**Last Updated:** November 8, 2025  
**Status:** ✅ Production Ready
