import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/core/models/member.dart';
import 'package:teampayapp/core/utils/currency_formatter.dart';

import '../../../core/constants/app_colors.dart';
import '../../groups/providers/group_provider.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();
    final groups = groupProvider.groups;

    if (groupProvider.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gastos')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (groupProvider.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gastos')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              groupProvider.errorMessage!,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

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
                    '${group.expenses.length} gastos · Total ${CurrencyFormatter.clp(total)}',
                  ),
                  children: group.expenses.map((expense) {
                    final payer = _findMemberById(
                      group.members,
                      expense.paidByMemberId,
                    );

                    final payerName = payer?.name ?? 'Integrante eliminado';

                    return ListTile(
                      leading: const Icon(Icons.receipt_long_rounded),
                      title: Text(
                        expense.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text('Pagó $payerName'),
                      trailing: Text(
                        CurrencyFormatter.clp(expense.amount),
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

Member? _findMemberById(List<Member> members, String memberId) {
  for (final member in members) {
    if (member.id == memberId) {
      return member;
    }
  }

  return null;
}
