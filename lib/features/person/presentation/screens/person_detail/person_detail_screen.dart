import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/ui/app_feedback.dart';
import '../../../../../core/ui/confirm_dialog.dart';
import '../../../../../core/ui/primary_button.dart';
import '../../../../../core/ui/status_message.dart';
import '../../../../../core/utils/app_date_format.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/entities/person.dart';
import '../../viewmodels/person_detail_viewmodel.dart';
import '../../widgets/person_avatar.dart';

class PersonDetailScreen extends StatefulWidget {
  final String personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  PersonDetailViewModel get _viewModel =>
      InjectionContainer.instance.personDetailViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.load(widget.personId);
  }

  @override
  void didUpdateWidget(covariant PersonDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personId != widget.personId) {
      _viewModel.load(widget.personId);
    }
  }

  void _evaluate() {
    context.push(AppRoutes.evaluatePerson(widget.personId));
  }

  void _edit() {
    context.push(AppRoutes.editPerson(widget.personId));
  }

  Future<void> _remove(Person person) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Remover pessoa?',
      message: '"${person.name}" e todas as avaliações recebidas por ela '
          'serão removidas. Essa ação não pode ser desfeita.',
      confirmLabel: 'Remover',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    await _viewModel.removePersonCommand.execute();

    if (!mounted) return;

    final state = _viewModel.removePersonCommand.state.value;

    if (state.isError) {
      AppFeedback.showError(context, state.errorMessage);
      return;
    }

    InjectionContainer.instance.peopleListViewModel.refresh();
    AppFeedback.showSuccess(context, 'Pessoa removida.');

    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.people);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detalhes',
          style: AppTextStyles.sora(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: SignalBuilder(
          builder: (context) {
            final loadState = _viewModel.loadPersonCommand.state.value;
            final person = _viewModel.person.value;

            if (person == null && loadState.isRunning) {
              return const Center(child: CircularProgressIndicator());
            }

            if (person == null) {
              return StatusMessage(
                icon: Icons.person_off_rounded,
                title: 'Pessoa não encontrada',
                message: loadState.isError ? loadState.errorMessage : null,
                actionLabel: 'Tentar novamente',
                onAction: () => _viewModel.load(widget.personId),
              );
            }

            return _DetailContent(
              person: person,
              isCurrentUser: _viewModel.isCurrentUser.value,
              canManage: _viewModel.canManage.value,
              isRemoving: _viewModel.removePersonCommand.state.value.isRunning,
              onEvaluate: _evaluate,
              onEdit: _edit,
              onRemove: () => _remove(person),
            );
          },
        ),
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Person person;
  final bool isCurrentUser;
  final bool canManage;
  final bool isRemoving;
  final VoidCallback onEvaluate;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  const _DetailContent({
    required this.person,
    required this.isCurrentUser,
    required this.canManage,
    required this.isRemoving,
    required this.onEvaluate,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final dim = Theme.of(context).colorScheme.onSurface.withValues(alpha: .6);

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
      children: [
        Center(child: PersonAvatar(name: person.name, size: 96)),
        const SizedBox(height: 14),
        Text(
          person.name,
          textAlign: TextAlign.center,
          style: AppTextStyles.sora(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          '"${person.nickname}"',
          textAlign: TextAlign.center,
          style: AppTextStyles.jakarta(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: dim,
          ),
        ),
        if (isCurrentUser) ...[
          const SizedBox(height: 10),
          const Center(child: _YouBadge()),
        ],
        const SizedBox(height: 22),
        _InfoTile(
          icon: Icons.school_rounded,
          label: 'Curso',
          value: person.course.label,
        ),
        const SizedBox(height: 10),
        _InfoTile(
          icon: Icons.groups_rounded,
          label: 'Turma / ano',
          value: '${person.classYear}',
        ),
        const SizedBox(height: 10),
        _InfoTile(
          icon: Icons.cake_rounded,
          label: 'Data de nascimento',
          value: AppDateFormat.short(person.birthDate),
        ),
        const SizedBox(height: 24),

        // Avaliar: para todos, exceto a própria pessoa (seção 14.12).
        if (isCurrentUser)
          _Notice(
            icon: Icons.block_rounded,
            text: 'Este é o seu perfil. Você não pode avaliar a si mesmo.',
          )
        else
          PrimaryButton(
            label: 'Avaliar',
            icon: Icons.star_rounded,
            onPressed: isRemoving ? null : onEvaluate,
          ),

        const SizedBox(height: 10),

        // Editar/remover: só para quem cadastrou.
        if (canManage) ...[
          PrimaryButton(
            label: 'Editar',
            icon: Icons.edit_rounded,
            color: AppColors.greenDeep,
            onPressed: isRemoving ? null : onEdit,
          ),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Remover',
            icon: Icons.delete_rounded,
            color: AppColors.red,
            isLoading: isRemoving,
            onPressed: onRemove,
          ),
        ] else
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'Somente quem cadastrou esta pessoa pode editá-la ou removê-la.',
              textAlign: TextAlign.center,
              style: AppTextStyles.jakarta(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: dim,
              ),
            ),
          ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.jakarta(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: .55),
                  ),
                ),
                Text(
                  value,
                  style: AppTextStyles.jakarta(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  final IconData icon;
  final String text;

  const _Notice({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.jakarta(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YouBadge extends StatelessWidget {
  const _YouBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.badge_rounded, size: 16, color: AppColors.gold),
          const SizedBox(width: 6),
          Text(
            'Você',
            style: AppTextStyles.jakarta(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.gold,
            ),
          ),
        ],
      ),
    );
  }
}