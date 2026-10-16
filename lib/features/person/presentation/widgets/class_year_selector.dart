import 'package:flutter/material.dart';
import 'package:signals/signals.dart';
import '../../domain/usecases/person_validator.dart';

// Seleção da turma/ano entre 1998 e 2026, sem digitação (seção 8.2).
// Os limites vêm do PersonValidator: a regra fica num lugar só.
class ClassYearSelector extends StatelessWidget {
  final Signal<int> signal;

  const ClassYearSelector({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final years = [
      for (var year = PersonValidator.maxClassYear;
          year >= PersonValidator.minClassYear;
          year--)
        year,
    ];

    return DropdownMenu<int>(
      initialSelection: signal.peek(),
      expandedInsets: EdgeInsets.zero,
      menuHeight: 300,
      // Impede digitar no campo (no Chrome ele viraria um campo de texto).
      requestFocusOnTap: false,
      leadingIcon: const Icon(Icons.school_rounded),
      onSelected: (year) {
        if (year != null) signal.value = year;
      },
      dropdownMenuEntries: [
        for (final year in years)
          DropdownMenuEntry(value: year, label: '$year'),
      ],
    );
  }
}