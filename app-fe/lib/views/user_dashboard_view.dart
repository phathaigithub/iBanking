import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import 'payment_view.dart';
import 'tuition_lookup_view.dart';
import 'account_info_view.dart';

class UserDashboardView extends StatefulWidget {
  const UserDashboardView({Key? key}) : super(key: key);

  @override
  State<UserDashboardView> createState() => _UserDashboardViewState();
}

class _UserDashboardViewState extends State<UserDashboardView> {
  int _currentIndex = 0;

  // Use late initialization to preserve state better
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      PaymentView(
        key: const PageStorageKey('payment_view'),
        onPaymentSuccess: () => _switchToTab(1), // Switch to lookup tab
      ),
      const TuitionLookupView(
        key: PageStorageKey('tuition_lookup_view'),
        initiallyShowMyTuition: true,
      ),
      const AccountInfoView(key: PageStorageKey('account_info_view')),
    ];
  }

  void _switchToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TUI iBanking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Thanh toán',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tra cứu'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Thông tin'),
        ],
      ),
    );
  }

  Future<void> _showLogoutDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất khỏi ứng dụng?'),
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
