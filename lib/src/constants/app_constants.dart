/// Application constants
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
