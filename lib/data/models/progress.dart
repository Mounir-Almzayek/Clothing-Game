import 'package:shirt_base/data/models/stage.dart';
import 'package:shirt_base/data/models/stage_status.dart';
import 'package:shirt_base/data/models/stage_type.dart';

/// Tracks a user's progress through ordered stages
class Progress {
  final List<Stage> stages;

  Progress({required this.stages}) {
    _ensureStageUnlocking();
  }

  factory Progress.withDefaultStages() {
    return Progress(stages: defaultStages());
  }

  static List<Stage> defaultStages() {
    return [
      Stage(id: 1, name: 'Stage 1', targetCount: 3, frontImage: 'shirt_forground_image.png', backImage: 'shirt_background_image.png', type: StageType.shirt),
      Stage(id: 2, name: 'Stage 2', targetCount: 5, frontImage: 'sweater_forground_image.png', backImage: 'sweater_background_image.png', type: StageType.shirt),
      Stage(id: 3, name: 'Stage 3', targetCount: 7, frontImage: 'pants_forground_image.png', backImage: 'pants_background_image.png', type: StageType.pants),
    ];
  }

  void completeStage(int stageId) {
    final idx = stages.indexWhere((s) => s.id == stageId);
    if (idx >= 0 && stages[idx].status != StageStatus.completed) {
      final stg = stages[idx];
      while (stg.currentCount < stg.targetCount) {
        stg.increment();
      }
      _unlockNext(idx);
    }
  }

  void incrementStage(int stageId) {
    final stg = stages.firstWhere((s) => s.id == stageId);
    stg.increment();
    if (stg.status == StageStatus.completed) {
      final idx = stages.indexOf(stg);
      _unlockNext(idx);
    }
  }

  bool isStageLocked(int stageId) {
    final stage = stages.firstWhere((s) => s.id == stageId, orElse: () => Stage(id: -1, name: '', frontImage: '', backImage: '', type: StageType.shirt));
    return stage.status == StageStatus.locked;
  }

  int completedStagesCount() {
    return stages.where((s) => s.status == StageStatus.completed).length;
  }

  void _unlockNext(int idx) {
    if (idx + 1 < stages.length) {
      final next = stages[idx + 1];
      if (next.status == StageStatus.locked) {
        next.status = StageStatus.inProgress;
      }
    }
  }

  void _ensureStageUnlocking() {
    for (int i = 0; i < stages.length; i++) {
      final stage = stages[i];
      if (stage.status == StageStatus.completed) {
        _unlockNext(i);
      } else if (stage.status == StageStatus.locked && i == 0) {
        stage.status = StageStatus.inProgress;
        break;
      } else {
        break;
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'stages': stages.map((s) => s.toJson()).toList(),
  };

  factory Progress.fromJson(Map<String, dynamic> json) {
    final list = (json['stages'] as List)
        .map((e) => Stage.fromJson(e as Map<String, dynamic>))
        .toList();
    return Progress(stages: list);
  }
}