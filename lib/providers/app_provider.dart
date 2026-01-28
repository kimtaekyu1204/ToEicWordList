/// ============================================================
/// App Provider - 앱 상태 관리 프로바이더
/// ============================================================
/// 전역 상태 관리:
/// - 테마 모드 (라이트/다크)
/// - 단어 데이터
/// - 테스트 상태
/// - 오답 노트
/// - 나만의 단어장
/// ============================================================

import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService.instance;

  // ============================================================
  // 테마 상태
  // ============================================================
  
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  /// 테마 모드 토글
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _storage.setThemeMode(_isDarkMode);
    notifyListeners();
  }

  /// 테마 모드 설정
  Future<void> setThemeMode(bool isDark) async {
    _isDarkMode = isDark;
    await _storage.setThemeMode(isDark);
    notifyListeners();
  }

  // ============================================================
  // 단어 데이터 상태
  // ============================================================
  
  List<Word> _baseWords = [];      // 기본 단어장 (앱 내장)
  List<Word> _customWords = [];    // 사용자 정의 단어장
  
  /// 전체 단어 (기본 + 사용자 정의)
  List<Word> get allWords => [..._baseWords, ..._customWords];
  
  /// 기본 단어만
  List<Word> get baseWords => _baseWords;
  
  /// 사용자 정의 단어만
  List<Word> get customWords => _customWords;
  
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  /// 단어 데이터 로드 (기본 + 사용자 정의)
  Future<void> loadWords() async {
    _isLoading = true;
    notifyListeners();

    _baseWords = await _storage.loadVocabularyFromAsset();
    _customWords = await _storage.loadCustomWords();
    
    _isLoading = false;
    notifyListeners();
  }

  /// 랜덤 단어 목록 반환 (테스트용)
  List<Word> getRandomWords(int count) {
    if (allWords.isEmpty) return [];
    
    final shuffled = List<Word>.from(allWords)..shuffle();
    return shuffled.take(count.clamp(0, allWords.length)).toList();
  }

  // ============================================================
  // 오늘의 오답 상태
  // ============================================================
  
  List<Word> _todayWrongAnswers = [];
  List<Word> get todayWrongAnswers => _todayWrongAnswers;

  /// 오늘의 오답 로드
  Future<void> loadTodayWrongAnswers() async {
    _todayWrongAnswers = await _storage.loadTodayWrongAnswers();
    notifyListeners();
  }

  /// 오늘의 오답에 추가 (중복 제거)
  Future<void> addTodayWrongAnswers(List<Word> wrongWords) async {
    await _storage.addTodayWrongAnswers(wrongWords);
    _todayWrongAnswers = await _storage.loadTodayWrongAnswers();
    notifyListeners();
  }

  /// 오늘의 오답 저장 (전체 덮어쓰기)
  Future<void> saveTodayWrongAnswers(List<Word> wrongWords) async {
    _todayWrongAnswers = wrongWords;
    await _storage.saveTodayWrongAnswers(wrongWords);
    notifyListeners();
  }

  // ============================================================
  // 나만의 단어장 상태
  // ============================================================
  
  List<Word> _savedWords = [];
  List<Word> get savedWords => _savedWords;

  /// 나만의 단어장 로드
  Future<void> loadSavedWords() async {
    _savedWords = await _storage.loadSavedWords();
    notifyListeners();
  }

  /// 단어 저장 토글
  Future<void> toggleSaveWord(Word word) async {
    final isCurrentlySaved = _savedWords.any((w) => w.word == word.word);
    
    if (isCurrentlySaved) {
      await _storage.removeFromSavedWords(word.word);
      _savedWords.removeWhere((w) => w.word == word.word);
    } else {
      await _storage.addToSavedWords(word);
      _savedWords.add(word);
    }
    
    notifyListeners();
  }

  /// 단어가 저장되어 있는지 확인
  bool isWordSaved(String wordText) {
    return _savedWords.any((w) => w.word == wordText);
  }

  // ============================================================
  // 테스트 결과 상태
  // ============================================================
  
  List<TestResult> _testResults = [];
  List<TestResult> get testResults => _testResults;

  /// 테스트 결과 로드
  Future<void> loadTestResults() async {
    _testResults = await _storage.loadTestResults();
    notifyListeners();
  }

  /// 테스트 결과 저장
  Future<void> saveTestResult(TestResult result) async {
    await _storage.saveTestResult(result);
    _testResults.add(result);
    notifyListeners();
  }

  /// 오늘 테스트 완료 여부 (최소 1회)
  bool get isTodayTestCompleted => _storage.isTodayTestCompleted();

  // ============================================================
  // 일일 통계 관련
  // ============================================================

  /// 오늘 테스트 횟수
  int get todayTestCount => _storage.getTodayTestCount();

  /// 오늘 정답 수
  int get todayCorrectCount => _storage.getTodayCorrectCount();

  /// 오늘 전체 문제 수
  int get todayTotalCount => _storage.getTodayTotalCount();

  /// 오늘 정답률 (퍼센트)
  double get todayAccuracy => _storage.getTodayAccuracy();

  // ============================================================
  // 사용자 정의 단어장 관련
  // ============================================================

  /// 사용자 정의 단어 추가
  Future<bool> addCustomWord(Word word) async {
    // 중복 체크 (기본 + 사용자 정의 모두)
    if (allWords.any((w) => w.word.toLowerCase() == word.word.toLowerCase())) {
      return false; // 중복
    }
    
    await _storage.addCustomWord(word);
    _customWords = await _storage.loadCustomWords();
    notifyListeners();
    return true;
  }

  /// 사용자 정의 단어 수정
  Future<void> updateCustomWord(String oldWord, Word newWord) async {
    await _storage.updateCustomWord(oldWord, newWord);
    _customWords = await _storage.loadCustomWords();
    notifyListeners();
  }

  /// 사용자 정의 단어 삭제
  Future<void> removeCustomWord(String wordText) async {
    await _storage.removeCustomWord(wordText);
    _customWords = await _storage.loadCustomWords();
    notifyListeners();
  }

  /// 사용자 정의 단어인지 확인
  bool isCustomWord(String wordText) {
    return _customWords.any((w) => w.word == wordText);
  }

  // ============================================================
  // 초기화
  // ============================================================

  /// 모든 데이터 초기화 및 로드
  Future<void> initialize() async {
    await _storage.initialize();
    
    // 테마 모드 로드
    _isDarkMode = _storage.getThemeMode();
    
    // 단어 데이터 로드 (기본 + 사용자 정의)
    await loadWords();
    
    // 오답 및 저장 단어 로드
    await loadTodayWrongAnswers();
    await loadSavedWords();
    await loadTestResults();
    
    // 오래된 데이터 정리
    await _storage.cleanOldWrongAnswers();
    
    notifyListeners();
  }
}
