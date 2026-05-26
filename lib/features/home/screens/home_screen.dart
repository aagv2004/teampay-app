import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/core/models/group.dart';
import 'package:teampayapp/core/utils/currency_formatter.dart';
import 'package:teampayapp/features/groups/screens/group_detail_screen.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../groups/providers/group_provider.dart';

/// Dashboard principal de TeamPay.
/// Resume tus grupos y el balance desde tu punto de vista.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final groupProvider = context.watch<GroupProvider>();
    final user = FirebaseAuth.instance.currentUser;
    final name =
        groupProvider.currentUserName ?? user?.displayName ?? 'Usuario';
    final groups = groupProvider.groups;
    final currentUserMemberId = groupProvider.currentUserMemberId;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final allExpenses = groups.expand((group) => group.expenses).toList();
    final allDebts = groups.expand((group) => group.debts).toList();

    final debtsByMe = currentUserMemberId == null
        ? 0.0
        : allDebts
              .where(
                (debt) =>
                    !debt.isPaid && debt.fromMemberId == currentUserMemberId,
              )
              .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

    final debtsToMe = currentUserMemberId == null
        ? 0.0
        : allDebts
              .where(
                (debt) =>
                    !debt.isPaid && debt.toMemberId == currentUserMemberId,
              )
              .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

    final netBalance = debtsToMe - debtsByMe;

    final topOwedToMe = _topGroupDebtInsight(
      groups,
      currentUserMemberId,
      owedToMe: true,
    );
    final topOwedByMe = _topGroupDebtInsight(
      groups,
      currentUserMemberId,
      owedToMe: false,
    );

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
            'Este es el resumen personal de tus grupos y pagos pendientes.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),

          _BalanceCard(
            debtsByMe: debtsByMe,
            debtsToMe: debtsToMe,
            netBalance: netBalance,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _InsightCard(
                  icon: Icons.south_west_rounded,
                  title: 'Te deben mas',
                  value: topOwedToMe == null
                      ? 'Sin pendientes'
                      : topOwedToMe.name,
                  subtitle: topOwedToMe == null
                      ? 'Todo al dia'
                      : CurrencyFormatter.clp(topOwedToMe.amount),
                  onTap: topOwedToMe == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(
                                groupId: topOwedToMe.groupId,
                              ),
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InsightCard(
                  icon: Icons.north_east_rounded,
                  title: 'Debes mas',
                  value: topOwedByMe == null ? 'Sin deudas' : topOwedByMe.name,
                  subtitle: topOwedByMe == null
                      ? 'Todo al dia'
                      : CurrencyFormatter.clp(topOwedByMe.amount),
                  highlighted: true,
                  onTap: topOwedByMe == null
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => GroupDetailScreen(
                                groupId: topOwedByMe.groupId,
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
            'Ultimos gastos registrados',
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

/// Encuentra el grupo donde mas debes o donde mas te deben.
_GroupDebtInsight? _topGroupDebtInsight(
  List<Group> groups,
  String? currentUserMemberId, {
  required bool owedToMe,
}) {
  if (currentUserMemberId == null) return null;

  _GroupDebtInsight? topInsight;

  for (final group in groups) {
    final amount = group.debts
        .where(
          (debt) =>
              !debt.isPaid &&
              (owedToMe
                  ? debt.toMemberId == currentUserMemberId
                  : debt.fromMemberId == currentUserMemberId),
        )
        .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

    if (amount <= 0) continue;
    if (topInsight == null || amount > topInsight.amount) {
      topInsight = _GroupDebtInsight(
        groupId: group.id,
        name: group.name,
        amount: amount,
      );
    }
  }

  return topInsight;
}

/// Dato resumido para las tarjetas del dashboard.
class _GroupDebtInsight {
  final String groupId;
  final String name;
  final double amount;

  const _GroupDebtInsight({
    required this.groupId,
    required this.name,
    required this.amount,
  });
}

/// Tarjeta grande con cuanto debes, cuanto te deben y balance neto.
class _BalanceCard extends StatelessWidget {
  final double debtsByMe;
  final double debtsToMe;
  final double netBalance;

  const _BalanceCard({
    required this.debtsByMe,
    required this.debtsToMe,
    required this.netBalance,
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
              'Resumen personal',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              CurrencyFormatter.clp(netBalance.abs()),
              style: TextStyle(
                color: netBalance < 0 ? AppColors.warning : AppColors.primary,
                fontSize: 36,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              netBalance == 0
                  ? 'Balance neto: estas al dia'
                  : netBalance < 0
                  ? 'Balance neto: debes mas de lo que te deben'
                  : 'Balance neto: te deben mas de lo que debes',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _BalanceMiniBox(
                    title: 'Debes',
                    value: CurrencyFormatter.clp(debtsByMe),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BalanceMiniBox(
                    title: 'Te deben',
                    value: CurrencyFormatter.clp(debtsToMe),
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

/// Caja pequena para un dato del resumen personal.
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

/// Tarjeta de dato rapido que puede llevar al detalle de un grupo.
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isClickable = onTap != null;
    final backgroundColor = highlighted
        ? isDark
              ? AppColors.warning.withValues(alpha: 0.14)
              : AppColors.warningBackground
        : isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final iconColor = highlighted ? AppColors.warning : AppColors.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: backgroundColor,
                    child: Icon(icon, size: 26, color: iconColor),
                  ),
                  const Spacer(),
                  if (isClickable)
                    const Icon(
                      Icons.touch_app_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 16),
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
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fila para mostrar un gasto reciente en el dashboard.
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
