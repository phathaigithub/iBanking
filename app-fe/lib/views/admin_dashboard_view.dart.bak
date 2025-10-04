import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/admin_viewmodel.dart';
import '../utils/app_theme.dart';
import '../utils/helpers.dart';
import 'tuition_management_view.dart';
import 'add_student_view.dart';

class AdminDashboardView extends StatefulWidget {
  const AdminDashboardView({Key? key}) : super(key: key);

  @override
  State<AdminDashboardView> createState() => _AdminDashboardViewState();
}

class _AdminDashboardViewState extends State<AdminDashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminViewModel>(context, listen: false).loadStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TUI iBanking - Admin Dashboard'),
        actions: [
          Consumer<AuthViewModel>(
            builder: (context, authVM, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.admin_panel_settings),
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(authVM.currentUser?.fullName ?? ''),
                      subtitle: const Text('Administrator'),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Đăng xuất'),
                    ),
                  ),
                ],
                onSelected: (String value) {
                  if (value == 'logout') {
                    _logout(context);
                  }
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AdminViewModel>(
        builder: (context, adminVM, child) {
          if (adminVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminVM.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                  const SizedBox(height: 16),
                  Text(
                    adminVM.errorMessage!,
                    style: AppTextStyles.body1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminVM.loadStudents(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWideScreen = constraints.maxWidth > 1000;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Period selector
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Chọn học kỳ để xem thống kê',
                              style: AppTextStyles.heading3,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: adminVM.selectedPeriodId,
                                    hint: const Text('Tất cả học kỳ'),
                                    decoration: const InputDecoration(
                                      labelText: 'Học kỳ',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      ...adminVM.availablePeriods.map((
                                        periodId,
                                      ) {
                                        return DropdownMenuItem<String>(
                                          value: periodId,
                                          child: Text(
                                            adminVM.getPeriodDisplayName(
                                              periodId,
                                            ),
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: (value) {
                                      adminVM.selectPeriod(value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistics cards
                    if (isWideScreen)
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Tổng số sinh viên',
                              adminVM.totalStudents.toString(),
                              Icons.people,
                              AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Đã thanh toán',
                              adminVM.paidStudents.toString(),
                              Icons.check_circle,
                              Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Chưa thanh toán',
                              adminVM.unpaidStudents.toString(),
                              Icons.pending,
                              Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Tổng đã thu',
                              CurrencyFormatter.formatWithoutSymbol(
                                adminVM.totalRevenue,
                              ),
                              Icons.account_balance_wallet,
                              Colors.blue,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Tổng số sinh viên',
                                  adminVM.totalStudents.toString(),
                                  Icons.people,
                                  AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Đã thanh toán',
                                  adminVM.paidStudents.toString(),
                                  Icons.check_circle,
                                  Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Chưa thanh toán',
                                  adminVM.unpaidStudents.toString(),
                                  Icons.pending,
                                  Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStatCard(
                                  'Tổng đã thu',
                                  CurrencyFormatter.formatWithoutSymbol(
                                    adminVM.totalRevenue,
                                  ),
                                  Icons.account_balance_wallet,
                                  Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    // Students list
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Danh sách sinh viên',
                                  style: AppTextStyles.heading3,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: () => adminVM.loadStudents(),
                                  tooltip: 'Làm mới',
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            if (adminVM.students.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Text(
                                    'Không có dữ liệu sinh viên',
                                    style: AppTextStyles.body1,
                                  ),
                                ),
                              )
                            else
                              _buildStudentsTable(adminVM, isWideScreen),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: PopupMenuButton<String>(
        child: FloatingActionButton.extended(
          onPressed: null,
          icon: const Icon(Icons.manage_accounts),
          label: const Text('Quản lý'),
          tooltip: 'Các chức năng quản lý',
        ),
        itemBuilder: (context) => [
          // const PopupMenuItem<String>(
          //   value: 'add_student',
          //   child: ListTile(
          //     leading: Icon(Icons.person_add),
          //     title: Text('Thêm sinh viên'),
          //   ),
          // ),
          const PopupMenuItem<String>(
            value: 'add_tuition_period',
            child: ListTile(
              leading: Icon(Icons.add_circle),
              title: Text('Thêm đợt đóng học phí'),
            ),
          ),
        ],
        onSelected: (String value) async {
          if (value == 'add_student') {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(builder: (context) => const AddStudentView()),
            );

            // If student was created successfully, refresh data
            if (result == true && mounted) {
              final adminVM = Provider.of<AdminViewModel>(
                context,
                listen: false,
              );
              await adminVM.refreshData();
            }
          } else if (value == 'add_tuition_period') {
            final result = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (context) => const TuitionManagementView(),
              ),
            );

            // If tuition period was created successfully, refresh data
            if (result == true && mounted) {
              final adminVM = Provider.of<AdminViewModel>(
                context,
                listen: false,
              );
              await adminVM.refreshData();
            }
          }
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    value,
                    style: AppTextStyles.heading3.copyWith(color: color),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsTable(AdminViewModel adminVM, bool isWideScreen) {
    if (isWideScreen) {
      return Table(
        border: TableBorder.all(color: Colors.grey[300]!, width: 1),
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(3),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
            ),
            children: [
              _buildTableHeader('Mã số SV'),
              _buildTableHeader('Họ và tên'),
              _buildTableHeader('Học phí'),
              _buildTableHeader('Trạng thái'),
            ],
          ),
          ...adminVM.students.map((student) {
            final latestTuition = adminVM.getLatestTuitionForStudent(
              student.studentId,
            );
            final tuitionStatus = adminVM.getTuitionStatus(student.studentId);
            final statusColor = adminVM.getTuitionStatusColor(
              student.studentId,
            );

            return TableRow(
              children: [
                _buildTableCell(student.studentId),
                _buildTableCell(student.fullName),
                _buildTableCell(
                  latestTuition != null
                      ? CurrencyFormatter.format(latestTuition.amount)
                      : 'N/A',
                ),
                _buildTableCell(tuitionStatus, textColor: statusColor),
              ],
            );
          }),
        ],
      );
    } else {
      return Column(
        children: adminVM.students.map((student) {
          final latestTuition = adminVM.getLatestTuitionForStudent(
            student.studentId,
          );
          final tuitionStatus = adminVM.getTuitionStatus(student.studentId);
          final statusColor = adminVM.getTuitionStatusColor(student.studentId);
          final hasAnyTuition = adminVM.hasAnyTuition(student.studentId);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: hasAnyTuition
                    ? (adminVM.hasUnpaidTuition(student.studentId)
                          ? Colors.orange
                          : Colors.green)
                    : Colors.grey,
                child: Icon(
                  hasAnyTuition
                      ? (adminVM.hasUnpaidTuition(student.studentId)
                            ? Icons.pending
                            : Icons.check)
                      : Icons.school,
                  color: Colors.white,
                ),
              ),
              title: Text(student.fullName),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MSSV: ${student.studentId}'),
                  Text(
                    latestTuition != null
                        ? CurrencyFormatter.format(latestTuition.amount)
                        : 'Không có học phí',
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: hasAnyTuition
                      ? (adminVM.hasUnpaidTuition(student.studentId)
                            ? Colors.orange.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1))
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tuitionStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      );
    }
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        style: AppTextStyles.body1.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text, {Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(text, style: AppTextStyles.body2.copyWith(color: textColor)),
    );
  }

  Future<void> _logout(BuildContext context) async {
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
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      await authVM.logout();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
