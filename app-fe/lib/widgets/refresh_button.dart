import 'package:flutter/material.dart';

/// Refresh Button Widget - Single Responsibility Principle
class RefreshButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;
  final String tooltip;

  const RefreshButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
      tooltip: tooltip,
    );
  }
}
