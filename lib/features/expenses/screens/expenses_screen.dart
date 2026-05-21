import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../groups/providers/group_provider.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupProvider>().groups;
    final groupsWithExpenses = groups
        .where((group) => group.expenses.isNotEmpty)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Gastos por grupo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Revisa los gastos registrados organizados según cada grupo.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),

          if (groupsWithExpenses.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(22),
                child: Text('Aún no hay gastos registrados.'),
              ),
            ),

          ...groupsWithExpenses.map((group) {
            final total = group.expenses.fold<double>(
              0,
              (sum, expense) => sum + expense.amount,
            );

            return Card(
              clipBehavior: Clip.antiAlias,
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.groups_rounded, color: Colors.white),
                  ),
                  title: Text(
                    group.name,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  subtitle: Text(
                    '${group.expenses.length} gastos · Total \$${total.toStringAsFixed(0)}',
                  ),
                  children: group.expenses.map((expense) {
                    final payer = group.members.firstWhere(
                      (member) => member.id == expense.paidByMemberId,
                    );

                    return ListTile(
                      leading: const Icon(Icons.receipt_long_rounded),
                      title: Text(
                        expense.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text('Pagó ${payer.name}'),
                      trailing: Text(
                        '\$${expense.amount.toStringAsFixed(0)}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    );
                  }).toList(),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
