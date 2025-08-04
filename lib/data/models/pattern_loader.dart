import 'dart:convert';
import 'package:flutter/services.dart';

class PatternLoader {
  /// يرجع قائمة من الأنماط، كل نمط هو List<List<List<Map<String, dynamic>>>>>
  static Future<List<List<List<List<Map<String, dynamic>>>>>> loadShirtPatterns() async {
    final jsonStr = await rootBundle.loadString('assets/json/patterns_shirt.json');
    final doc = json.decode(jsonStr) as Map<String, dynamic>;
    final rawPatterns = doc['patterns'] as List<dynamic>;
    // كل نمط هو بنية متعدد الأبعاد من القوائم
    return rawPatterns.map((p) {
      return (p as List).map((row) {
        return (row as List).map((cell) {
          return (cell as List).map((seg) {
            return (seg as Map<String, dynamic>);
          }).toList();
        }).toList();
      }).toList();
    }).toList();
  }

  /// يرجع قائمة من الأنماط للبناطيل
  static Future<List<List<List<List<Map<String, dynamic>>>>>> loadPantsPatterns() async {
    final jsonStr = await rootBundle.loadString('assets/json/patterns_pants.json');
    final doc = json.decode(jsonStr) as Map<String, dynamic>;
    final rawPatterns = doc['patterns'] as List<dynamic>;
    // كل نمط هو بنية متعدد الأبعاد من القوائم
    return rawPatterns.map((p) {
      return (p as List).map((row) {
        return (row as List).map((cell) {
          return (cell as List).map((seg) {
            return (seg as Map<String, dynamic>);
          }).toList();
        }).toList();
      }).toList();
    }).toList();
  }
}

