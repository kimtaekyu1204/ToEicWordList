/// ============================================================
/// Wrong Answers Screen - 오답 노트 화면
/// ============================================================
/// 오늘의 오답과 나만의 단어장 관리
/// - 오늘 틀린 단어 복습
/// - 저장한 단어 관리
/// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class WrongAnswersScreen extends StatefulWidget {
  const WrongAnswersScreen({super.key});

  @override
  State<WrongAnswersScreen> createState() => _WrongAnswersScreenState();
}

class _WrongAnswersScreenState extends State<WrongAnswersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 탭 바
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkCardBg : AppColors.lightCardBg)
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '오늘의 오답'),
                Tab(text: '나만의 단어장'),
              ],
            ),
          ),
        ),
        
        // 탭 뷰
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _TodayWrongAnswersTab(),
              _SavedWordsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

/// 오늘의 오답 탭
class _TodayWrongAnswersTab extends StatelessWidget {
  const _TodayWrongAnswersTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final wrongAnswers = provider.todayWrongAnswers;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (wrongAnswers.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.check_circle_outline,
        title: '오답이 없습니다',
        subtitle: '오늘 테스트에서 틀린 단어가 여기에 표시됩니다.',
        isDark: isDark,
      );
    }

    return _WordListView(
      words: wrongAnswers,
      emptyTitle: '오답이 없습니다',
      emptySubtitle: '오늘 테스트에서 틀린 단어가 여기에 표시됩니다.',
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
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
    );
  }
}

/// 나만의 단어장 탭
class _SavedWordsTab extends StatelessWidget {
  const _SavedWordsTab();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final savedWords = provider.savedWords;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (savedWords.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.bookmark_outline,
        title: '저장된 단어가 없습니다',
        subtitle: '학습 중 북마크 버튼을 눌러\n나만의 단어장을 만들어보세요.',
        isDark: isDark,
      );
    }

    return _WordListView(
      words: savedWords,
      emptyTitle: '저장된 단어가 없습니다',
      emptySubtitle: '학습 중 북마크 버튼을 눌러\n나만의 단어장을 만들어보세요.',
      showDeleteButton: true,
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
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
    );
  }
}

/// 단어 목록 뷰
class _WordListView extends StatefulWidget {
  final List<Word> words;
  final String emptyTitle;
  final String emptySubtitle;
  final bool showDeleteButton;

  const _WordListView({
    required this.words,
    required this.emptyTitle,
    required this.emptySubtitle,
    this.showDeleteButton = false,
  });

  @override
  State<_WordListView> createState() => _WordListViewState();
}

class _WordListViewState extends State<_WordListView> {
  Word? _selectedWord;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        // 단어 수 표시
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Text(
                '총 ${widget.words.length}개',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        
        // 선택된 단어 상세 (모달처럼 표시)
        if (_selectedWord != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildDetailCard(_selectedWord!, isDark),
          ),
        
        // 단어 목록
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: widget.words.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final word = widget.words[index];
              final isSelected = _selectedWord?.word == word.word;
              
              return GlassCard(
                onTap: () {
                  setState(() {
                    _selectedWord = isSelected ? null : word;
                  });
                },
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            word.word,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            word.meaning,
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
                    if (widget.showDeleteButton)
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: AppColors.wrong,
                        iconSize: 20,
                        onPressed: () {
                          context.read<AppProvider>().toggleSaveWord(word);
                          if (_selectedWord?.word == word.word) {
                            setState(() => _selectedWord = null);
                          }
                        },
                      )
                    else
                      Icon(
                        isSelected ? Icons.expand_less : Icons.expand_more,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 상세 카드
  Widget _buildDetailCard(Word word, bool isDark) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                word.word,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedWord = null),
                iconSize: 20,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              word.meaning,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '예문',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            word.example,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            word.translation,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
