/// ============================================================
/// Custom Words Screen - 사용자 정의 단어장 화면
/// ============================================================
/// 사용자가 직접 단어를 추가/수정/삭제
/// - 추가한 단어는 전체 앱에서 사용 가능
/// - 테스트, 릴레이, 오답노트 등에 통합
/// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';

class CustomWordsScreen extends StatefulWidget {
  const CustomWordsScreen({super.key});

  @override
  State<CustomWordsScreen> createState() => _CustomWordsScreenState();
}

class _CustomWordsScreenState extends State<CustomWordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final customWords = provider.customWords;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 검색 필터링
    final filteredWords = _searchQuery.isEmpty
        ? customWords
        : customWords.where((w) =>
            w.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            w.meaning.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Column(
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.correct.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: AppColors.correct,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '나만의 단어장',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          Text(
                            '${customWords.length}개의 단어',
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
                  // 단어 추가 버튼
                  GlassIconButton(
                    icon: Icons.add,
                    onTap: () => _showAddWordDialog(context),
                    color: AppColors.correct,
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // 검색 바
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkCardBg : AppColors.lightCardBg)
                      .withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _searchQuery = value),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '단어 또는 뜻 검색...',
                    hintStyle: TextStyle(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 단어 목록
        Expanded(
          child: filteredWords.isEmpty
              ? _buildEmptyState(context, isDark, customWords.isEmpty)
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredWords.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final word = filteredWords[index];
                    return _buildWordCard(context, word, isDark);
                  },
                ),
        ),
      ],
    );
  }

  /// 빈 상태 위젯
  Widget _buildEmptyState(BuildContext context, bool isDark, bool isEmpty) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isEmpty ? Icons.note_add_outlined : Icons.search_off,
              size: 64,
              color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                  .withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              isEmpty ? '단어를 추가해보세요!' : '검색 결과가 없습니다',
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
              isEmpty
                  ? '상단의 + 버튼을 눌러\n나만의 단어를 추가하세요.'
                  : '다른 검색어로 시도해보세요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            if (isEmpty) ...[
              const SizedBox(height: 24),
              GlassButton(
                text: '단어 추가하기',
                icon: Icons.add,
                onTap: () => _showAddWordDialog(context),
                color: AppColors.correct,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 단어 카드 위젯
  Widget _buildWordCard(BuildContext context, Word word, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // 사용자 추가 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.correct.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '내 단어',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.correct,
                  ),
                ),
              ),
              const Spacer(),
              // 수정 버튼
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => _showEditWordDialog(context, word),
                color: isDark ? AppColors.darkAccent : AppColors.lightAccentDark,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              // 삭제 버튼
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => _confirmDelete(context, word),
                color: AppColors.wrong,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            word.word,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            word.meaning,
            style: TextStyle(
              fontSize: 15,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          if (word.example.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkAccent : AppColors.lightAccent)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.example,
                    style: TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  if (word.translation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      word.translation,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 단어 추가 다이얼로그
  void _showAddWordDialog(BuildContext context) {
    _showWordFormDialog(context, null);
  }

  /// 단어 수정 다이얼로그
  void _showEditWordDialog(BuildContext context, Word word) {
    _showWordFormDialog(context, word);
  }

  /// 단어 폼 다이얼로그 (추가/수정 공용)
  void _showWordFormDialog(BuildContext context, Word? existingWord) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = existingWord != null;
    final originalWord = existingWord?.word ?? '';  // 원본 단어 저장
    
    final wordController = TextEditingController(text: existingWord?.word ?? '');
    final meaningController = TextEditingController(text: existingWord?.meaning ?? '');
    final exampleController = TextEditingController(text: existingWord?.example ?? '');
    final translationController = TextEditingController(text: existingWord?.translation ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isEditing ? Icons.edit : Icons.add_circle,
              color: AppColors.correct,
            ),
            const SizedBox(width: 8),
            Text(
              isEditing ? '단어 수정' : '새 단어 추가',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(
                controller: wordController,
                label: '단어 *',
                hint: '영어 단어를 입력하세요',
                isDark: isDark,
                enabled: !isEditing, // 수정시 단어는 변경 불가
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: meaningController,
                label: '뜻 *',
                hint: '한국어 뜻을 입력하세요',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: exampleController,
                label: '예문 (선택)',
                hint: '영어 예문을 입력하세요',
                isDark: isDark,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: translationController,
                label: '예문 번역 (선택)',
                hint: '예문의 한국어 번역',
                isDark: isDark,
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final word = wordController.text.trim();
              final meaning = meaningController.text.trim();
              final example = exampleController.text.trim();
              final translation = translationController.text.trim();

              if (word.isEmpty || meaning.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('단어와 뜻은 필수입니다.'),
                    backgroundColor: AppColors.wrong,
                  ),
                );
                return;
              }

              final newWord = Word(
                word: isEditing ? originalWord : word,
                meaning: meaning,
                example: example,
                translation: translation,
              );

              final provider = context.read<AppProvider>();
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              if (isEditing) {
                await provider.updateCustomWord(originalWord, newWord);
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('단어가 수정되었습니다.'),
                    backgroundColor: AppColors.correct,
                  ),
                );
              } else {
                final success = await provider.addCustomWord(newWord);
                if (success) {
                  if (dialogContext.mounted) Navigator.pop(dialogContext);
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('단어가 추가되었습니다.'),
                      backgroundColor: AppColors.correct,
                    ),
                  );
                } else {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text('이미 존재하는 단어입니다.'),
                      backgroundColor: AppColors.wrong,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.correct,
              foregroundColor: Colors.white,
            ),
            child: Text(isEditing ? '수정' : '추가'),
          ),
        ],
      ),
    );
  }

  /// 텍스트 필드 위젯
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    bool enabled = true,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      style: TextStyle(
        color: isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary,
        ),
        hintStyle: TextStyle(
          color: (isDark
              ? AppColors.darkTextSecondary
              : AppColors.lightTextSecondary).withValues(alpha: 0.5),
        ),
        filled: true,
        fillColor: (isDark ? AppColors.darkCardBg : AppColors.lightCardBg)
            .withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.correct),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  void _confirmDelete(BuildContext context, Word word) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: AppColors.wrong),
            const SizedBox(width: 8),
            Text(
              '단어 삭제',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          '"${word.word}" 단어를 삭제하시겠습니까?\n삭제된 단어는 복구할 수 없습니다.',
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              '취소',
              style: TextStyle(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AppProvider>().removeCustomWord(word.word);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('단어가 삭제되었습니다.'),
                  backgroundColor: AppColors.wrong,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.wrong,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}
