import 'package:flutter/material.dart';
import 'package:teampayapp/core/models/group.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/core/models/member.dart';
import 'package:teampayapp/core/utils/currency_formatter.dart';

import '../../../core/constants/app_colors.dart';
import 'add_expense_screen.dart';
import '../../groups/providers/group_provider.dart';

/// Pantalla que lista gastos agrupados por grupo.
/// Sirve para revisar rapidamente que se ha registrado.
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startAddExpenseFlow(context, groups),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Gasto'),
      ),
    );
  }
}

/// Decide si abrir directo o pedir elegir grupo antes de crear gasto.
void _startAddExpenseFlow(BuildContext context, List<Group> groups) {
  if (groups.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Crea un grupo antes de registrar gastos')),
    );
    return;
  }

  if (groups.length == 1) {
    _openAddExpenseScreen(context, groups.first);
    return;
  }

  _showGroupPicker(context, groups);
}

/// Abre el formulario de gasto para el grupo elegido.
void _openAddExpenseScreen(BuildContext context, Group group) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AddExpenseScreen(groupId: group.id)),
  );
}

/// Muestra una lista simple de grupos para asociar el nuevo gasto.
void _showGroupPicker(BuildContext context, List<Group> groups) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Elige un grupo',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              const Text(
                'El gasto quedara asociado al grupo que selecciones.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              ...groups.map((group) {
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.groups_rounded, color: Colors.white),
                    ),
                    title: Text(
                      group.name,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text('${group.members.length} integrantes'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      Navigator.pop(sheetContext);
                      _openAddExpenseScreen(context, group);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

/// Busca quien pago usando el ID guardado en el gasto.
Member? _findMemberById(List<Member> members, String memberId) {
  for (final member in members) {
    if (member.id == memberId) {
      return member;
    }
  }

  return null;
}
