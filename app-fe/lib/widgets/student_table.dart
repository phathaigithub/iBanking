import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/student_detail.dart';
import '../models/major.dart';
import '../utils/app_theme.dart';
import '../widgets/major_icon.dart';

/// Student Table Widget with search and filter functionality
class StudentTable extends ConsumerStatefulWidget {
  final List<StudentDetail> students;
  final List<Major> majors;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRefresh;
  final Function(String)? onSearch; // Add search callback

  const StudentTable({
    super.key,
    required this.students,
    required this.majors,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onSearch,
  });

  @override
  ConsumerState<StudentTable> createState() => _StudentTableState();
}

class _StudentTableState extends ConsumerState<StudentTable> {
  final TextEditingController _searchController = TextEditingController();
  String _searchField = 'name'; // 'name' or 'studentCode'
  String? _selectedMajorCode;
  List<StudentDetail> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _filteredStudents = widget.students;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(StudentTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.students != widget.students) {
      _applyFilters();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filteredStudents = widget.students.where((student) {
        // Apply search filter locally
        final searchText = _searchController.text.toLowerCase();
        bool matchesSearch = false;

        if (searchText.isEmpty) {
          matchesSearch = true;
        } else {
          if (_searchField == 'name') {
            matchesSearch = student.name.toLowerCase().contains(searchText);
          } else {
            matchesSearch = student.studentCode.toLowerCase().contains(
              searchText,
            );
          }
        }

        // Apply major filter
        bool matchesMajor = true;
        if (_selectedMajorCode != null && _selectedMajorCode!.isNotEmpty) {
          matchesMajor = student.majorCode == _selectedMajorCode;
        }

        return matchesSearch && matchesMajor;
      }).toList();
    });
  }

  void _performSearch() {
    // For now, just apply local filters since API search is not working
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filter Section
        _buildSearchAndFilterSection(),

        // Spacing between search card and table
        const SizedBox(height: 12),

        // Table Section
        Expanded(
          child: Card(
            child: Column(
              children: [
                // Table Header
                _buildTableHeader(),
                const Divider(height: 1),

                // Table Content
                Expanded(
                  child: widget.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : widget.error != null
                      ? _buildErrorWidget()
                      : _buildTableContent(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          // Header Row with title, results, and action buttons
          Row(
            children: [
              // Title
              Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    'Tìm kiếm và lọc',
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Results count
              Text(
                'Kết quả: ${_filteredStudents.length}/${widget.students.length}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 16),
              // Action buttons
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _selectedMajorCode = null;
                  });
                  _applyFilters();
                },
                icon: const Icon(Icons.clear_all),
                label: const Text('Xóa bộ lọc'),
              ),
              const SizedBox(width: 8),
              if (widget.onRefresh != null)
                IconButton(
                  onPressed: widget.onRefresh,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Làm mới dữ liệu',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Row
          Row(
            children: [
              // Search Field Dropdown
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  initialValue: _searchField,
                  decoration: const InputDecoration(
                    labelText: 'Tìm theo',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('Tên sinh viên'),
                    ),
                    DropdownMenuItem(
                      value: 'studentCode',
                      child: Text('Mã số sinh viên'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _searchField = value!;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Search Input - Flex 1
              Expanded(
                flex: 1,
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: _searchField == 'name'
                        ? 'Nhập tên sinh viên'
                        : 'Nhập mã số sinh viên',
                    hintText: _searchField == 'name'
                        ? 'Ví dụ: Nguyễn Văn A'
                        : 'Ví dụ: 52200001',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Major Filter Dropdown - Flex 1
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedMajorCode,
                  decoration: const InputDecoration(
                    labelText: 'Ngành học',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  hint: const Text('Tất cả ngành'),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Tất cả ngành'),
                    ),
                    ...widget.majors.map((major) {
                      return DropdownMenuItem<String>(
                        value: major.code,
                        child: IntrinsicWidth(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              MajorIcon(majorCode: major.code, size: 16),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  major.name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedMajorCode = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),

              // Search Button
              ElevatedButton.icon(
                onPressed: _performSearch,
                icon: const Icon(Icons.search),
                label: const Text('Tìm kiếm'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
      ),
      child: Row(
        children: [
          _buildHeaderCell('STT', 60),
          _buildHeaderCell('Mã số SV', 120),
          _buildHeaderCell('Họ và tên', 200),
          _buildHeaderCell('Tuổi', 80),
          _buildHeaderCell('Email', 250),
          _buildHeaderCell('Số điện thoại', 150),
          _buildHeaderCell('Ngành học', 150),
          _buildHeaderCell('Thao tác', 120),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildTableContent() {
    if (_filteredStudents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy sinh viên nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy thử thay đổi từ khóa tìm kiếm hoặc bộ lọc',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredStudents.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final student = _filteredStudents[index];
        return _buildStudentRow(student, index + 1);
      },
    );
  }

  Widget _buildStudentRow(StudentDetail student, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _buildCell(index.toString(), 60),
          _buildCell(student.studentCode, 120),
          _buildCell(student.name, 200),
          _buildCell(student.age.toString(), 80),
          _buildCell(student.email, 250),
          _buildCell(student.phone, 150),
          _buildCell(student.majorName, 150),
          _buildActionCell(student, 120),
        ],
      ),
    );
  }

  Widget _buildCell(String text, double width) {
    return SizedBox(
      width: width,
      child: Text(
        text,
        style: const TextStyle(fontSize: 14),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildActionCell(StudentDetail student, double width) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          IconButton(
            onPressed: () => _makePhoneCall(student.phone),
            icon: const Icon(Icons.phone, color: Colors.green),
            tooltip: 'Gọi điện',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
          IconButton(
            onPressed: () => _sendEmail(student.email),
            icon: const Icon(Icons.email, color: Colors.blue),
            tooltip: 'Gửi email',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            widget.error!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: widget.onRefresh,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _makePhoneCall(String phoneNumber) {
    // Implementation for phone call
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gọi số: $phoneNumber'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _sendEmail(String email) {
    // Implementation for email
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gửi email đến: $email'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
