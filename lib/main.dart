/// ============================================================
/// Vocab Master - 토익 단어 학습 앱
/// ============================================================
/// 메인 진입점
/// - 앱 초기화
/// - Provider 설정
/// - 메인 네비게이션
/// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/widgets.dart';
import 'screens/screens.dart';

void main() {
  runApp(const VocabMasterApp());
}

/// 메인 앱 위젯
class VocabMasterApp extends StatelessWidget {
  const VocabMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const _AppContent(),
    );
  }
}

/// 앱 콘텐츠 (Provider 하위)
class _AppContent extends StatefulWidget {
  const _AppContent();

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await context.read<AppProvider>().initialize();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return MaterialApp(
      title: 'Vocab Master',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _initialized
          ? MainScreen(key: MainScreen.mainScreenKey)
          : const _LoadingScreen(),
    );
  }
}

/// 로딩 화면
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: const Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고/아이콘
              Icon(
                Icons.menu_book,
                size: 64,
                color: AppColors.lightAccentDark,
              ),
              SizedBox(height: 24),
              Text(
                'Vocab Master',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '단어장을 불러오는 중...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              SizedBox(height: 32),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppColors.lightAccentDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 메인 화면 (하단 네비게이션 포함)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  /// 전역 키 (외부에서 탭 전환용)
  static final GlobalKey<_MainScreenState> mainScreenKey = GlobalKey<_MainScreenState>();

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  /// 외부에서 탭 전환
  void switchToTab(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() => _currentIndex = index);
    }
  }

  // 화면 목록
  final List<Widget> _screens = const [
    HomeScreen(),
    StudyScreen(),
    TestScreen(),
    RelayScreen(),
    WrongAnswersScreen(),
  ];

  // 네비게이션 아이템 데이터
  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: '홈'),
    _NavItem(icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book, label: '학습'),
    _NavItem(icon: Icons.quiz_outlined, activeIcon: Icons.quiz, label: '테스트'),
    _NavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events, label: '릴레이'),
    _NavItem(icon: Icons.bookmark_outline, activeIcon: Icons.bookmark, label: '오답'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ),
        bottomNavigationBar: _buildBottomNav(isDark),
      ),
    );
  }

  /// 하단 네비게이션 바 빌드
  Widget _buildBottomNav(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkCardBg : AppColors.lightCardBg)
            .withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightAccent)
                .withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_navItems.length, (index) {
            return _buildNavItem(index, isDark);
          }),
        ),
      ),
    );
  }

  /// 네비게이션 아이템 빌드
  Widget _buildNavItem(int index, bool isDark) {
    final item = _navItems[index];
    final isSelected = _currentIndex == index;
    final color = isSelected
        ? (isDark ? AppColors.darkAccent : AppColors.lightAccentDark)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 네비게이션 아이템 데이터 클래스
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
