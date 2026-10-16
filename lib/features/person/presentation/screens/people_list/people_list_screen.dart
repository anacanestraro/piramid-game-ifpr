import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signals_flutter/signals_flutter.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/router/app_routes.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/ui/status_message.dart';
import '../../viewmodels/people_list_viewmodel.dart';
import '../../widgets/person_card.dart';

class PeopleListScreen extends StatefulWidget {
  const PeopleListScreen({super.key});

  @override
  State<PeopleListScreen> createState() => _PeopleListScreenState();
}

class _PeopleListScreenState extends State<PeopleListScreen> {
  PeopleListViewModel get _viewModel =>
      InjectionContainer.instance.peopleListViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.newPerson),
        backgroundColor: AppColors.green,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Nova pessoa'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding direito maior: os botões de tema/sair ficam por cima.
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 120, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pessoas', style: AppTextStyles.screenTitle),
                  const SizedBox(height: 2),
                  Text(
                    'Quem está na disputa pelo Nível Lenda',
                    style: AppTextStyles.jakarta(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface.withValues(alpha: .6),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
              child: _SearchField(
                onChanged: (value) => _viewModel.searchTerm.value = value,
              ),
            ),
            Expanded(
              child: SignalBuilder(
                builder: (context) => _buildContent(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final loadState = _viewModel.loadPeopleCommand.state.value;
    final allPeople = _viewModel.people.value;
    final visiblePeople = _viewModel.filteredPeople.value;

    if (allPeople.isEmpty && loadState.isRunning) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allPeople.isEmpty && loadState.isError) {
      return StatusMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Não foi possível carregar',
        message: loadState.errorMessage,
        actionLabel: 'Tentar novamente',
        onAction: _viewModel.refresh,
      );
    }

    if (allPeople.isEmpty) {
      return const StatusMessage(
        icon: Icons.groups_rounded,
        title: 'Ninguém cadastrado ainda',
        message: 'Toque em "Nova pessoa" para começar a disputa.',
      );
    }

    if (visiblePeople.isEmpty) {
      return const StatusMessage(
        icon: Icons.search_off_rounded,
        title: 'Nenhum resultado',
        message: 'Tente buscar por outro nome ou apelido.',
      );
    }

    return RefreshIndicator(
      onRefresh: _viewModel.refresh,
      child: ListView.separated(
        // Espaço no fim para o botão flutuante não cobrir o último item.
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 96),
        itemCount: visiblePeople.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final person = visiblePeople[index];
          return PersonCard(
            person: person,
            onTap: () => context.push(AppRoutes.personDetail(person.id)),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const _SearchField({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    OutlineInputBorder border(Color color) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: color, width: 1.5),
      );
    }

    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: AppTextStyles.jakarta(fontSize: 15, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: 'Buscar por nome ou apelido',
        prefixIcon: const Icon(Icons.search_rounded),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: border(theme.dividerColor),
        enabledBorder: border(theme.dividerColor),
        focusedBorder: border(AppColors.green),
      ),
    );
  }
}