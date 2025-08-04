import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

const _prefsKey = 'roster_list';

/// Repository for persisting roster list in SharedPreferences
class RosterRepository {
  static Future<List<User>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    final list = (json.decode(raw) as List)
        .map((e) => User.fromJson(e))
        .toList();
    return list;
  }

  static Future<void> saveAll(List<User> list) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = json.encode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_prefsKey, raw);
  }

  static Future<void> add(User item) async {
    final list = await loadAll();
    list.add(item);
    await saveAll(list);
  }

  static Future<void> update(User item) async {
    final list = await loadAll();
    final idx = list.indexWhere((r) => r.id == item.id);
    if (idx >= 0) {
      list[idx] = item;
      await saveAll(list);
    }
  }

  static Future<void> incrementStage(String userId, int stageId) async {
    final list = await loadAll();
    final user = list.firstWhere((r) => r.id == userId, orElse: () => throw Exception('User not found'));
    user.progress.incrementStage(stageId);
    await update(user);
  }

  static Future<void> completeStage(String userId, int stageId) async {
    final list = await loadAll();
    final user = list.firstWhere((r) => r.id == userId, orElse: () => throw Exception('User not found'));
    user.progress.completeStage(stageId);
    await update(user);
  }

  static Future<bool> isStageLocked(String userId, int stageId) async {
    final list = await loadAll();
    final user = list.firstWhere((r) => r.id == userId, orElse: () => throw Exception('User not found'));
    return user.progress.isStageLocked(stageId);
  }

  static Future<int> completedStars(String userId) async {
    final list = await loadAll();
    final user = list.firstWhere((r) => r.id == userId, orElse: () => throw Exception('User not found'));
    return user.progress.completedStagesCount();
  }


  static Future<void> delete(String id) async {
    final list = await loadAll();
    list.removeWhere((r) => r.id == id);
    await saveAll(list);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}