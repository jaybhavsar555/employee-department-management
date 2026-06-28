import 'package:flutter/material.dart';

/// Reusable pagination bar for Spring Data pages (0-based index).
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalElements,
    required this.onPrevious,
    required this.onNext,
  });

  final int currentPage;
  final int totalPages;
  final int totalElements;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Text('Page ${currentPage + 1} of $totalPages ($totalElements total)'),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}
