/// ============================================================
/// Relay Screen - 만점 릴레이 모드 화면
/// ============================================================
/// 모든 단어를 맞출 때까지 무한 반복
/// - 틀리면 이후에 다시 출제
/// - 틀린 것 + 아직 안 나온 것 중 랜덤 출제
/// - 오답노트에 추가되지 않음
/// - 중단 가능
/// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class RelayScreen extends StatefulWidget {
  const RelayScreen({super.key});

  @override
  State<RelayScreen> createState() => _RelayScreenState();
}

class _RelayScreenState extends State<RelayScreen> {
  // 릴레이 상태: 'select' | 'playing' | 'complete'
  String _relayState = 'select';
  
  // 테스트 유형: 'wordToMeaning' | 'meaningToWord'
  String _testType = 'wordToMeaning';
  
  // 아직 맞추지 못한 단어들 (틀린 것 + 아직 안 나온 것)
  List<Word> _remainingWords = [];
  
  // 맞춘 단어들
  List<Word> _completedWords = [];
  
  // 현재 문제 단어
  Word? _currentWord;
  
  // 현재 문제의 선택지들
  List<String> _choices = [];
  
  // 선택한 답 인덱스 (-1: 미선택)
  int _selectedIndex = -1;
  
  // 정답 인덱스
  int _correctIndex = 0;
  
  // 결과 표시 중 여부
  bool _showingResult = false;
  
  // 전체 단어 수
  int _totalWords = 0;
  
  // 현재 라운드에서 틀린 횟수
  int _wrongCount = 0;
  
  // 전체 시도 횟수
  int _totalAttempts = 0;

  // 랜덤 생성기
  final Random _random = Random();

  @override
  Widget build(BuildContext context) {
    switch (_relayState) {
      case 'playing':
        return _buildPlayingScreen(context);
      case 'complete':
        return _buildCompleteScreen(context);
      default:
        return _buildSelectScreen(context);
    }
  }

