import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/ui/app_feedback.dart';
import '../../../../../core/ui/primary_button.dart';
import '../../../../../core/ui/status_message.dart';
import '../../../../../core/utils/app_date_format.dart';
import '../../../../person/domain/entities/person.dart';
import '../../../../person/presentation/widgets/person_avatar.dart';
import '../../../domain/entities/criteria_type.dart';
import '../../../domain/entities/popularity_tier.dart';
import '../../viewmodels/evaluation_form_viewmodel.dart';
import '../../widgets/star_rating_row.dart';

// Avaliar uma pessoa pela primeira vez ou alterar a avaliação existente.
class EvaluationFormScreen extends StatefulWidget {
  final String personId;

  const EvaluationFormScreen({super.key, required this.personId});

  @override
  State<EvaluationFormScreen> createState() => _EvaluationFormScreenState();
}

class _EvaluationFormScreenState extends State<EvaluationFormScreen> {
  EvaluationFormViewModel get _viewModel =>
      InjectionContainer.instance.evaluationFormViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load(widget.personId);
  }

  @override
  void didUpdateWidget(covariant EvaluationFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personId != widget.personId) {
      _viewModel.load(widget.personId);
    }
  }

  Future<void> _save() async {
    // Guardado antes: depois de salvar, isEditing passa a ser true.
    final wasEditing = _viewModel.isEditing.value;

    await _viewModel.evaluatePersonCommand.execute();

    if (!mounted) return;

    final state = _viewModel.evaluatePersonCommand.state.value;

    if (state.isError) {
      AppFeedback.showError(context, state.errorMessage);
      return;
    }

    if (!state.isSuccess) return;

    AppFeedback.showSuccess(
      context,
      wasEditing ? 'Avaliação atualizada!' : 'Avaliação registrada!',
    );
    _close();
  }

  void _close() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.personDetail(widget.personId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: SignalBuilder(
          builder: (context) => Text(
            _viewModel.isEditing.value ? 'Alterar avaliação' : 'Avaliar',
            style:
                AppTextStyles.sora(fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      body: SafeArea(
        child: SignalBuilder(
          builder: (context) {
            final loadState = _viewModel.loadCommand.state.value;
            final person = _viewModel.person.value;

            if (loadState.isRunning) {
              return const Center(child: CircularProgressIndicator());
            }

            if (loadState.isError || person == null) {
              return StatusMessage(
                icon: Icons.cloud_off_rounded,
                title: 'Não foi possível abrir a avaliação',
                message: loadState.isError ? loadState.errorMessage : null,
                actionLabel: 'Tentar novamente',
                onAction: () => _viewModel.load(widget.personId),
              );
            }

            if (_viewModel.isSelf.value) {
              return const StatusMessage(
                icon: Icons.block_rounded,
                title: 'Você não pode avaliar a si mesmo',
                message: 'Este perfil está vinculado à sua conta. '
                    'Avalie seus colegas para movimentar o ranking!',
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
                    children: [
                      _PersonHeader(
                        person: person,
                        evaluatedAt: _viewModel.existing.value?.evaluatedAt,
                      ),
                      const SizedBox(height: 18),
                      _ProgressLabel(viewModel: _viewModel),
                      const SizedBox(height: 10),
                      for (final criteria in CriteriaType.values) ...[
                        StarRatingRow(
                          criteria: criteria,
                          signal: _viewModel.scores[criteria]!,
                          onChanged: (value) =>
                              _viewModel.setScore(criteria, value),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                _ScoreBar(viewModel: _viewModel, onSave: _save),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PersonHeader extends StatelessWidget {
  final Person person;
  final DateTime? evaluatedAt;

  const _PersonHeader({required this.person, required this.evaluatedAt});

  @override
  Widget build(BuildContext context) {
    final dim = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);
    final date = evaluatedAt;

    return Row(
      children: [
        PersonAvatar(name: person.name, size: 56),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.name,
                style: AppTextStyles.sora(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                date == null
                    ? 'Primeira avaliação'
                    : 'Sua última avaliação: ${AppDateFormat.short(date)}',
                style: AppTextStyles.jakarta(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: dim,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProgressLabel extends StatelessWidget {
  final EvaluationFormViewModel viewModel;

  const _ProgressLabel({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return SignalBuilder(
      builder: (context) {
        final rated = viewModel.ratedCount.value;
        final total = CriteriaType.values.length;

        return Text(
          'CRITÉRIOS · $rated/$total AVALIADOS',
          style: AppTextStyles.jakarta(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}

// Rodapé fixo: pontuação, nível e botão de salvar.
class _ScoreBar extends StatelessWidget {
  final EvaluationFormViewModel viewModel;
  final VoidCallback onSave;

  const _ScoreBar({required this.viewModel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SignalBuilder(
        builder: (context) {
          final isComplete = viewModel.isComplete.value;
          final isSaving =
              viewModel.evaluatePersonCommand.state.value.isRunning;

          return Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${viewModel.totalScore.value} / '
                    '${CriteriaScoreLimits.maxTotal}',
                    style: AppTextStyles.sora(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: AppColors.green,
                    ),
                  ),
                  Text(
                    'NÍVEL ${viewModel.tier.value.label.toUpperCase()}',
                    style: AppTextStyles.jakarta(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .6,
                      color: AppColors.gold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButton(
                  label: !isComplete
                      ? 'Avalie todos os critérios'
                      : viewModel.isEditing.value
                          ? 'Salvar alterações'
                          : 'Registrar avaliação',
                  icon: isComplete ? Icons.check_rounded : null,
                  isLoading: isSaving,
                  onPressed: isComplete ? onSave : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}