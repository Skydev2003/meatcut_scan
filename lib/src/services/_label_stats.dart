/// Helper class to track label statistics for confidence calculation
class LabelStats {
  int count = 0;
  double totalDistance = 0;

  void addSample(double distance) {
    count++;
    totalDistance += distance;
  }

  double get averageDistance => totalDistance / count;
}
