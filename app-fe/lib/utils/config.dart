/// Configuration constants for the TUI iBanking application
class AppConfig {
  /// The month when the new academic year starts (August = 8)
  static const int newYearMonth = 8;

  /// Default tuition fee amount (15 million VND)
  static const double defaultTuitionFee = 15000000.0;

  /// Semester due date configurations
  static const Map<int, SemesterDueDates> semesterDueDates = {
    1: SemesterDueDates(
      startMonth: 9,
      startDay: 1,
      endMonth: 9,
      endDay: 15,
      yearOffset: 0, // Same academic year
    ),
    2: SemesterDueDates(
      startMonth: 2,
      startDay: 1,
      endMonth: 2,
      endDay: 15,
      yearOffset: 1, // Next calendar year
    ),
    3: SemesterDueDates(
      startMonth: 6,
      startDay: 1,
      endMonth: 6,
      endDay: 15,
      yearOffset: 1, // Next calendar year
    ),
  };
}

class SemesterDueDates {
  final int startMonth;
  final int startDay;
  final int endMonth;
  final int endDay;
  final int yearOffset; // 0 for same year, 1 for next year

  const SemesterDueDates({
    required this.startMonth,
    required this.startDay,
    required this.endMonth,
    required this.endDay,
    required this.yearOffset,
  });
}
