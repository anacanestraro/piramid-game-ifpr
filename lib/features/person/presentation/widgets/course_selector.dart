import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../domain/entities/course.dart';
import 'selectable_chip.dart';

// Seleção do curso (INFO, MEC, MAMB, PROD, TADS, TGA) em chips.
class CourseSelector extends StatelessWidget {
  final Signal<Course> signal;

  const CourseSelector({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final selected = signal.value;

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Course.values.map((course) {
            return SelectableChip(
              label: course.label,
              isSelected: course == selected,
              onTap: () => signal.value = course,
            );
          }).toList(),
        );
      },
    );
  }
}