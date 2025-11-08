# TensorFlow Lite Models

วางไฟล์โมเดล TensorFlow Lite ไว้ที่นี่

## โมเดลที่ต้องการ

- `mobilenet_v3.tflite` - MobileNetV3 สำหรับ feature extraction

## วิธีการดาวน์โหลดโมเดล

1. ดาวน์โหลด MobileNetV3 จาก TensorFlow Hub หรือ TensorFlow Lite Model Maker
2. หรือใช้โมเดลที่เทรนเอง
3. วางไฟล์ `.tflite` ไว้ในโฟลเดอร์นี้

## ตัวอย่างการใช้งาน

```dart
final interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v3.tflite');
```
