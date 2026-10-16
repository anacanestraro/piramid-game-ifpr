import 'package:flutter/material.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/person.dart';
import 'person_avatar.dart';

// Item da lista de pessoas: nome, apelido, curso e turma (seção 14.6).
class PersonCard extends StatelessWidget {
  final Person person;
  final VoidCallback onTap;

  const PersonCard({super.key, required this.person, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface.withValues(alpha: .6);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            children: [
              PersonAvatar(name: person.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '"${person.nickname}"',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.jakarta(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: dim,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${person.course.label} · Turma ${person.classYear}',
                      style: AppTextStyles.jakarta(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: dim),
            ],
          ),
        ),
      ),
    );
  }
}