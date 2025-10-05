import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tui_ibank/utils/context_utils.dart';
import 'package:tui_ibank/widgets/refresh_button.dart';
import 'package:tui_ibank/widgets/student_table.dart';
import 'package:tui_ibank/widgets/major_icon.dart';
import 'package:tui_ibank/widgets/add_student_dialog.dart';
import 'package:tui_ibank/widgets/tuition_table.dart';
import 'package:tui_ibank/widgets/tuition_search_card.dart';
import '../providers/auth_provider.dart';
import '../providers/admin_provider.dart';
import '../providers/admin_tuition_provider.dart';
import '../models/api/tuition_response.dart';
import '../utils/app_theme.dart';
import 'create_tuition_period_view.dart';

class AdminDashboardView extends ConsumerStatefulWidget {
  const AdminDashboardView({super.key});

  @override
  ConsumerState<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends ConsumerState<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    // Load majors on init
    Future.microtask(() {
      ref.read(adminDashboardProvider.notifier).loadMajors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final adminState = ref.watch(adminDashboardProvider);
    final isMobile = ContextUtils.isMobile(
      context: context,
      thresholdWidth: 1400,
    );

    return Scaffold(
      body: isMobile
          ? _buildMobilePlaceholder()
          : _buildDesktopView(user, adminState),
    );
  }

  Widget _buildDesktopView(user, AdminDashboardState adminState) {
    return Row(
      children: [
        // Sidebar
        _buildSidebar(context, adminState),

        // Main content
        Expanded(
          child: Column(
            children: [
              // Top bar
              _buildTopBar(context, user),

              // Content area
              Expanded(child: _buildContent(context, adminState)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobilePlaceholder() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.desktop_windows, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Admin Dashboard chỉ hỗ trợ giao diện desktop.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Vui lòng sử dụng máy tính hoặc thu nhỏ cửa sổ trình duyệt.',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, AdminDashboardState state) {
    return Container(
      width: 250,
      color: AppColors.primary,
      child: Column(
        children: [
          // Logo/Header
          Container(
            padding: const EdgeInsets.all(24),
            child: const Column(
              children: [
                Icon(Icons.admin_panel_settings, size: 48, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          // Menu items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  icon: Icons.school,
                  title: 'Ngành học & Sinh viên',
                  isSelected:
                      state.currentTab == AdminViewTab.majorsAndStudents,
                  onTap: () {
                    ref
                        .read(adminDashboardProvider.notifier)
                        .setTab(AdminViewTab.majorsAndStudents);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.payment,
                  title: 'Học phí',
                  isSelected: state.currentTab == AdminViewTab.tuition,
                  onTap: () {
                    ref
                        .read(adminDashboardProvider.notifier)
                        .setTab(AdminViewTab.tuition);
                  },
                ),
                _buildMenuItem(
                  icon: Icons.add_circle,
                  title: 'Tạo đợt đóng học phí',
                  isSelected:
                      state.currentTab == AdminViewTab.createTuitionPeriod,
                  onTap: () {
                    ref
                        .read(adminDashboardProvider.notifier)
                        .setTab(AdminViewTab.createTuitionPeriod);
                  },
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          // Logout button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Chào mừng, ${user?.fullName ?? "Admin"}',
              style: AppTextStyles.heading2,
            ),
          ),
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              user?.fullName?.substring(0, 1).toUpperCase() ?? 'A',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AdminDashboardState state) {
    switch (state.currentTab) {
      case AdminViewTab.majorsAndStudents:
        return _buildMajorsAndStudentsView(state);
      case AdminViewTab.tuition:
        return _buildTuitionView();
      case AdminViewTab.createTuitionPeriod:
        return const CreateTuitionPeriodView();
    }
  }

  Widget _buildMajorsAndStudentsView(AdminDashboardState state) {
    return Column(
      children: [
        // Tab switcher
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              SizedBox(
                width: 320, // 2 buttons, each 160 width
                child: SegmentedButton<MajorStudentTab>(
                  segments: const [
                    ButtonSegment(
                      value: MajorStudentTab.majors,
                      label: Text('Ngành học'),
                      icon: Icon(Icons.business),
                    ),
                    ButtonSegment(
                      value: MajorStudentTab.students,
                      label: Text('Sinh viên'),
                      icon: Icon(Icons.people),
                    ),
                  ],
                  selected: {state.majorStudentTab},
                  onSelectionChanged: (Set<MajorStudentTab> newSelection) {
                    ref
                        .read(adminDashboardProvider.notifier)
                        .setMajorStudentTab(newSelection.first);
                  },
                ),
              ),
              const Spacer(),
              if (state.majorStudentTab == MajorStudentTab.students)
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddStudentDialog(),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm sinh viên'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Content based on selected tab
        Expanded(
          child: state.majorStudentTab == MajorStudentTab.majors
              ? _buildMajorsContent(state)
              : _buildStudentsContent(state),
        ),
      ],
    );
  }

  Widget _buildMajorsContent(AdminDashboardState state) {
    if (state.isLoadingMajors) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMajors != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(state.errorMajors!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(adminDashboardProvider.notifier).loadMajors();
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (state.majors.isEmpty) {
      return const Center(child: Text('Không có ngành học nào'));
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text('Danh sách ngành học', style: AppTextStyles.heading3),
                  const Spacer(),
                  Text(
                    'Tổng: ${state.majors.length} ngành',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  RefreshButton(
                    isLoading: state.isLoadingMajors,
                    onPressed: () {
                      ref.read(adminDashboardProvider.notifier).loadMajors();
                    },
                    tooltip: 'Làm mới danh sách ngành học',
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: state.majors.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final major = state.majors[index];
                  return ListTile(
                    leading: MajorIcon(majorCode: major.code),
                    title: Text(
                      major.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Mã ngành: ${major.code}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Text(
                        'ID: ${major.id}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsContent(AdminDashboardState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: StudentTable(
        students: state.students,
        majors: state.majors,
        isLoading: state.isLoadingStudents,
        error: state.errorStudents,
        onRefresh: () {
          ref.read(adminDashboardProvider.notifier).loadStudents();
        },
      ),
    );
  }

  Widget _buildTuitionView() {
    final tuitionState = ref.watch(adminTuitionProvider);
    final tuitionNotifier = ref.read(adminTuitionProvider.notifier);

    return Column(
      children: [
        // View mode switcher
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              SizedBox(
                width: 400, // Increased width as requested
                child: SegmentedButton<TuitionViewMode>(
                  segments: const [
                    ButtonSegment(
                      value: TuitionViewMode.all,
                      label: Text('Tất cả'),
                      icon: Icon(Icons.list),
                    ),
                    ButtonSegment(
                      value: TuitionViewMode.byMajor,
                      label: Text('Xem theo ngành'),
                      icon: Icon(Icons.business),
                    ),
                  ],
                  selected: {tuitionState.viewMode},
                  onSelectionChanged: (Set<TuitionViewMode> newSelection) {
                    tuitionNotifier.setViewMode(newSelection.first);
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Semester dropdown moved to the right of segment button
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  initialValue: tuitionState.selectedSemester,
                  decoration: InputDecoration(
                    labelText: 'Học kỳ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: tuitionState.availableSemestersForDropdown.map((
                    semester,
                  ) {
                    if (semester == 'Tất cả học kỳ') {
                      return DropdownMenuItem(
                        value: semester,
                        child: Text(semester),
                      );
                    }
                    // Create a temporary TuitionResponse to get formatted display
                    final tempTuition = TuitionResponse(
                      tuitionCode: '',
                      studentCode: '',
                      semester: semester,
                      amount: 0,
                      status: '',
                    );
                    return DropdownMenuItem(
                      value: semester,
                      child: Text(tempTuition.semesterDisplay),
                    );
                  }).toList(),
                  onChanged: (value) {
                    tuitionNotifier.setSelectedSemester(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Major dropdown moved to the right of semester dropdown
              if (tuitionState.viewMode == TuitionViewMode.byMajor)
                SizedBox(
                  width: 250,
                  child: DropdownButtonFormField<String>(
                    initialValue: tuitionState.selectedMajorCode,
                    decoration: InputDecoration(
                      labelText: 'Ngành học',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    items: tuitionState.majors.map((major) {
                      return DropdownMenuItem(
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
                    }).toList(),
                    onChanged: (value) {
                      tuitionNotifier.setSelectedMajor(value);
                    },
                  ),
                ),
              const Spacer(),
              // Refresh button
              RefreshButton(
                onPressed: () {
                  tuitionNotifier.refreshTuitions();
                },
                isLoading: tuitionState.isLoading,
                tooltip: 'Làm mới danh sách học phí',
              ),
            ],
          ),
        ),

        // Search and filter card
        const TuitionSearchCard(),

        // Results summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                'Tìm thấy ${tuitionState.filteredTuitions.length} học phí',
                style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
              ),
              const Spacer(),
              if (tuitionState.error != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        tuitionState.error!,
                        style: TextStyle(color: Colors.red[700], fontSize: 12),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Tuition table
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: TuitionTable(
              tuitions: tuitionState.filteredTuitions,
              isLoading: tuitionState.isLoading,
              error: tuitionState.error,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi hệ thống quản trị?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Đăng xuất'),
            ),
          ],
        );
      },
    );

    if (result == true && mounted) {
      await ref.read(authProvider.notifier).logout();
    }
  }
}
