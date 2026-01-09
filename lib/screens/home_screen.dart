/// ============================================================
/// Home Screen - 메인 홈 화면
/// ============================================================
/// 앱의 메인 대시보드
/// - 오늘의 정답률 (원형 차트)
/// - 일일 테스트 횟수
/// - 오답 노트 현황
/// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 앱 시작시 테스트 알림 체크
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkTodayTest();
    });
  }

  /// 오늘 테스트 여부 확인하고 알림
  void _checkTodayTest() {
    final provider = context.read<AppProvider>();
    if (!provider.isTodayTestCompleted) {
      _showTestReminder();
    }
  }

  /// 테스트 알림 다이얼로그
  void _showTestReminder() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
            ),
            const SizedBox(width: 8),
            Text(
              '오늘의 테스트',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          '아직 오늘 테스트를 하지 않았어요!\n매일 꾸준히 테스트하면 토익 점수가 올라갑니다. 📈',
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
              '나중에',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 테스트 화면(인덱스 2)으로 이동
              MainScreen.mainScreenKey.currentState?.switchToTab(2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
              foregroundColor: Colors.white,
            ),
            child: const Text('테스트 하러 가기'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 인사말 + 테마 토글
          _buildHeader(context, provider, isDark),
          
          const SizedBox(height: 24),
          
          // 오늘의 정답률 카드 (원형 차트)
          _buildTodayAccuracyCard(context, provider, isDark),
          
          const SizedBox(height: 16),
          
          // 학습 현황 카드
          _buildProgressCard(context, provider, isDark),
          
          const SizedBox(height: 16),
          
          // 오늘의 테스트 상태 카드
          _buildTodayTestCard(context, provider, isDark),
          
          const SizedBox(height: 16),
          
          // 오답 노트 카드 (오답이 있을 때만)
          if (provider.todayWrongAnswers.isNotEmpty)
            _buildWrongAnswersCard(context, provider, isDark),
          
          const SizedBox(height: 16),
          
          // 나만의 단어장 미리보기 (저장된 단어가 있을 때만)
          if (provider.savedWords.isNotEmpty)
            _buildSavedWordsCard(context, provider, isDark),
        ],
      ),
    );
  }

  /// 헤더 위젯 빌드
  Widget _buildHeader(BuildContext context, AppProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '안녕하세요! 👋',
              style: TextStyle(
                fontSize: 16,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Vocab Master',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        GlassIconButton(
          icon: isDark ? Icons.light_mode : Icons.dark_mode,
          onTap: () => provider.toggleTheme(),
        ),
      ],
    );
  }

  /// 오늘의 정답률 카드 (원형 차트)
  Widget _buildTodayAccuracyCard(BuildContext context, AppProvider provider, bool isDark) {
    final accuracy = provider.todayAccuracy;
    final hasTestToday = provider.todayTotalCount > 0;

    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.pie_chart,
                color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 정답률',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (hasTestToday)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AccuracyPieChart(
                  accuracy: accuracy,
                  size: 120,
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow('정답', '${provider.todayCorrectCount}개', AppColors.correct, isDark),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      '오답', 
                      '${provider.todayTotalCount - provider.todayCorrectCount}개', 
                      AppColors.wrong, 
                      isDark,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow('총 문제', '${provider.todayTotalCount}개', 
                      isDark ? AppColors.darkAccent : AppColors.lightAccentDark, 
                      isDark,
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              children: [
                Icon(
                  Icons.hourglass_empty,
                  size: 48,
                  color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                      .withValues(alpha: 0.5),
                ),
                const SizedBox(height: 12),
                Text(
                  '아직 오늘 테스트 기록이 없어요',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '테스트를 시작해보세요!',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// 통계 행 위젯
  Widget _buildStatRow(String label, String value, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  /// 학습 현황 카드
  Widget _buildProgressCard(BuildContext context, AppProvider provider, bool isDark) {
    final totalWords = provider.allWords.length;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_graph,
                color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '학습 현황',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatItem(
                context,
                '전체 단어',
                '$totalWords개',
                Icons.library_books_outlined,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                context,
                '오늘 테스트',
                '${provider.todayTestCount}회',
                Icons.quiz_outlined,
                isDark,
              ),
              const SizedBox(width: 16),
              _buildStatItem(
                context,
                '저장된 단어',
                '${provider.savedWords.length}개',
                Icons.bookmark_outline,
                isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 통계 아이템 위젯
  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: (isDark ? AppColors.darkAccent : AppColors.lightAccent)
              .withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
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

  /// 오늘의 테스트 카드
  Widget _buildTodayTestCard(BuildContext context, AppProvider provider, bool isDark) {
    final isCompleted = provider.isTodayTestCompleted;
    final testCount = provider.todayTestCount;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.pending_actions,
                color: isCompleted
                    ? AppColors.correct
                    : (isDark ? AppColors.darkAccent : AppColors.lightAccentDark),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 테스트',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.correct.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$testCount회 완료',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.correct,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            isCompleted
                ? '오늘 ${testCount}회 테스트를 완료했습니다! 더 하고 싶으면 계속 도전하세요.'
                : '매일 단어 테스트로 실력을 확인해보세요.',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCompleted
                ? '💪 꾸준히 학습하면 토익 900+ 달성할 수 있어요!'
                : '📝 테스트 탭에서 시작하세요 (1일 1테스트 필수!)',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 오답 노트 카드
  Widget _buildWrongAnswersCard(BuildContext context, AppProvider provider, bool isDark) {
    final wrongCount = provider.todayWrongAnswers.length;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.wrong,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '오늘의 오답',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.wrong.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$wrongCount개',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.wrong,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '오답 탭에서 틀린 단어를 다시 학습하세요.',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 나만의 단어장 카드
  Widget _buildSavedWordsCard(BuildContext context, AppProvider provider, bool isDark) {
    final savedCount = provider.savedWords.length;
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.bookmark,
                color: AppColors.saved,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                '나만의 단어장',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.saved.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$savedCount개',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.saved,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '저장한 단어들을 시험 전에 복습하세요.',
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
