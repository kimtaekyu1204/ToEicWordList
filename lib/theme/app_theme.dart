/// ============================================================
/// App Theme - 앱 테마 설정
/// ============================================================
/// 라이트/다크 모드 파스텔 테마
/// - 라이트: 소프트 라벤더 배경, 검정 글씨
/// - 다크: 진한 배경, 흰색 글씨
/// - 눈이 편안한 연한 파스텔 색상만 사용
/// ============================================================

import 'package:flutter/material.dart';

/// 앱 색상 팔레트
class AppColors {
  // ============================================================
  // 라이트 모드 색상 (소프트 라벤더 테마)
  // ============================================================
  
  /// 라이트 모드 배경 그라데이션 시작 색상 (연한 라벤더)
  static const Color lightBgStart = Color(0xFFF5F3FF);
  
  /// 라이트 모드 배경 그라데이션 끝 색상 (흰색에 가까운 라벤더)
  static const Color lightBgEnd = Color(0xFFFAF9FF);
  
  /// 라이트 모드 카드 배경 (반투명 흰색)
  static const Color lightCardBg = Color(0xFFFFFFFF);
  
  /// 라이트 모드 주 텍스트 색상 (검정)
  static const Color lightTextPrimary = Color(0xFF1A1A2E);
  
  /// 라이트 모드 보조 텍스트 색상 (회색)
  static const Color lightTextSecondary = Color(0xFF6B6B80);
  
  /// 라이트 모드 포인트 색상 (연한 라벤더)
  static const Color lightAccent = Color(0xFFB8B5E4);
  
  /// 라이트 모드 포인트 색상 (조금 더 진한 라벤더)
  static const Color lightAccentDark = Color(0xFF9D99D9);

  // ============================================================
  // 다크 모드 색상
  // ============================================================
  
  /// 다크 모드 배경 그라데이션 시작 색상
  static const Color darkBgStart = Color(0xFF1A1A2E);
  
  /// 다크 모드 배경 그라데이션 끝 색상
  static const Color darkBgEnd = Color(0xFF16162A);
  
  /// 다크 모드 카드 배경 (반투명 진한 색)
  static const Color darkCardBg = Color(0xFF252542);
  
  /// 다크 모드 주 텍스트 색상 (흰색)
  static const Color darkTextPrimary = Color(0xFFF5F5F7);
  
  /// 다크 모드 보조 텍스트 색상 (연한 회색)
  static const Color darkTextSecondary = Color(0xFFA0A0B0);
  
  /// 다크 모드 포인트 색상 (연한 라벤더)
  static const Color darkAccent = Color(0xFFB8B5E4);
  
  /// 다크 모드 포인트 색상 (조금 더 밝은 라벤더)
  static const Color darkAccentLight = Color(0xFFCBC8F0);

  // ============================================================
  // 공통 색상
  // ============================================================
  
  /// 정답 색상 (연한 초록)
  static const Color correct = Color(0xFF7EC8A8);
  
  /// 오답 색상 (연한 분홍)
  static const Color wrong = Color(0xFFE8A0A0);
  
  /// 경고 색상 (연한 노랑)
  static const Color warning = Color(0xFFE8D090);
  
  /// 저장됨 표시 색상 (연한 파랑)
  static const Color saved = Color(0xFF90B8E8);
}

/// 앱 테마 데이터
class AppTheme {
  /// 라이트 테마
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // 색상 스킴
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightAccentDark,
      secondary: AppColors.lightAccent,
      surface: AppColors.lightCardBg,
      onPrimary: Colors.white,
      onSecondary: AppColors.lightTextPrimary,
      onSurface: AppColors.lightTextPrimary,
    ),
    
    // 스캐폴드 배경색 (투명 - 그라데이션 사용을 위해)
    scaffoldBackgroundColor: Colors.transparent,
    
    // 앱바 테마
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
    ),
    
    // 텍스트 테마
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.lightTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppColors.lightTextSecondary,
        fontSize: 12,
      ),
    ),
    
    // 카드 테마
    cardTheme: CardThemeData(
      color: AppColors.lightCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.lightAccentDark,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // 하단 네비게이션 바 테마
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightCardBg,
      selectedItemColor: AppColors.lightAccentDark,
      unselectedItemColor: AppColors.lightTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );

  /// 다크 테마
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // 색상 스킴
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkAccent,
      secondary: AppColors.darkAccentLight,
      surface: AppColors.darkCardBg,
      onPrimary: AppColors.darkTextPrimary,
      onSecondary: AppColors.darkTextPrimary,
      onSurface: AppColors.darkTextPrimary,
    ),
    
    // 스캐폴드 배경색 (투명 - 그라데이션 사용을 위해)
    scaffoldBackgroundColor: Colors.transparent,
    
    // 앱바 테마
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    ),
    
    // 텍스트 테마
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      headlineMedium: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 24,
        fontWeight: FontWeight.w600,
      ),
      headlineSmall: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: AppColors.darkTextPrimary,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 14,
      ),
      bodySmall: TextStyle(
        color: AppColors.darkTextSecondary,
        fontSize: 12,
      ),
    ),
    
    // 카드 테마
    cardTheme: CardThemeData(
      color: AppColors.darkCardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // 버튼 테마
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkAccent,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    
    // 하단 네비게이션 바 테마
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkCardBg,
      selectedItemColor: AppColors.darkAccent,
      unselectedItemColor: AppColors.darkTextSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
  );
}
