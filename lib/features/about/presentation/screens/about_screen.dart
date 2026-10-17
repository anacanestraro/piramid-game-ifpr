import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../evaluation/domain/entities/criteria_type.dart';
import '../../../evaluation/domain/entities/popularity_tier.dart';

// Tela "Sobre o App" (seção 20 da especificação).
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          children: [
            // Padding à direita: os botões de tema/sair ficam por cima.
            Padding(
              padding: const EdgeInsets.only(right: 100),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Sobre o app',
                      style: AppTextStyles.screenTitle,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const _InfoCard(
              icon: Icons.emoji_events_rounded,
              iconColor: AppColors.gold,
              title: 'O que é o PiramidGame',
              child: _Paragraphs([
                'O PiramidGame IFPR-Pgua é um aplicativo desenvolvido em '
                    'Flutter para fins didáticos.',
                'Ele permite cadastrar pessoas do IFPR – Campus Paranaguá e '
                    'avaliá-las em critérios descontraídos de convivência, '
                    'destaque e participação, sempre dentro do respeito.',
              ]),
            ),
            const SizedBox(height: 14),

            _InfoCard(
              icon: Icons.star_rounded,
              iconColor: AppColors.gold,
              title: 'Os ${CriteriaType.values.length} critérios',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Paragraphs([
                    'Cada critério recebe uma nota de 1 a 5 estrelas. '
                        'Para registrar uma avaliação, todos precisam ser '
                        'avaliados.',
                  ]),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final criteria in CriteriaType.values)
                        _Tag(criteria.label),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            _InfoCard(
              icon: Icons.calculate_rounded,
              iconColor: AppColors.green,
              title: 'Nível Lenda',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Paragraphs([
                    'A soma das 15 notas de uma avaliação forma o Nível Lenda.',
                  ]),
                  const SizedBox(height: 12),
                  _ScoreRange(maxTotal: CriteriaScoreLimits.maxTotal),
                  const SizedBox(height: 12),
                  const _TierTable(),
                ],
              ),
            ),
            const SizedBox(height: 14),

            const _InfoCard(
              icon: Icons.person_rounded,
              iconColor: AppColors.green,
              title: 'Ranking Pessoal',
              child: _Paragraphs([
                'Responde: "Na minha opinião, quem possui o maior Nível Lenda?"',
                'Considera somente as avaliações feitas por você. As notas '
                    'dos outros usuários não interferem nele.',
              ]),
            ),
            const SizedBox(height: 14),

            const _InfoCard(
              icon: Icons.public_rounded,
              iconColor: AppColors.green,
              title: 'Ranking Global',
              child: _Paragraphs([
                'Responde: "Na opinião dos usuários do app, quem possui o '
                    'maior Nível Lenda?"',
                'Considera as avaliações de todos os usuários. A pontuação de '
                    'cada pessoa é a média das avaliações recebidas. Exemplo: '
                    '60, 70 e 65 pontos → (60 + 70 + 65) ÷ 3 = 65 pontos.',
                'Cada usuário tem uma única avaliação por pessoa e pode '
                    'alterá-la, mas não criar outra. Ninguém pode avaliar a '
                    'si mesmo.',
              ]),
            ),
            const SizedBox(height: 14),

            const _InfoCard(
              icon: Icons.cloud_rounded,
              iconColor: AppColors.red,
              title: 'Dados na nuvem (Firestore)',
              child: _Paragraphs([
                'Pessoas e avaliações são armazenadas remotamente no Cloud '
                    'Firestore, então todos os usuários veem os mesmos dados.',
                'No dispositivo ficam apenas a preferência de tema e um cache '
                    'simples do usuário logado. Senhas nunca são salvas.',
              ]),
            ),
            const SizedBox(height: 14),

            const _InfoCard(
              icon: Icons.lock_rounded,
              iconColor: AppColors.red,
              title: 'Login seguro (Firebase Authentication)',
              child: _Paragraphs([
                'O acesso ao app usa Firebase Authentication, com e-mail e '
                    'senha ou com a conta Google. É ele que garante que a sua '
                    'sessão é válida.',
              ]),
            ),
            const SizedBox(height: 14),

            const _InfoCard(
              icon: Icons.dark_mode_rounded,
              iconColor: AppColors.gold,
              title: 'Tema claro e escuro',
              child: _Paragraphs([
                'Use o botão no topo da tela para alternar entre os temas '
                    'claro e escuro a qualquer momento. Sua escolha fica '
                    'salva no dispositivo.',
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.jakarta(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

// Um ou mais parágrafos com o mesmo estilo de texto.
class _Paragraphs extends StatelessWidget {
  final List<String> paragraphs;

  const _Paragraphs(this.paragraphs);

  @override
  Widget build(BuildContext context) {
    final style = AppTextStyles.jakarta(
      fontSize: 13.5,
      fontWeight: FontWeight.w500,
      height: 1.5,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .75),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < paragraphs.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Text(paragraphs[i], style: style),
        ],
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: AppTextStyles.jakarta(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.green,
        ),
      ),
    );
  }
}

// Faixa de pontuação: mínimo -> máximo.
class _ScoreRange extends StatelessWidget {
  final int maxTotal;

  const _ScoreRange({required this.maxTotal});

  @override
  Widget build(BuildContext context) {
    final minTotal = CriteriaType.values.length * CriteriaScoreLimits.min;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ScoreBadge(value: '$minTotal', label: 'MÍNIMO'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14),
            child: Icon(Icons.arrow_forward_rounded, size: 18),
          ),
          _ScoreBadge(value: '$maxTotal', label: 'MÁXIMO'),
        ],
      ),
    );
  }
}

class _ScoreBadge extends StatelessWidget {
  final String value;
  final String label;

  const _ScoreBadge({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTextStyles.sora(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.green,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.jakarta(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: .5,
            color: AppColors.green.withValues(alpha: .7),
          ),
        ),
      ],
    );
  }
}

// Faixas de classificação (Novato -> Lenda).
class _TierTable extends StatelessWidget {
  const _TierTable();

  // Mesmos limites usados em PopularityTierInfo.fromScore.
  static const _ranges = {
    PopularityTier.novato: '15 a 30',
    PopularityTier.popular: '31 a 45',
    PopularityTier.idolo: '46 a 60',
    PopularityTier.lenda: '61 a 75',
  };

  @override
  Widget build(BuildContext context) {
    final dim = Theme.of(context).colorScheme.onSurface.withValues(alpha: .7);

    return Column(
      children: [
        for (final entry in _ranges.entries)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key.label,
                    style: AppTextStyles.jakarta(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.gold,
                    ),
                  ),
                ),
                Text(
                  '${entry.value} pontos',
                  style: AppTextStyles.jakarta(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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