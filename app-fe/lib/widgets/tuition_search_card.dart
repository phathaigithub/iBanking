import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_tuition_provider.dart';
import '../utils/app_theme.dart';

class TuitionSearchCard extends ConsumerStatefulWidget {
  const TuitionSearchCard({super.key});

  @override
  ConsumerState<TuitionSearchCard> createState() => _TuitionSearchCardState();
}

class _TuitionSearchCardState extends ConsumerState<TuitionSearchCard> {
  final _searchController = TextEditingController();
  String _searchField = 'studentCode';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(adminTuitionProvider.notifier);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.search, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tìm kiếm và lọc học phí',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search section
            Row(
              children: [
                // Search field dropdown
                Container(
                  width: 240, // Doubled from 120 to 240
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _searchField,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(
                          value: 'studentCode',
                          child: Text('Mã sinh viên'),
                        ),
                        DropdownMenuItem(
                          value: 'tuitionCode',
                          child: Text('Mã học phí'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _searchField = value;
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Search input
                Expanded(
                  child: TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: _searchField == 'studentCode'
                          ? 'Nhập mã sinh viên...'
                          : 'Nhập mã học phí...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                notifier.setSearchQuery('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      notifier.setSearchQuery(value);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Search button
                ElevatedButton.icon(
                  onPressed: () {
                    notifier.searchTuitions();
                  },
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Tìm kiếm'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Clear filters button moved to the right of search button
                OutlinedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    notifier.clearFilters();
                  },
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Xóa bộ lọc'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
