import 'package:flutter/material.dart';
import 'package:tui_ibank/models/student_detail.dart';
import 'package:tui_ibank/widgets/student_card.dart';

/// Student Grid Widget - Single Responsibility Principle
class StudentGrid extends StatelessWidget {
  final List<StudentDetail> students;

  const StudentGrid({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double cardWidth = 300.0;
          final int columns = (constraints.maxWidth / cardWidth).floor().clamp(
            1,
            3,
          );

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisExtent: 125,
              crossAxisSpacing: 12,
              mainAxisSpacing: 8,
            ),
            itemCount: students.length,
            itemBuilder: (context, index) {
              return StudentCard(student: students[index]);
            },
          );
        },
      ),
    );
  }
}
