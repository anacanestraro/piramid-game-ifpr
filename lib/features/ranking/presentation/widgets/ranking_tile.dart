import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/app_number_format.dart';
import '../../../evaluation/domain/entities/criteria_type.dart';
import '../../../evaluation/domain/entities/popularity_tier.dart';
import '../../../person/domain/entities/course.dart';
import '../../../person/presentation/widgets/person_avatar.dart';
import '../../domain/entities/ranking_entry.dart';

// Uma linha do ranking. No global, mostra também a quantidade de avaliações.
class RankingTile extends StatelessWidget {
  final RankingEntry entry;
  final bool showEvaluationCount;
  final VoidCallback onTap;

  const RankingTile({
    super.key,
    required this.entry,
    required this.showEvaluationCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface.withValues(alpha: .6);
    final person = entry.person;
    final medal = _medalColor(entry.position);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: medal?.withValues(alpha: .55) ?? theme.dividerColor,
              width: medal == null ? 1 : 1.6,
            ),
          ),
          child: Row(
            children: [
              _PositionBadge(position: entry.position, medal: medal),
              const SizedBox(width: 10),
              PersonAvatar(name: person.name, size: 42),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.sora(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${person.course.label} · Turma ${person.classYear}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.jakarta(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: dim,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${AppNumberFormat.score(entry.score)} pts',
                    style: AppTextStyles.sora(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                  Text(
                    showEvaluationCount
                        ? AppNumberFormat.evaluations(entry.evaluationCount)
                        : 'de ${CriteriaScoreLimits.maxTotal}',
                    style: AppTextStyles.jakarta(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: dim,
                    ),
                  ),
                  Text(
                    entry.tier.label.toUpperCase(),
                    style: AppTextStyles.jakarta(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .6,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Ouro, prata e bronze para o pódio; null para os demais.
  static Color? _medalColor(int position) {
    switch (position) {
      case 1:
        return AppColors.gold;
      case 2:
        return const Color(0xFF9EA7AD);
      case 3:
        return const Color(0xFFC07A45);
      default:
        return null;
    }
  }
}

class _PositionBadge extends StatelessWidget {
  final int position;
  final Color? medal;

  const _PositionBadge({required this.position, required this.medal});

  @override
  Widget build(BuildContext context) {
    final color = medal;

    return SizedBox(
      width: 34,
      child: color == null
          ? Text(
              '$positionº',
              textAlign: TextAlign.center,
              style: AppTextStyles.sora(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: .55),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.emoji_events_rounded, color: color, size: 22),
                Text(
                  '$positionº',
                  style: AppTextStyles.sora(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
    );
  }
}