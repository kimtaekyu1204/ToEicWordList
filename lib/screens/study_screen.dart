/// ============================================================
/// Study Screen - 단어 학습 화면
/// ============================================================
/// 단어 학습 모드 선택 및 학습
/// - 상세 학습: 예문과 함께 학습
/// - 빠른 보기: 단어와 뜻만 빠르게 학습
/// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class StudyScreen extends StatefulWidget {
  const StudyScreen({super.key});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  // 학습 모드: 'select' | 'detail' | 'quick'
  String _mode = 'select';
  
  // 현재 학습 중인 단어 목록
  List<Word> _studyWords = [];
  
  // 현재 단어 인덱스
  int _currentIndex = 0;
  
  // 뜻 표시 여부 (상세 모드에서)
  bool _showMeaning = false;

  @override
  Widget build(BuildContext context) {
    switch (_mode) {
      case 'detail':
        return _buildDetailStudy(context);
      case 'quick':
        return _buildQuickStudy(context);
      default:
        return _buildModeSelect(context);
    }
  }

  /// 모드 선택 화면
  Widget _buildModeSelect(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Text(
            '단어 학습',
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
            '학습 모드를 선택하세요',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 상세 학습 모드 카드
          GlassCard(
            onTap: () => _startStudy('detail', provider.allWords),
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
                    Icons.menu_book,
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
                        '상세 학습',
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
                        '예문과 번역으로 심화 학습',
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
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 빠른 보기 모드 카드
          GlassCard(
            onTap: () => _startStudy('quick', provider.allWords),
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
                    Icons.flash_on,
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
                        '빠른 보기',
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
                        '단어와 뜻만 빠르게 확인',
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
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // 단어 수 표시
          Center(
            child: Text(
              '총 ${provider.allWords.length}개의 단어',
              style: TextStyle(
                fontSize: 14,
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

  /// 상세 학습 모드 화면
  Widget _buildDetailStudy(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_studyWords.isEmpty) {
      return const Center(child: Text('학습할 단어가 없습니다.'));
    }
    
    final currentWord = _studyWords[_currentIndex];
    
    return Column(
      children: [
        // 상단 바: 뒤로가기 + 진행률
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GlassIconButton(
                icon: Icons.close,
                onTap: () => setState(() => _mode = 'select'),
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_currentIndex + 1} / ${_studyWords.length}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: (_currentIndex + 1) / _studyWords.length,
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
        
        // 단어 카드
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: GestureDetector(
              onTap: () {
                if (!_showMeaning) {
                  setState(() => _showMeaning = true);
                }
              },
              child: DetailWordCard(
                word: currentWord,
                showMeaning: _showMeaning,
              ),
            ),
          ),
        ),
        
        // 하단 네비게이션 버튼
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // 이전 버튼
              Expanded(
                child: GlassButton(
                  text: '이전',
                  icon: Icons.arrow_back,
                  onTap: _currentIndex > 0 ? _previousWord : null,
                ),
              ),
              const SizedBox(width: 12),
              // 다음 버튼
              Expanded(
                child: GlassButton(
                  text: _currentIndex < _studyWords.length - 1 ? '다음' : '완료',
                  icon: _currentIndex < _studyWords.length - 1
                      ? Icons.arrow_forward
                      : Icons.check,
                  onTap: _showMeaning ? _nextWord : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 빠른 보기 모드 화면
  Widget _buildQuickStudy(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        // 상단 바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              GlassIconButton(
                icon: Icons.close,
                onTap: () => setState(() => _mode = 'select'),
                size: 40,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '빠른 보기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Text(
                '${_studyWords.length}개 단어',
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
        
        // 단어 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _studyWords.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return QuickWordCard(
                word: _studyWords[index],
                showMeaning: true,
              );
            },
          ),
        ),
      ],
    );
  }

  /// 학습 시작
  void _startStudy(String mode, List<Word> words) {
    setState(() {
      _mode = mode;
      _studyWords = List.from(words)..shuffle();
      _currentIndex = 0;
      _showMeaning = false;
    });
  }

  /// 이전 단어로
  void _previousWord() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showMeaning = false;
      });
    }
  }

  /// 다음 단어로 또는 완료
  void _nextWord() {
    if (_currentIndex < _studyWords.length - 1) {
      setState(() {
        _currentIndex++;
        _showMeaning = false;
      });
    } else {
      // 학습 완료
      _showCompletionDialog();
    }
  }

  /// 학습 완료 다이얼로그
  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          '학습 완료! 🎉',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          '${_studyWords.length}개 단어 학습을 완료했습니다.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _mode = 'select');
            },
            child: Text(
              '확인',
              style: TextStyle(
                color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
