# Contributing to MeatCut Scan

ขอบคุณที่สนใจมีส่วนร่วมในโปรเจกต์!

## การเริ่มต้น

1. Fork repository
2. Clone fork ของคุณ
3. สร้าง branch ใหม่: `git checkout -b feature/your-feature`
4. ทำการเปลี่ยนแปลง
5. Commit: `git commit -m "Add your feature"`
6. Push: `git push origin feature/your-feature`
7. สร้าง Pull Request

## Code Style

- ใช้ `flutter format` ก่อน commit
- ใช้ `flutter analyze` เพื่อตรวจสอบ warnings
- ตั้งชื่อตัวแปรและฟังก์ชันให้ชัดเจน
- เขียน comments สำหรับ logic ที่ซับซ้อน

## Commit Messages

- ใช้ present tense ("Add feature" ไม่ใช่ "Added feature")
- เริ่มด้วย verb (Add, Fix, Update, Remove)
- ให้รายละเอียดที่เพียงพอ

ตัวอย่าง:
- `Add image upload feature`
- `Fix k-NN classification bug`
- `Update UI theme colors`

## Pull Request Process

1. อัปเดต README.md หากมีการเปลี่ยนแปลง API
2. อัปเดต TODO.md หากเสร็จสิ้นงาน
3. ตรวจสอบว่าไม่มี merge conflicts
4. รอการ review จาก maintainers

## การรายงาน Bugs

เปิด issue ใหม่พร้อมข้อมูล:
- คำอธิบายปัญหา
- ขั้นตอนการทำซ้ำ
- ผลลัพธ์ที่คาดหวัง
- ผลลัพธ์จริง
- Screenshots (ถ้ามี)
- Environment (OS, Flutter version)

## การขอ Features

เปิด issue ใหม่พร้อมข้อมูล:
- คำอธิบาย feature
- Use case
- ตัวอย่างการใช้งาน
- Mockups (ถ้ามี)
