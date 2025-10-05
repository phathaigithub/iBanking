import 'package:flutter/material.dart';

/// Professional Major Icon Widget - Single Responsibility Principle
class MajorIcon extends StatelessWidget {
  final String majorCode;
  final double size;

  const MajorIcon({super.key, required this.majorCode, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: _getMajorGradient(majorCode),
        borderRadius: BorderRadius.circular(size / 4),
        boxShadow: [
          BoxShadow(
            color: _getMajorColor(majorCode).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _getMajorIcon(majorCode),
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  /// Get professional icon for each major
  IconData _getMajorIcon(String majorCode) {
    switch (majorCode.toUpperCase()) {
      case 'CNTT':
        return Icons.computer;
      case 'QTKD':
        return Icons.business_center;
      case 'KTE':
        return Icons.trending_up;
      case 'KT':
        return Icons.engineering;
      case 'NN':
        return Icons.language;
      case 'SP':
        return Icons.school;
      case 'Y':
        return Icons.local_hospital;
      case 'LUAT':
        return Icons.gavel;
      default:
        return Icons.school;
    }
  }

  /// Get gradient colors for each major
  LinearGradient _getMajorGradient(String majorCode) {
    final color = _getMajorColor(majorCode);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [color, color.withValues(alpha: 0.8)],
    );
  }

  /// Get primary color for each major
  Color _getMajorColor(String majorCode) {
    switch (majorCode.toUpperCase()) {
      case 'CNTT':
        return const Color(0xFF2196F3); // Blue
      case 'QTKD':
        return const Color(0xFF4CAF50); // Green
      case 'KTE':
        return const Color(0xFFFF9800); // Orange
      case 'KT':
        return const Color(0xFF9C27B0); // Purple
      case 'NN':
        return const Color(0xFFE91E63); // Pink
      case 'SP':
        return const Color(0xFF607D8B); // Blue Grey
      case 'Y':
        return const Color(0xFFF44336); // Red
      case 'LUAT':
        return const Color(0xFF795548); // Brown
      default:
        return const Color(0xFF1976D2); // Default Blue
    }
  }
}
