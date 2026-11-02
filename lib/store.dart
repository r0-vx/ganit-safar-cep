import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'content.dart';

class AppStore extends ChangeNotifier {
  late SharedPreferences prefs;
  int language = 2, grade = 1, stars = 0;
  bool sound = true, contrast = false, largeText = false, slow = false;
  double speed = 1;
  bool sidebarOpen = true, reducedMotion = false;
  bool smartboard = true;
  List<String> completedChapters = [];
  Map<String, dynamic> practiceDraft = {};
  String profile = 'Classroom';
  Map<String, dynamic> profiles = {}, quizSettings = {};
  List<dynamic> completed = [], results = [], custom = [], archives = [];
  String pinHash = digest('1234');
  static String digest(String pin) =>
      sha256.convert(utf8.encode('ganit-safar-local:$pin')).toString();
  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('ganit_safar_v1');
    if (raw != null) {
      try {
        decode(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {}
    }
  }

  Map<String, dynamic> progressData() => {
    'completed': completed,
    'results': results,
    'stars': stars,
    'completedChapters': completedChapters,
  };
  void loadProgress(Map p) {
    completed = List.of(p['completed'] ?? []);
    results = List.of(p['results'] ?? []);
    stars = (p['stars'] as num?)?.toInt() ?? 0;
    completedChapters = List<String>.from(p['completedChapters'] ?? []);
  }

  Map<String, dynamic> encode() => {
    'version': 1,
    'extensionSchemaVersion': 4,
    'sidebarOpen': sidebarOpen,
    'reducedMotion': reducedMotion,
    'smartboard': smartboard,
    'practiceDraft': practiceDraft,
    'language': language,
    'grade': grade,
    'sound': sound,
    'contrast': contrast,
    'largeText': largeText,
    'slow': slow,
    'speed': speed,
    'profile': profile,
    'profiles': profiles,
    'progress': progressData(),
    'custom': [
      for (final quiz in custom)
        {
          ...Map<String, dynamic>.from(quiz),
          'questions': [
            for (final question in quiz['questions'])
              normalizeCustomQuestion(Map<String, dynamic>.from(question)),
          ],
        },
    ],
    'archives': archives,
    'pinHash': pinHash,
    'quizSettings': quizSettings,
  };

  /// Portable learning files must not carry a teacher credential verifier.
  Map<String, dynamic> learningBackup() => encode()..remove('pinHash');

  void restoreLearningBackup(Map<String, dynamic> data) {
    decode({...data, 'pinHash': pinHash});
  }

  void decode(Map<String, dynamic> m) {
    if (m['version'] != 1 || m['progress'] is! Map || m['custom'] is! List) {
      throw const FormatException('Invalid Ganit Safar backup');
    }
    validateBackup(m);
    sidebarOpen = m['sidebarOpen'] != false;
    reducedMotion = m['reducedMotion'] == true;
    smartboard = m['smartboard'] != false;
    practiceDraft = m['practiceDraft'] is Map
        ? Map<String, dynamic>.from(m['practiceDraft'])
        : {};
    quizSettings = Map<String, dynamic>.from(m['quizSettings'] ?? {});
    language = ((m['language'] as num?)?.toInt() ?? 2).clamp(0, 2);
    grade = ((m['grade'] as num?)?.toInt() ?? 1).clamp(1, 4);
    sound = m['sound'] == true;
    contrast = m['contrast'] == true;
    largeText = m['largeText'] == true;
    slow = m['slow'] == true;
    speed = ((m['speed'] as num?)?.toDouble() ?? 1).clamp(.5, 2);
    profile = m['profile']?.toString() ?? 'Classroom';
    profiles = Map<String, dynamic>.from(m['profiles'] ?? {});
    loadProgress(m['progress'] as Map);
    custom = [
      for (final quiz in m['custom'])
        {
          ...Map<String, dynamic>.from(quiz),
          'questions': [
            for (final question in quiz['questions'])
              normalizeCustomQuestion(Map<String, dynamic>.from(question)),
          ],
        },
    ];
    archives = List.of(m['archives'] ?? []);
    pinHash = m['pinHash']?.toString() ?? digest('1234');
  }

  static void validateBackup(Map<String, dynamic> m) {
    final ids = topics.map((t) => t.id).toSet();
    void progress(dynamic p) {
      if (p is! Map ||
          p['completed'] is! List ||
          p['results'] is! List ||
          p['stars'] is! int ||
          (p['stars'] as int) < 0)
        throw const FormatException('Invalid progress');
      for (final v in p['completed']) {
        if (v is! String ||
            !RegExp(r'^[1-4]:[a-z]+$').hasMatch(v) ||
            !ids.contains(v.split(':').last))
          throw const FormatException('Invalid lesson');
      }
      if (p['completedChapters'] != null) {
        if (p['completedChapters'] is! List) {
          throw const FormatException('Invalid chapter progress');
        }
        const counts = {1: 29, 2: 22, 3: 14, 4: 14};
        for (final id in p['completedChapters']) {
          final match = id is String
              ? RegExp(r'^G([1-4])-C(\d{2})$').firstMatch(id)
              : null;
          if (match == null ||
              int.parse(match[2]!) < 1 ||
              int.parse(match[2]!) > counts[int.parse(match[1]!)]!) {
            throw const FormatException('Invalid chapter progress');
          }
        }
      }
      for (final r in p['results']) {
        if (r is! Map ||
            !ids.contains(r['topic']) ||
            r['grade'] is! int ||
            r['grade'] < 1 ||
            r['grade'] > 4 ||
            r['correct'] is! int ||
            r['total'] is! int ||
            r['total'] <= 0 ||
            r['correct'] < 0 ||
            r['correct'] > r['total'] ||
            r['date'] is! String ||
            DateTime.tryParse(r['date']) == null ||
            r['mistakes'] is! List)
          throw const FormatException('Invalid results');
      }
    }

    progress(m['progress']);
    if (m['profiles'] is! Map || m['archives'] is! List)
      throw const FormatException('Invalid profiles');
    for (final p in (m['profiles'] as Map).values) {
      progress(p);
    }
    for (final a in m['archives']) {
      progress(a);
    }
    for (final quiz in m['custom']) {
      if (quiz is! Map ||
          quiz['name'] is! String ||
          !ids.contains(quiz['topic']) ||
          quiz['grade'] is! int ||
          quiz['grade'] < 1 ||
          quiz['grade'] > 4 ||
          quiz['questions'] is! List ||
          (quiz['questions'] as List).isEmpty)
        throw const FormatException('Invalid quiz');
      for (final q in quiz['questions']) {
        if (q is! Map ||
            q['en'] is! String ||
            q['mr'] is! String ||
            q['hintEn'] is! String ||
            q['hintMr'] is! String ||
            q['answer'] is! int ||
            q['answer'] < 0)
          throw const FormatException('Invalid question');
        normalizeCustomQuestion(Map<String, dynamic>.from(q));
      }
    }
  }

  Future<void> save() async {
    await prefs.setString('ganit_safar_v1', jsonEncode(encode()));
    notifyListeners();
  }

  Future<void> switchProfile(String name) async {
    profiles[profile] = progressData();
    profile = name;
    loadProgress(Map.from(profiles[name] ?? {}));
    await save();
  }

  bool isDone(String topic) => completed.contains('$grade:$topic');
  bool isChapterDone(String id) => completedChapters.contains(id);
  void completeChapter(String id) {
    if (!completedChapters.contains(id)) {
      completedChapters.add(id);
      stars += 3;
      save();
    }
  }

  void complete(String topic) {
    final key = '$grade:$topic';
    if (!completed.contains(key)) {
      completed.add(key);
      stars += 3;
    }
    save();
  }

  void record(
    String topic,
    int correct,
    int total,
    List<Map<String, dynamic>> mistakes,
  ) {
    stars += correct;
    results.add({
      'topic': topic,
      'grade': grade,
      'correct': correct,
      'total': total,
      'mistakes': mistakes,
      'date': DateTime.now().toIso8601String(),
    });
    save();
  }

  void reset({bool archive = true}) {
    if (archive) {
      archives.add({
        'profile': profile,
        'date': DateTime.now().toIso8601String(),
        ...progressData(),
      });
    }
    completed = [];
    completedChapters = [];
    results = [];
    stars = 0;
    save();
  }
}
