/// Application constants
class AppConstants {
  // App Info
  static const String appName = 'MeatCut Scan';
  static const String appVersion = '0.1.0';

  // AI Model
  static const String modelPath = 'assets/models/MobileNet-v3-Large.tflite';
  static const int embeddingSize = 1280;
  static const int imageSize = 224;

  // k-NN
  static const int kNeighbors = 5;
  static const double confidenceThreshold = 0.6;

  // Storage Keys
  static const String samplesKey = 'training_samples';
  static const String modelVersionKey = 'model_version';

  // Meat Types - ประเภทหลัก
  static const List<String> meatCategories = [
    'เนื้อวัว',
    'เนื้อหมู',
    'เนื้อไก่',
    'เนื้อปลา',
    'อื่นๆ',
  ];

  // Meat Parts - ส่วนของเนื้อ
  static const Map<String, List<String>> meatParts = {
    'เนื้อวัว': [
      'สันนอก',
      'สันใน',
      'สันคอ',
      'สะโพก',
      'น่อง',
      'หน้าขา',
      'หน้าท้อง',
      'สันสะโพก',
    ],
    'เนื้อหมู': [
      'สันนอก',
      'สันใน',
      'สันคอ',
      'สะโพก',
      'น่อง',
      'หมูสามชั้น',
      'หมูบด',
    ],
    'เนื้อไก่': ['อกไก่', 'น่องไก่', 'ปีกไก่', 'สะโพกไก่', 'ไก่บด'],
    'เนื้อปลา': ['ปลาแซลมอน', 'ปลาทูน่า', 'ปลากะพง', 'ปลาหมึก'],
    'อื่นๆ': ['อื่นๆ'],
  };

  // Get all meat types (flat list)
  static List<String> get allMeatTypes {
    final types = <String>[];
    meatParts.forEach((category, parts) {
      types.addAll(parts);
    });
    return types;
  }
}
