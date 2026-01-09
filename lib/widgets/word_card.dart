/// ============================================================
/// Word Card Widget - 단어 카드 위젯
/// ============================================================
/// 단어 학습에 사용되는 카드 위젯
/// - 상세 모드: 단어, 뜻, 예문, 번역 모두 표시
/// - 빠른 보기 모드: 단어와 뜻만 표시
/// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

/// 상세 단어 카드 (예문 포함)
class DetailWordCard extends StatelessWidget {
  final Word word;
  final bool showMeaning;
  final VoidCallback? onTap;

  const DetailWordCard({
    super.key,
    required this.word,
    this.showMeaning = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final isSaved = provider.isWordSaved(word.word);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 단어 + 저장 버튼
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              GlassIconButton(
                icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? AppColors.saved : null,
                size: 40,
                onTap: () => provider.toggleSaveWord(word),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 뜻
          if (showMeaning) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.meaning,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 예문
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
            const SizedBox(height: 6),
            Text(
              word.example,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 예문 번역
            Text(
              word.translation,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ] else ...[
            // 뜻 숨김 상태
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  '탭하여 뜻 보기',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 빠른 단어 카드 (단어와 뜻만)
class QuickWordCard extends StatelessWidget {
  final Word word;
  final bool showMeaning;
  final VoidCallback? onTap;

  const QuickWordCard({
    super.key,
    required this.word,
    this.showMeaning = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<AppProvider>();
    final isSaved = provider.isWordSaved(word.word);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // 단어
          Expanded(
            flex: 2,
            child: Text(
              word.word,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
          
          // 뜻
          Expanded(
            flex: 3,
            child: Text(
              showMeaning ? word.meaning : '• • •',
              style: TextStyle(
                fontSize: 15,
                color: showMeaning
                    ? (isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // 저장 버튼
          IconButton(
            icon: Icon(
              isSaved ? Icons.bookmark : Icons.bookmark_border,
              color: isSaved
                  ? AppColors.saved
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary),
              size: 22,
            ),
            onPressed: () => provider.toggleSaveWord(word),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 36,
              minHeight: 36,
            ),
          ),
        ],
      ),
    );
  }
}

/// 미니 단어 카드 (리스트용)
class MiniWordCard extends StatelessWidget {
  final Word word;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MiniWordCard({
    super.key,
    required this.word,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassCard(
      onTap: onTap,
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
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
