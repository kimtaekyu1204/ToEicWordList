/// ============================================================
/// Test Screen - 테스트 화면
/// ============================================================
/// 매일 단어 테스트 (100문제)
/// - 단어 → 뜻 맞추기
/// - 뜻 → 단어 맞추기
/// - 4지선다 객관식
/// - 하루 여러번 테스트 가능
/// - 중간 종료시에도 오답 저장
/// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  // 테스트 상태: 'select' | 'testing' | 'result'
  String _testState = 'select';
  
  // 테스트 유형: 'wordToMeaning' | 'meaningToWord'
  String _testType = 'wordToMeaning';
  
  // 테스트 문제 목록
  List<Word> _testWords = [];
  
  // 현재 문제 인덱스
  int _currentIndex = 0;
  
  // 현재 문제의 선택지들
  List<String> _choices = [];
  
  // 선택한 답 인덱스 (-1: 미선택)
  int _selectedIndex = -1;
  
  // 정답 인덱스
  int _correctIndex = 0;
  
  // 결과 표시 중 여부
  bool _showingResult = false;
  
  // 정답 수
  int _correctCount = 0;
  
  // 틀린 단어 목록 (이번 테스트에서)
  List<Word> _wrongWords = [];

  // 랜덤 생성기
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    switch (_testState) {
      case 'testing':
        return _buildTestingScreen(context);
      case 'result':
        return _buildResultScreen(context);
      default:
        return _buildSelectScreen(context);
    }
  }

  /// 테스트 유형 선택 화면
  Widget _buildSelectScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final totalWords = provider.allWords.length;
    final testCount = totalWords.clamp(0, 100); // 최대 100개

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Text(
            '단어 테스트',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '테스트 유형을 선택하세요',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 오늘의 정답률 미니 카드
          if (provider.todayTotalCount > 0)
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AccuracyPieChart(
                    accuracy: provider.todayAccuracy,
                    size: 60,
                    strokeWidth: 8,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '오늘의 정답률',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.todayTestCount}회 테스트 완료',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 16),
          
          // 테스트 정보 카드
          GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 48,
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                ),
                const SizedBox(height: 12),
                Text(
                  '단어 테스트',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$testCount문제 • 4지선다 객관식 • 랜덤 출제',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 단어 → 뜻 테스트
          GlassCard(
            onTap: () => _startTest('wordToMeaning', provider.allWords),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkAccent : AppColors.lightAccentDark)
                        .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.translate,
                    size: 28,
                    color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '단어 → 뜻',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '영어 단어를 보고 뜻 맞추기',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 뜻 → 단어 테스트
          GlassCard(
            onTap: () => _startTest('meaningToWord', provider.allWords),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.correct.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.spellcheck,
                    size: 28,
                    color: AppColors.correct,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '뜻 → 단어',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '한국어 뜻을 보고 단어 맞추기',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: AppColors.correct,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 테스트 진행 화면
  Widget _buildTestingScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_testWords.isEmpty) {
      return const Center(child: Text('테스트할 단어가 없습니다.'));
    }
    
    final currentWord = _testWords[_currentIndex];
    final question = _testType == 'wordToMeaning'
        ? currentWord.word
        : currentWord.meaning;
    
    return Column(
      children: [
        // 상단 바: 진행률
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GlassIconButton(
                icon: Icons.close,
                onTap: _confirmExit,
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_currentIndex + 1} / ${_testWords.length}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '✓ $_correctCount',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.correct,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '✗ ${_wrongWords.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.wrong,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / _testWords.length,
                      backgroundColor: (isDark
                              ? AppColors.darkAccent
                              : AppColors.lightAccent)
                          .withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation(
                        isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // 문제 카드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GlassCard(
            child: Column(
              children: [
                Text(
                  _testType == 'wordToMeaning' ? '다음 단어의 뜻은?' : '다음 뜻에 해당하는 단어는?',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  question,
                  style: TextStyle(
                    fontSize: _testType == 'wordToMeaning' ? 32 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // 선택지들
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _choices.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildChoiceButton(context, index, isDark);
            },
          ),
        ),
        
        // 다음 버튼 (결과 표시 중일 때만)
        if (_showingResult)
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: GlassButton(
                text: _currentIndex < _testWords.length - 1 ? '다음 문제' : '결과 보기',
                icon: _currentIndex < _testWords.length - 1
                    ? Icons.arrow_forward
                    : Icons.assessment,
                onTap: _nextQuestion,
              ),
            ),
          ),
      ],
    );
  }

  /// 선택지 버튼 빌드
  Widget _buildChoiceButton(BuildContext context, int index, bool isDark) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    
    if (_showingResult) {
      if (index == _correctIndex) {
        // 정답
        bgColor = AppColors.correct.withValues(alpha: 0.2);
        borderColor = AppColors.correct;
        textColor = AppColors.correct;
      } else if (index == _selectedIndex && index != _correctIndex) {
        // 오답 선택
        bgColor = AppColors.wrong.withValues(alpha: 0.2);
        borderColor = AppColors.wrong;
        textColor = AppColors.wrong;
      } else {
        // 기본
        bgColor = isDark
            ? AppColors.darkCardBg.withValues(alpha: 0.5)
            : AppColors.lightCardBg.withValues(alpha: 0.5);
        borderColor = Colors.transparent;
        textColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
      }
    } else {
      // 선택 전
      bgColor = isDark
          ? AppColors.darkCardBg.withValues(alpha: 0.7)
          : AppColors.lightCardBg.withValues(alpha: 0.8);
      borderColor = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.white.withValues(alpha: 0.5);
      textColor = isDark
          ? AppColors.darkTextPrimary
          : AppColors.lightTextPrimary;
    }
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showingResult ? null : () => _selectAnswer(index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: _showingResult && (index == _correctIndex || index == _selectedIndex)
                  ? 2
                  : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                      .withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // A, B, C, D
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _choices[index],
                  style: TextStyle(
                    fontSize: 15,
                    color: textColor,
                    fontWeight: _showingResult && index == _correctIndex
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              ),
              if (_showingResult && index == _correctIndex)
                const Icon(Icons.check_circle, color: AppColors.correct, size: 22),
              if (_showingResult && index == _selectedIndex && index != _correctIndex)
                const Icon(Icons.cancel, color: AppColors.wrong, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  /// 결과 화면
  Widget _buildResultScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accuracy = (_correctCount / _testWords.length * 100);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // 결과 카드 (원형 차트 포함)
          GlassCard(
            child: Column(
              children: [
                Icon(
                  accuracy >= 80
                      ? Icons.emoji_events
                      : accuracy >= 50
                          ? Icons.thumb_up
                          : Icons.sentiment_satisfied,
                  size: 48,
                  color: accuracy >= 80
                      ? Colors.amber
                      : AppColors.correct,
                ),
                const SizedBox(height: 16),
                Text(
                  '테스트 완료!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 24),
                AccuracyPieChart(
                  accuracy: accuracy,
                  size: 140,
                  strokeWidth: 14,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildResultStat('정답', '$_correctCount', AppColors.correct, isDark),
                    _buildResultStat(
                      '오답',
                      '${_testWords.length - _correctCount}',
                      AppColors.wrong,
                      isDark,
                    ),
                    _buildResultStat('총 문제', '${_testWords.length}', 
                      isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 틀린 단어 목록 (있을 경우)
          if (_wrongWords.isNotEmpty) ...[
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.wrong,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '틀린 단어 (${_wrongWords.length}개)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...List.generate(
              _wrongWords.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MiniWordCard(word: _wrongWords[index]),
              ),
            ),
          ],
          
          const SizedBox(height: 24),
          
          // 버튼들
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  text: '다시 테스트',
                  icon: Icons.refresh,
                  onTap: () => setState(() => _testState = 'select'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  text: '확인',
                  icon: Icons.check,
                  onTap: () => setState(() => _testState = 'select'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 결과 통계 위젯
  Widget _buildResultStat(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  /// 테스트 시작
  void _startTest(String type, List<Word> allWords) {
    final testCount = allWords.length.clamp(0, 100); // 최대 100개
    
    // 랜덤으로 단어 선택 (매번 다르게)
    final shuffled = List<Word>.from(allWords)..shuffle(_random);
    _testWords = shuffled.take(testCount).toList();
    
    setState(() {
      _testState = 'testing';
      _testType = type;
      _currentIndex = 0;
      _correctCount = 0;
      _wrongWords = [];
      _selectedIndex = -1;
      _showingResult = false;
    });
    
    _generateChoices();
  }

  /// 선택지 생성 (정답 1개 + 랜덤 오답 3개)
  void _generateChoices() {
    final currentWord = _testWords[_currentIndex];
    final provider = context.read<AppProvider>();
    final allWords = provider.allWords;
    
    // 정답
    final correctAnswer = _testType == 'wordToMeaning'
        ? currentWord.meaning
        : currentWord.word;
    
    // 오답 3개 생성 (정답과 다른 것들, 랜덤)
    final wrongAnswers = <String>[];
    final shuffledWords = List<Word>.from(allWords)..shuffle(_random);
    
    for (final word in shuffledWords) {
      if (wrongAnswers.length >= 3) break;
      
      final answer = _testType == 'wordToMeaning' ? word.meaning : word.word;
      if (answer != correctAnswer && !wrongAnswers.contains(answer)) {
        wrongAnswers.add(answer);
      }
    }
    
    // 선택지 섞기 (매번 다른 순서)
    _choices = [correctAnswer, ...wrongAnswers]..shuffle(_random);
    _correctIndex = _choices.indexOf(correctAnswer);
    
    setState(() {});
  }

  /// 답 선택
  void _selectAnswer(int index) {
    if (_showingResult) return;
    
    final isCorrect = index == _correctIndex;
    final currentWord = _testWords[_currentIndex];
    
    setState(() {
      _selectedIndex = index;
      _showingResult = true;
      
      if (isCorrect) {
        _correctCount++;
      } else {
        // 오답 추가 (중복 체크)
        if (!_wrongWords.any((w) => w.word == currentWord.word)) {
          _wrongWords.add(currentWord);
        }
        // 즉시 오답 저장 (중간 종료 대비)
        _saveWrongAnswersImmediately();
      }
    });
  }

  /// 오답 즉시 저장 (중간 종료 대비)
  void _saveWrongAnswersImmediately() {
    if (_wrongWords.isNotEmpty) {
      context.read<AppProvider>().addTodayWrongAnswers(_wrongWords);
    }
  }

  /// 다음 문제
  void _nextQuestion() {
    if (_currentIndex < _testWords.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedIndex = -1;
        _showingResult = false;
      });
      _generateChoices();
    } else {
      // 테스트 완료
      _finishTest();
    }
  }

  /// 테스트 완료
  void _finishTest() {
    final provider = context.read<AppProvider>();
    final now = DateTime.now();
    
    // 결과 저장
    final result = TestResult(
      date: now.toString().split(' ')[0],
      totalQuestions: _testWords.length,
      correctAnswers: _correctCount,
      wrongWords: _wrongWords.map((w) => w.word).toList(),
      testType: _testType,
      completedAt: now.toIso8601String(),
    );
    
    provider.saveTestResult(result);
    
    // 오답 저장 (중복 제거하며 추가)
    if (_wrongWords.isNotEmpty) {
      provider.addTodayWrongAnswers(_wrongWords);
    }
    
    setState(() {
      _testState = 'result';
    });
  }

  /// 종료 확인 (중간 종료시 오답 저장)
  void _confirmExit() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '테스트 종료',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          _wrongWords.isEmpty
              ? '정말 테스트를 종료하시겠습니까?'
              : '테스트를 종료하시겠습니까?\n틀린 단어 ${_wrongWords.length}개는 오답 노트에 저장됩니다.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '계속하기',
              style: TextStyle(
                color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // 중간 종료시에도 오답 저장
              if (_wrongWords.isNotEmpty) {
                context.read<AppProvider>().addTodayWrongAnswers(_wrongWords);
              }
              setState(() => _testState = 'select');
            },
            child: const Text(
              '종료',
              style: TextStyle(color: AppColors.wrong),
            ),
          ),
        ],
      ),
    );
  }
}