  /// 테스트 유형 선택 화면
  Widget _buildSelectScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final totalWords = provider.allWords.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '만점 릴레이',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      '모든 단어를 맞출 때까지!',
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
            ],
          ),
          
          const SizedBox(height: 24),
          
          // 설명 카드
          GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '릴레이 모드 규칙',
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
                _buildRuleItem('🎯', '모든 단어($totalWords개)를 맞출 때까지 계속', isDark),
                _buildRuleItem('🔄', '틀린 단어는 다시 출제', isDark),
                _buildRuleItem('🎲', '틀린 것 + 아직 안 나온 것 중 랜덤', isDark),
                _buildRuleItem('📝', '오답노트에 추가되지 않음', isDark),
                _buildRuleItem('⏸️', '언제든 중단 가능', isDark),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 단어 → 뜻 릴레이
          GlassCard(
            onTap: () => _startRelay('wordToMeaning', provider.allWords),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.translate,
                    size: 28,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '단어 → 뜻 릴레이',
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
                const Icon(
                  Icons.play_arrow,
                  size: 28,
                  color: Colors.amber,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 뜻 → 단어 릴레이
          GlassCard(
            onTap: () => _startRelay('meaningToWord', provider.allWords),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.spellcheck,
                    size: 28,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '뜻 → 단어 릴레이',
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
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 규칙 아이템 위젯
  Widget _buildRuleItem(String emoji, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 릴레이 진행 화면
  Widget _buildPlayingScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_currentWord == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final question = _testType == 'wordToMeaning'
        ? _currentWord!.word
        : _currentWord!.meaning;
    
    final progress = _completedWords.length / _totalWords;

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
                          '${_completedWords.length} / $_totalWords',
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
                            const Icon(Icons.refresh, size: 14, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              '남은 $_remainingWordsCount개',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.amber.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.amber),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 통계
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip('시도', '$_totalAttempts', Colors.blue, isDark),
              const SizedBox(width: 12),
              _buildStatChip('틀림', '$_wrongCount', AppColors.wrong, isDark),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _testType == 'wordToMeaning' ? '다음 단어의 뜻은?' : '다음 뜻에 해당하는 단어는?',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
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
                text: '다음 문제',
                icon: Icons.arrow_forward,
                onTap: _nextQuestion,
                color: Colors.amber,
              ),
            ),
          ),
      ],
    );
  }

  /// 통계 칩 위젯
  Widget _buildStatChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// 남은 단어 수
  int get _remainingWordsCount => _remainingWords.length;

  /// 선택지 버튼 빌드
  Widget _buildChoiceButton(BuildContext context, int index, bool isDark) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    
    if (_showingResult) {
      if (index == _correctIndex) {
        bgColor = AppColors.correct.withValues(alpha: 0.2);
        borderColor = AppColors.correct;
        textColor = AppColors.correct;
      } else if (index == _selectedIndex && index != _correctIndex) {
        bgColor = AppColors.wrong.withValues(alpha: 0.2);
        borderColor = AppColors.wrong;
        textColor = AppColors.wrong;
      } else {
        bgColor = isDark
            ? AppColors.darkCardBg.withValues(alpha: 0.5)
            : AppColors.lightCardBg.withValues(alpha: 0.5);
        borderColor = Colors.transparent;
        textColor = isDark
            ? AppColors.darkTextSecondary
            : AppColors.lightTextSecondary;
      }
    } else {
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
                  color: Colors.amber.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index),
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

  /// 완료 화면
  Widget _buildCompleteScreen(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accuracy = _totalAttempts > 0 
        ? (_totalWords / _totalAttempts * 100) 
        : 100.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // 축하 카드
          GlassCard(
            child: Column(
              children: [
                const Icon(
                  Icons.celebration,
                  size: 64,
                  color: Colors.amber,
                ),
                const SizedBox(height: 16),
                Text(
                  '🎉 만점 달성! 🎉',
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
                  '모든 단어를 맞췄습니다!',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                
                // 결과 통계
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildResultStat('총 단어', '$_totalWords', Colors.amber, isDark),
                    _buildResultStat('총 시도', '$_totalAttempts', Colors.blue, isDark),
                    _buildResultStat('틀린 횟수', '$_wrongCount', AppColors.wrong, isDark),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // 효율성
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: (accuracy >= 80 ? AppColors.correct : Colors.amber)
                        .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        accuracy >= 80 ? Icons.star : Icons.trending_up,
                        color: accuracy >= 80 ? AppColors.correct : Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '효율성: ${accuracy.toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: accuracy >= 80 ? AppColors.correct : Colors.amber,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 버튼들
          Row(
            children: [
              Expanded(
                child: GlassButton(
                  text: '다시 도전',
                  icon: Icons.refresh,
                  onTap: () => setState(() => _relayState = 'select'),
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GlassButton(
                  text: '완료',
                  icon: Icons.check,
                  onTap: () => setState(() => _relayState = 'select'),
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

  /// 릴레이 시작
  void _startRelay(String type, List<Word> allWords) {
    _testType = type;
    _totalWords = allWords.length;
    _remainingWords = List.from(allWords)..shuffle(_random);
    _completedWords = [];
    _wrongCount = 0;
    _totalAttempts = 0;
    
    setState(() {
      _relayState = 'playing';
    });
    
    _loadNextQuestion();
  }

  /// 다음 문제 로드
  void _loadNextQuestion() {
    if (_remainingWords.isEmpty) {
      // 모든 단어 완료!
      setState(() {
        _relayState = 'complete';
      });
      return;
    }
    
    // 남은 단어 중 랜덤 선택
    _remainingWords.shuffle(_random);
    _currentWord = _remainingWords.first;
    
    _generateChoices();
    
    setState(() {
      _selectedIndex = -1;
      _showingResult = false;
    });
  }

  /// 선택지 생성
  void _generateChoices() {
    final provider = context.read<AppProvider>();
    final allWords = provider.allWords;
    
    final correctAnswer = _testType == 'wordToMeaning'
        ? _currentWord!.meaning
        : _currentWord!.word;
    
    final wrongAnswers = <String>[];
    final shuffledWords = List<Word>.from(allWords)..shuffle(_random);
    
    for (final word in shuffledWords) {
      if (wrongAnswers.length >= 3) break;
      
      final answer = _testType == 'wordToMeaning' ? word.meaning : word.word;
      if (answer != correctAnswer && !wrongAnswers.contains(answer)) {
        wrongAnswers.add(answer);
      }
    }
    
    _choices = [correctAnswer, ...wrongAnswers]..shuffle(_random);
    _correctIndex = _choices.indexOf(correctAnswer);
  }

  /// 답 선택
  void _selectAnswer(int index) {
    if (_showingResult) return;
    
    final isCorrect = index == _correctIndex;
    
    setState(() {
      _selectedIndex = index;
      _showingResult = true;
      _totalAttempts++;
      
      if (isCorrect) {
        // 정답: 완료 목록으로 이동
        _completedWords.add(_currentWord!);
        _remainingWords.remove(_currentWord!);
      } else {
        // 오답: 남은 목록에 그대로 유지 (다시 출제됨)
        _wrongCount++;
      }
    });
  }

  /// 다음 문제
  void _nextQuestion() {
    _loadNextQuestion();
  }

  /// 종료 확인
  void _confirmExit() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber),
            const SizedBox(width: 8),
            Text(
              '릴레이 종료',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          '진행 상황:\n✓ 완료: ${_completedWords.length}개\n○ 남음: ${_remainingWords.length}개\n\n지금 종료하시겠습니까?',
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
                color: Colors.amber,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _relayState = 'select');
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
