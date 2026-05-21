import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../groups/providers/group_provider.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupProvider>().groups;
    final expenses = groups.expand((group) => group.expenses).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Gastos',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Revisa todos los gastos registrados en tus grupos.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),

          if (expenses.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('Aún no hay gastos registrados.'),
              ),
            ),

          ...groups.expand((group) {
            return group.expenses.map((expense) {
              final payer = group.members.firstWhere(
                (member) => member.id == expense.paidByMemberId,
              );

              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    expense.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${group.name} · Pagó ${payer.name}'),
                  trailing: Text(
                    '\$${expense.amount.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              );
            });
          }),
        ],
      ),
    );
  }
}
