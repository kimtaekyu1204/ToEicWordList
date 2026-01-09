/// ============================================================
/// Glass Card Widget - 글래스 카드 위젯
/// ============================================================
/// 반투명 글래스 효과가 적용된 카드 위젯
/// - 프로스티드 글래스 효과
/// - 부드러운 그림자
/// - 라이트/다크 모드 대응
/// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  /// 카드 내부 위젯
  final Widget child;
  
  /// 카드 패딩 (기본값: 16)
  final EdgeInsetsGeometry padding;
  
  /// 카드 마진
  final EdgeInsetsGeometry? margin;
  
  /// 카드 너비
  final double? width;
  
  /// 카드 높이
  final double? height;
  
  /// 모서리 둥글기 (기본값: 20)
  final double borderRadius;
  
  /// 클릭 콜백
  final VoidCallback? onTap;
  
  /// 블러 강도 (기본값: 10)
  final double blurAmount;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.onTap,
    this.blurAmount = 10,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 카드 배경색 (반투명)
    final backgroundColor = isDark
        ? AppColors.darkCardBg.withValues(alpha: 0.7)
        : AppColors.lightCardBg.withValues(alpha: 0.8);
    
    // 테두리 색상 (미세한 하이라이트)
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.white.withValues(alpha: 0.5);
    
    // 그림자 색상
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.3)
        : AppColors.lightAccent.withValues(alpha: 0.15);

    return Container(
      width: width,
      height: height,
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: blurAmount,
            sigmaY: blurAmount,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(borderRadius),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 작은 글래스 버튼 위젯
class GlassButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final IconData? icon;
  final Color? color;
  final bool isSmall;

  const GlassButton({
    super.key,
    required this.text,
    this.onTap,
    this.icon,
    this.color,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final buttonColor = color ?? 
        (isDark ? AppColors.darkAccent : AppColors.lightAccentDark);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 12 : 20,
            vertical: isSmall ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: buttonColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: buttonColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: Colors.white,
                  size: isSmall ? 16 : 20,
                ),
                SizedBox(width: isSmall ? 6 : 8),
              ],
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 13 : 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 아이콘만 있는 글래스 버튼
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.darkCardBg.withValues(alpha: 0.7)
        : AppColors.lightCardBg.withValues(alpha: 0.8);
    final iconColor = color ?? 
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.lightAccent)
                    .withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
