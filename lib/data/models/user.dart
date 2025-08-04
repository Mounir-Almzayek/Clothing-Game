import 'package:shirt_base/data/models/progress.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

/// Main user/roster model
class User {
  final String id;
  String name;
  Progress progress;

  User({
    String? id,
    required this.name,
    Progress? progress,
  })  : id = id ?? _uuid.v4(),
        progress = progress ?? Progress.withDefaultStages();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'progress': progress.toJson(),
  };

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'],
    name: json['name'],
    progress: Progress.fromJson(json['progress']),
  );
}
