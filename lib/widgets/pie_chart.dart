/// ============================================================
/// Pie Chart Widget - 원형 차트 위젯
/// ============================================================
/// 정답률을 원형 차트로 표시
/// ============================================================

import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AccuracyPieChart extends StatelessWidget {
  /// 정답률 (0 ~ 100)
  final double accuracy;
  
  /// 차트 크기
  final double size;
  
  /// 선 두께
  final double strokeWidth;

  const AccuracyPieChart({
    super.key,
    required this.accuracy,
    this.size = 120,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 정답률에 따른 색상
    Color progressColor;
    if (accuracy >= 80) {
      progressColor = AppColors.correct;
    } else if (accuracy >= 50) {
      progressColor = AppColors.warning;
    } else {
      progressColor = AppColors.wrong;
    }
    
    final bgColor = (isDark ? AppColors.darkAccent : AppColors.lightAccent)
        .withValues(alpha: 0.2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // 배경 원
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: 1.0,
              color: bgColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // 진행 원
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: accuracy / 100,
              color: progressColor,
              strokeWidth: strokeWidth,
            ),
          ),
          // 중앙 텍스트
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${accuracy.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  '정답률',
                  style: TextStyle(
                    fontSize: size * 0.1,
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
    );
  }
}

/// 원형 차트 페인터
class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    
    // -90도(12시 방향)에서 시작
    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

/// 간단한 원형 진행률 인디케이터
class SimpleProgressRing extends StatelessWidget {
  final double progress;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const SimpleProgressRing({
    super.key,
    required this.progress,
    this.size = 40,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressColor = color ?? 
        (isDark ? AppColors.darkAccent : AppColors.lightAccentDark);
    final bgColor = backgroundColor ?? 
        progressColor.withValues(alpha: 0.2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: 1.0,
              color: bgColor,
              strokeWidth: size * 0.15,
            ),
          ),
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: progress.clamp(0, 1),
              color: progressColor,
              strokeWidth: size * 0.15,
            ),
          ),
        ],
      ),
    );
  }
}
