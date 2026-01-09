/// ============================================================
/// Storage Service - 로컬 저장소 서비스
/// ============================================================
/// Hive와 SharedPreferences를 사용한 로컬 데이터 저장
/// - 단어장 데이터 로드/저장
/// - 테스트 결과 저장
/// - 오답 노트 관리
/// - 나만의 단어장 관리
/// - 설정 저장
/// ============================================================

import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class StorageService {
  static StorageService? _instance;
  static StorageService get instance => _instance ??= StorageService._();
  
  StorageService._();

  // Hive Box 이름 상수
  static const String _vocabularyBox = 'vocabulary';
  static const String _testResultsBox = 'test_results';
  static const String _wrongAnswersBox = 'wrong_answers';
  static const String _savedWordsBox = 'saved_words';
  
  // SharedPreferences 키 상수
  static const String _themeModeKey = 'theme_mode';
  static const String _lastTestDateKey = 'last_test_date';
  static const String _todayTestCountKey = 'today_test_count';
  static const String _todayCorrectCountKey = 'today_correct_count';
  static const String _todayTotalCountKey = 'today_total_count';
  
  late SharedPreferences _prefs;
  
  /// 서비스 초기화
  Future<void> initialize() async {
    // Hive 초기화
    await Hive.initFlutter();
    
    // Box 열기
    await Hive.openBox<String>(_vocabularyBox);
    await Hive.openBox<String>(_testResultsBox);
    await Hive.openBox<String>(_wrongAnswersBox);
    await Hive.openBox<String>(_savedWordsBox);
    
    // SharedPreferences 초기화
    _prefs = await SharedPreferences.getInstance();
    
    // 날짜가 바뀌면 일일 카운트 리셋
    _resetDailyCountsIfNewDay();
  }

  /// 날짜가 바뀌면 일일 카운트 리셋
  void _resetDailyCountsIfNewDay() {
    final lastDate = _prefs.getString(_lastTestDateKey);
    final today = DateTime.now().toString().split(' ')[0];
    
    if (lastDate != today) {
      _prefs.setInt(_todayTestCountKey, 0);
      _prefs.setInt(_todayCorrectCountKey, 0);
      _prefs.setInt(_todayTotalCountKey, 0);
    }
  }

  // ============================================================
  // 단어장 관련 메서드
  // ============================================================

  /// 에셋에서 단어장 로드
  Future<List<Word>> loadVocabularyFromAsset() async {
    try {
      final String jsonString = 
          await rootBundle.loadString('assets/data/vocabulary.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> vocabulary = data['vocabulary'] as List<dynamic>;
      
      return vocabulary
          .map((item) => Word.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 단어장 데이터 저장 (추가 단어장용)
  Future<void> saveVocabulary(String key, List<Word> words) async {
    final box = Hive.box<String>(_vocabularyBox);
    final jsonList = words.map((w) => w.toJson()).toList();
    await box.put(key, json.encode(jsonList));
  }

  /// 저장된 단어장 로드
  Future<List<Word>> loadSavedVocabulary(String key) async {
    final box = Hive.box<String>(_vocabularyBox);
    final data = box.get(key);
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    return jsonList
        .map((item) => Word.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // ============================================================
  // 테스트 결과 관련 메서드
  // ============================================================

  /// 테스트 결과 저장
  Future<void> saveTestResult(TestResult result) async {
    final box = Hive.box<String>(_testResultsBox);
    
    // 기존 결과 목록 로드
    List<TestResult> results = await loadTestResults();
    results.add(result);
    
    // 최근 100개 결과만 유지
    if (results.length > 100) {
      results = results.sublist(results.length - 100);
    }
    
    final jsonList = results.map((r) => r.toJson()).toList();
    await box.put('results', json.encode(jsonList));
    
    // 마지막 테스트 날짜 업데이트
    final today = DateTime.now().toString().split(' ')[0];
    await _prefs.setString(_lastTestDateKey, today);
    
    // 오늘 테스트 횟수 증가
    final currentCount = _prefs.getInt(_todayTestCountKey) ?? 0;
    await _prefs.setInt(_todayTestCountKey, currentCount + 1);
    
    // 오늘 정답/전체 수 업데이트
    final currentCorrect = _prefs.getInt(_todayCorrectCountKey) ?? 0;
    final currentTotal = _prefs.getInt(_todayTotalCountKey) ?? 0;
    await _prefs.setInt(_todayCorrectCountKey, currentCorrect + result.correctAnswers);
    await _prefs.setInt(_todayTotalCountKey, currentTotal + result.totalQuestions);
  }

  /// 테스트 결과 목록 로드
  Future<List<TestResult>> loadTestResults() async {
    final box = Hive.box<String>(_testResultsBox);
    final data = box.get('results');
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    return jsonList
        .map((item) => TestResult.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 오늘 테스트 완료 여부 확인 (최소 1회 이상)
  bool isTodayTestCompleted() {
    final lastDate = _prefs.getString(_lastTestDateKey);
    final today = DateTime.now().toString().split(' ')[0];
    return lastDate == today;
  }

  /// 오늘 테스트 횟수 조회
  int getTodayTestCount() {
    _resetDailyCountsIfNewDay();
    return _prefs.getInt(_todayTestCountKey) ?? 0;
  }

  /// 오늘 정답 수 조회
  int getTodayCorrectCount() {
    _resetDailyCountsIfNewDay();
    return _prefs.getInt(_todayCorrectCountKey) ?? 0;
  }

  /// 오늘 전체 문제 수 조회
  int getTodayTotalCount() {
    _resetDailyCountsIfNewDay();
    return _prefs.getInt(_todayTotalCountKey) ?? 0;
  }

  /// 오늘 정답률 조회 (퍼센트)
  double getTodayAccuracy() {
    final correct = getTodayCorrectCount();
    final total = getTodayTotalCount();
    if (total == 0) return 0;
    return (correct / total) * 100;
  }

  // ============================================================
  // 오답 노트 관련 메서드 (오늘의 오답)
  // ============================================================

  /// 오늘의 오답에 추가 (중복 제거)
  Future<void> addTodayWrongAnswers(List<Word> newWrongWords) async {
    final box = Hive.box<String>(_wrongAnswersBox);
    final today = DateTime.now().toString().split(' ')[0];
    
    // 기존 오답 로드
    List<Word> existingWrong = await loadTodayWrongAnswers();
    
    // 중복 제거하며 추가
    for (final word in newWrongWords) {
      if (!existingWrong.any((w) => w.word == word.word)) {
        existingWrong.add(word);
      }
    }
    
    final jsonList = existingWrong.map((w) => w.toJson()).toList();
    await box.put(today, json.encode(jsonList));
  }

  /// 오늘의 오답 저장 (전체 덮어쓰기)
  Future<void> saveTodayWrongAnswers(List<Word> wrongWords) async {
    final box = Hive.box<String>(_wrongAnswersBox);
    final today = DateTime.now().toString().split(' ')[0];
    
    final jsonList = wrongWords.map((w) => w.toJson()).toList();
    await box.put(today, json.encode(jsonList));
  }

  /// 오늘의 오답 로드
  Future<List<Word>> loadTodayWrongAnswers() async {
    final box = Hive.box<String>(_wrongAnswersBox);
    final today = DateTime.now().toString().split(' ')[0];
    final data = box.get(today);
    
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    return jsonList
        .map((item) => Word.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 오래된 오답 데이터 정리 (7일 이상)
  Future<void> cleanOldWrongAnswers() async {
    final box = Hive.box<String>(_wrongAnswersBox);
    final now = DateTime.now();
    
    final keysToDelete = <String>[];
    for (final key in box.keys) {
      try {
        final date = DateTime.parse(key as String);
        if (now.difference(date).inDays > 7) {
          keysToDelete.add(key);
        }
      } catch (_) {
        // 날짜 파싱 실패시 무시
      }
    }
    
    for (final key in keysToDelete) {
      await box.delete(key);
    }
  }

  // ============================================================
  // 나만의 단어장 관련 메서드
  // ============================================================

  /// 나만의 단어장에 단어 추가
  Future<void> addToSavedWords(Word word) async {
    final box = Hive.box<String>(_savedWordsBox);
    List<Word> savedWords = await loadSavedWords();
    
    // 중복 체크
    if (!savedWords.any((w) => w.word == word.word)) {
      savedWords.add(word);
      final jsonList = savedWords.map((w) => w.toJson()).toList();
      await box.put('saved', json.encode(jsonList));
    }
  }

  /// 나만의 단어장에서 단어 삭제
  Future<void> removeFromSavedWords(String wordText) async {
    final box = Hive.box<String>(_savedWordsBox);
    List<Word> savedWords = await loadSavedWords();
    
    savedWords.removeWhere((w) => w.word == wordText);
    final jsonList = savedWords.map((w) => w.toJson()).toList();
    await box.put('saved', json.encode(jsonList));
  }

  /// 나만의 단어장 로드
  Future<List<Word>> loadSavedWords() async {
    final box = Hive.box<String>(_savedWordsBox);
    final data = box.get('saved');
    
    if (data == null) return [];
    
    final List<dynamic> jsonList = json.decode(data);
    return jsonList
        .map((item) => Word.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// 단어가 저장되어 있는지 확인
  Future<bool> isWordSaved(String wordText) async {
    final savedWords = await loadSavedWords();
    return savedWords.any((w) => w.word == wordText);
  }

  // ============================================================
  // 설정 관련 메서드
  // ============================================================

  /// 테마 모드 저장 (true = 다크모드)
  Future<void> setThemeMode(bool isDark) async {
    await _prefs.setBool(_themeModeKey, isDark);
  }

  /// 테마 모드 로드
  bool getThemeMode() {
    return _prefs.getBool(_themeModeKey) ?? false;
  }
}
