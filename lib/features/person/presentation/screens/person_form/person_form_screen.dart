import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/ui/app_feedback.dart';
import '../../../../../core/ui/primary_button.dart';
import '../../viewmodels/person_form_viewmodel.dart';
import '../../widgets/birth_date_field.dart';
import '../../widgets/class_year_selector.dart';
import '../../widgets/course_selector.dart';
import '../../widgets/form_section_label.dart';
import '../../widgets/signal_text_field.dart';

// Cadastrar (personId == null) ou editar (personId != null) uma pessoa.
class PersonFormScreen extends StatefulWidget {
  final String? personId;

  const PersonFormScreen({super.key, this.personId});

  @override
  State<PersonFormScreen> createState() => _PersonFormScreenState();
}

class _PersonFormScreenState extends State<PersonFormScreen> {
  PersonFormViewModel get _viewModel =>
      InjectionContainer.instance.personFormViewModel;

  @override
  void initState() {
    super.initState();
    _prepareForm();
  }

  @override
  void didUpdateWidget(covariant PersonFormScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.personId != widget.personId) _prepareForm();
  }

  void _prepareForm() {
    final personId = widget.personId;
    if (personId == null) {
      _viewModel.startNew();
    } else {
      _viewModel.startEditing(personId);
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: _viewModel.birthDate.value ?? DateTime(now.year - 18),
      firstDate: DateTime(1950),
      lastDate: now,
      helpText: 'Data de nascimento',
    );

    if (picked != null) _viewModel.birthDate.value = picked;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();

    final wasEditing = _viewModel.isEditing.value;
    final state = await _viewModel.save();

    if (!mounted) return;

    if (state.isError) {
      AppFeedback.showError(context, state.errorMessage);
      return;
    }

    if (!state.isSuccess) return;

    // Atualiza as telas que mostram essa pessoa.
    final container = InjectionContainer.instance;
    container.peopleListViewModel.refresh();
    final personId = widget.personId;
    if (wasEditing && personId != null) {
      container.personDetailViewModel.load(personId);
    }

    AppFeedback.showSuccess(
      context,
      wasEditing ? 'Pessoa atualizada!' : 'Pessoa cadastrada!',
    );
    _close();
  }

  void _close() {
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
        title: SignalBuilder(
          builder: (context) => Text(
            _viewModel.isEditing.value ? 'Editar pessoa' : 'Nova pessoa',
            style: AppTextStyles.sora(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: SignalBuilder(
          builder: (context) {
            final loadState = _viewModel.loadPersonCommand.state.value;

            if (loadState.isRunning) {
              return const Center(child: CircularProgressIndicator());
            }

            if (loadState.isError) {
              return _LoadError(
                message: loadState.errorMessage,
                onRetry: _prepareForm,
              );
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    // Trocar a key recria os campos com os valores atuais.
                    key: ValueKey(_viewModel.formVersion.value),
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 24),
                    children: [
                      const FormSectionLabel('Perfil'),
                      SignalTextField(
                        signal: _viewModel.name,
                        hint: 'Nome completo',
                        icon: Icons.person_rounded,
                      ),
                      const SizedBox(height: 11),
                      SignalTextField(
                        signal: _viewModel.nickname,
                        hint: 'Apelido',
                        icon: Icons.tag_faces_rounded,
                      ),
                      const FormSectionLabel('Curso'),
                      CourseSelector(signal: _viewModel.course),
                      const FormSectionLabel('Turma / ano'),
                      ClassYearSelector(signal: _viewModel.classYear),
                      const FormSectionLabel('Data de nascimento'),
                      BirthDateField(
                        signal: _viewModel.birthDate,
                        onTap: _pickBirthDate,
                      ),
                      const FormSectionLabel('Vínculo com a conta'),
                      _IsMeSwitch(signal: _viewModel.isMe),
                    ],
                  ),
                ),
                _SaveBar(viewModel: _viewModel, onSave: _save),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _IsMeSwitch extends StatelessWidget {
  final Signal<bool> signal;

  const _IsMeSwitch({required this.signal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SignalBuilder(
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: theme.dividerColor, width: 1.5),
          ),
          child: SwitchListTile(
            value: signal.value,
            onChanged: (value) => signal.value = value,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            secondary: const Icon(Icons.badge_rounded),
            title: Text(
              'Esta pessoa sou eu',
              style: AppTextStyles.jakarta(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              'Vincula este perfil à sua conta. '
              'Você não poderá avaliar a si mesmo.',
              style: AppTextStyles.jakarta(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: theme.colorScheme.onSurface.withValues(alpha: .6),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SaveBar extends StatelessWidget {
  final PersonFormViewModel viewModel;
  final VoidCallback onSave;

  const _SaveBar({required this.viewModel, required this.onSave});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: SignalBuilder(
        builder: (context) {
          final isSaving = viewModel.isSaving.value;
          final canSubmit = viewModel.canSubmit.value;

          return PrimaryButton(
            label: viewModel.isEditing.value
                ? 'Salvar alterações'
                : 'Cadastrar pessoa',
            icon: Icons.check_rounded,
            isLoading: isSaving,
            onPressed: canSubmit ? onSave : null,
          );
        },
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            TextButton(onPressed: onRetry, child: const Text('Tentar novamente')),
          ],
        ),
      ),
    );
  }
}