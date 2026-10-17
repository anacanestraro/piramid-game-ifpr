import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/criteria_type.dart';

// Um critério: nome, descrição e 5 estrelas tocáveis (Star Rating).
class StarRatingRow extends StatelessWidget {
  final CriteriaType criteria;
  final Signal<int> signal;
  final ValueChanged<int> onChanged;

  const StarRatingRow({
    super.key,
    required this.criteria,
    required this.signal,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dim = theme.colorScheme.onSurface;

    return SignalBuilder(
      builder: (context) {
        final current = signal.value;

        return Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: current > 0
                  ? AppColors.green.withValues(alpha: .35)
                  : theme.dividerColor,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      criteria.label,
                      style: AppTextStyles.jakarta(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  for (var star = 1; star <= 5; star++)
                    _Star(
                      isFilled: star <= current,
                      tooltip: '$star de 5',
                      onTap: () => onChanged(star),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                criteria.description,
                style: AppTextStyles.jakarta(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: dim.withValues(alpha: .55),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Star extends StatelessWidget {
  final bool isFilled;
  final String tooltip;
  final VoidCallback onTap;

  const _Star({
    required this.isFilled,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final empty = Theme.of(context).colorScheme.onSurface.withValues(alpha: .3);

    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 18,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            size: 26,
            color: isFilled ? AppColors.gold : empty,
          ),
        ),
      ),
    );
  }
}