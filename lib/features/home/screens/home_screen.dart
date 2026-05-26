import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/core/utils/currency_formatter.dart';
import 'package:teampayapp/features/groups/screens/group_detail_screen.dart';

import '../../../core/theme/theme_provider.dart';
import '../../groups/providers/group_provider.dart';
import '../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final name = user?.displayName ?? 'Usuario';

    final themeProvider = context.watch<ThemeProvider>();
    final groups = context.watch<GroupProvider>().groups;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allExpenses = groups.expand((group) => group.expenses).toList();
    final allDebts = groups.expand((group) => group.debts).toList();

    final totalSpent = allExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final totalPending = allDebts
        .where((debt) => !debt.isPaid)
        .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

    final groupWithMostMembers = [...groups]
      ..sort((a, b) => b.members.length.compareTo(a.members.length));

    final groupWithMostPending =
        groups.where((group) {
          final pending = group.debts
              .where((debt) => !debt.isPaid)
              .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

          return pending > 0;
        }).toList()..sort((a, b) {
          final pendingA = a.debts
              .where((debt) => !debt.isPaid)
              .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

          final pendingB = b.debts
              .where((debt) => !debt.isPaid)
              .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

          return pendingB.compareTo(pendingA);
        });

    return Scaffold(
      appBar: AppBar(
        title: const Text('TeamPay'),
        actions: [
          IconButton(
            onPressed: () {
              themeProvider.setThemeMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              );
            },
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Hola, $name',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Este es el resumen general de tus grupos y pagos pendientes.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),

          _BalanceCard(
            totalSpent: totalSpent,
            totalPending: totalPending,
            groupsCount: groups.length,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  icon: Icons.groups_rounded,
                  title: 'Más integrantes',
                  value: groupWithMostMembers.isEmpty
                      ? 'Sin grupos'
                      : groupWithMostMembers.first.name,
                  subtitle: groupWithMostMembers.isEmpty
                      ? 'Crea tu primer grupo'
                      : '${groupWithMostMembers.first.members.length} integrantes',
                  onTap: groupWithMostMembers.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(
                                groupId: groupWithMostMembers.first.id,
                              ),
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightCard(
                  icon: Icons.warning_amber_rounded,
                  title: 'Mayor pendiente',
                  value: groupWithMostPending.isEmpty
                      ? 'Sin pendientes'
                      : groupWithMostPending.first.name,
                  subtitle: groupWithMostPending.isEmpty
                      ? 'Todo limpio por ahora 🦖'
                      : 'Revisar deudas',
                  highlighted: true,
                  onTap: groupWithMostPending.isEmpty
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(
                                groupId: groupWithMostPending.first.id,
                              ),
                            ),
                          );
                        },
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Últimos gastos registrados',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),

          ...allExpenses
              .take(4)
              .map(
                (expense) => _MovementTile(
                  title: expense.title,
                  subtitle:
                      'Registrado el ${DateFormat('dd/MM/yyyy').format(expense.createdAt)}',
                  amount: expense.amount,
                ),
              ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double totalSpent;
  final double totalPending;
  final int groupsCount;

  const _BalanceCard({
    required this.totalSpent,
    required this.totalPending,
    required this.groupsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Balance general',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.clp(totalPending),
              style: TextStyle(
                color: totalPending > 0
                    ? AppColors.primary
                    : AppColors.primaryDark,
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pendiente total en todos tus grupos',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BalanceMiniBox(
                    title: 'Total gastado',
                    value: CurrencyFormatter.clp(totalSpent),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BalanceMiniBox(
                    title: 'Grupos',
                    value: '$groupsCount',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceMiniBox extends StatelessWidget {
  final String title;
  final String value;

  const _BalanceMiniBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(16),
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
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final bool highlighted;
  final VoidCallback? onTap;

  const _InsightCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    this.highlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isClickable = onTap != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: highlighted
                      ? AppColors.warningBackground
                      : Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  child: Icon(
                    icon,
                    size: 30,
                    color: highlighted ? AppColors.warning : AppColors.primary,
                  ),
                ),

                const SizedBox(height: 14),

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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (isClickable) ...[
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.touch_app_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MovementTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;

  const _MovementTile({
    required this.title,
    required this.subtitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(Icons.receipt_long_rounded, color: Colors.white),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: Text(
          CurrencyFormatter.clp(amount),
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
