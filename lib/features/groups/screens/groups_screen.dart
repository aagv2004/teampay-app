import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/features/groups/providers/group_provider.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import '../../../core/constants/app_colors.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupProvider>().groups;

    return Scaffold(
      appBar: AppBar(title: const Text('Grupos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Tus grupos',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Administra los grupos donde compartes gastos y revisa sus saldos pendientes.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),

          ...groups.map((group) {
            final total = group.expenses.fold<double>(
              0,
              (sum, expense) => sum + expense.amount,
            );

            final pending = group.debts
                .where((debt) => !debt.isPaid)
                .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _GroupListCard(
                name: group.name,
                membersCount: group.members.length,
                total: total,
                pending: pending,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(groupId: group.id),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Grupo'),
      ),
    );
  }
}

class _GroupListCard extends StatelessWidget {
  final String name;
  final int membersCount;
  final double total;
  final double pending;
  final VoidCallback onTap;

  const _GroupListCard({
    required this.name,
    required this.membersCount,
    required this.total,
    required this.pending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasPending = pending > 0;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.groups_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$membersCount integrantes',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _MiniInfoBox(
                      title: 'Total',
                      value: '\$${total.toStringAsFixed(0)}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MiniInfoBox(
                      title: 'Pendiente',
                      value: '\$${pending.toStringAsFixed(0)}',
                      highlight: hasPending,
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
}

class _MiniInfoBox extends StatelessWidget {
  final String title;
  final String value;
  final bool highlight;

  const _MiniInfoBox({
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final backgroundColor = highlight
        ? isDark
              ? AppColors.warning.withValues(alpha: 0.14)
              : AppColors.warningBackground
        : isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: highlight ? AppColors.warning : AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
