import 'package:shirt_base/data/models/stage_status.dart';
import 'package:shirt_base/data/models/stage_type.dart';



class Stage {
  final int id;
  final String name;
  int currentCount;
  final int targetCount;
  StageStatus status;
  final String frontImage;
  final String backImage;
  final StageType type;

  String get frontImagePath => "assets/images/$frontImage";
  String get backImagePath => "assets/images/$backImage";

  Stage({
    required this.id,
    required this.name,
    this.currentCount = 0,
    this.targetCount = 1,
    this.status = StageStatus.locked,
    required this.frontImage,
    required this.backImage,
    required this.type,
  }) {
    _updateStatus();
  }

  void increment() {
    if (status != StageStatus.completed) {
      currentCount++;
      _updateStatus();
    }
  }

  void _updateStatus() {
    if (currentCount >= targetCount) {
      status = StageStatus.completed;
    } else if (currentCount > 0) {
      status = StageStatus.inProgress;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'currentCount': currentCount,
    'targetCount': targetCount,
    'status': status.index,
    'frontImage': frontImage,
    'backImage': backImage,
    'type': type.index,
  };

  factory Stage.fromJson(Map<String, dynamic> json) => Stage(
    id: json['id'],
    name: json['name'],
    currentCount: json['currentCount'],
    targetCount: json['targetCount'],
    status: StageStatus.values[json['status']],
    frontImage: json['frontImage'],
    backImage: json['backImage'],
    type: StageType.values[json['type']],
  );
}