/// Represents a single stage with progress count and lock status
enum StageStatus { locked, inProgress, completed }

extension StageStatusName on StageStatus {
  String get label {
    switch (this) {
      case StageStatus.locked: return 'مغلق';
      case StageStatus.inProgress: return 'قيد التقدم';
      case StageStatus.completed: return 'مكتمل';
    }
  }
}