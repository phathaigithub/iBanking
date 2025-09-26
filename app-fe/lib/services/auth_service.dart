import '../models/user.dart';
import '../models/transaction.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  User? get currentUser => _currentUser;

  // TODO: Replace with actual backend authentication
  Future<User?> login(String studentId, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    if (studentId == 'admin' && password == 'admin') {
      _currentUser = User(
        id: 'admin',
        username: 'admin',
        fullName: 'Administrator',
        phoneNumber: '0123456789',
        email: 'admin@tdtu.edu.vn',
        availableBalance: 0,
        transactionHistory: [],
        isAdmin: true,
      );
      return _currentUser;
    } else {
      // Check if student exists with this student ID
      final user = _getValidUser(studentId, password);
      if (user != null) {
        _currentUser = user;
        return _currentUser;
      } else {
        return null; // Invalid credentials
      }
    }
  }

  Future<void> logout() async {
    _currentUser = null;
  }

  void updateCurrentUser(User user) {
    _currentUser = user;
    // TODO: In real app, notify all listeners about user update
    // For now, we rely on widgets to check currentUser directly
  }

  // TODO: Replace with backend user validation
  User? _getValidUser(String studentId, String password) {
    // Static users for demo - TODO: Replace with database lookup
    final validUsers = {
      '52200001': {
        'password': 'pass1',
        'user': User(
          id: '52200001',
          username: '52200001',
          fullName: 'Nguyễn Văn An',
          phoneNumber: '0987654321',
          email: '52200001@student.tdtu.edu.vn',
          availableBalance: 50000000,
          transactionHistory: _generateSampleTransactions('52200001'),
        ),
      },
      '52200002': {
        'password': 'pass2',
        'user': User(
          id: '52200002',
          username: '52200002',
          fullName: 'Trần Thị Bảo',
          phoneNumber: '0987654322',
          email: '52200002@student.tdtu.edu.vn',
          availableBalance: 30000000,
          transactionHistory: _generateSampleTransactions('52200002'),
        ),
      },
      '52200003': {
        'password': 'pass3',
        'user': User(
          id: '52200003',
          username: '52200003',
          fullName: 'Lê Hoàng Châu',
          phoneNumber: '0987654323',
          email: '52200003@student.tdtu.edu.vn',
          availableBalance: 75000000,
          transactionHistory: _generateSampleTransactions('52200003'),
        ),
      },
    };

    if (validUsers.containsKey(studentId)) {
      final userData = validUsers[studentId]!;
      if (userData['password'] == password) {
        return userData['user'] as User;
      }
    }
    return null;
  }

  List<Transaction> _generateSampleTransactions(String userId) {
    return [
      Transaction(
        id: '${userId}_tx001',
        date: DateTime.now().subtract(const Duration(days: 30)),
        amount: 15000000,
        type: TransactionType.tuitionPayment,
        description: 'Thanh toán học phí kỳ 1',
        studentId: userId,
        studentName: 'Nguyễn Văn An',
      ),
      Transaction(
        id: '${userId}_tx002',
        date: DateTime.now().subtract(const Duration(days: 60)),
        amount: 20000000,
        type: TransactionType.deposit,
        description: 'Nạp tiền vào tài khoản',
      ),
    ];
  }
}
