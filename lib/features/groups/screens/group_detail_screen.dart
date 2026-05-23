import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/core/models/debt.dart';
import 'package:teampayapp/core/models/member.dart';
import 'package:teampayapp/features/groups/providers/group_provider.dart';
import '../../../core/constants/app_colors.dart';
import 'edit_group_screen.dart';
import '../../expenses/screens/add_expense_screen.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;

  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().getGroupById(groupId);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grupo no encontrado')),
        body: const Center(child: Text('No se pudo encontrar este grupo')),
      );
    }

    final owner = _findMemberById(group.members, group.ownerMemberId);
    final ownerName = owner?.name ?? 'integrante eliminado';

    final total = group.expenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );

    final pending = group.debts
        .where((debt) => !debt.isPaid)
        .fold<double>(0, (sum, debt) => sum + debt.remainingAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditGroupScreen(groupId: group.id),
                ),
              );
            },
            icon: const Icon(Icons.edit_rounded),
          ),
          IconButton(
            onPressed: () => _confirmDeleteGroup(context, groupId),
            icon: const Icon(Icons.delete_rounded),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _GroupHeaderCard(
            groupName: group.name,
            total: '\$${total.toStringAsFixed(0)}',
            members:
                '${group.members.length} integrantes · Administrado por $ownerName',
            pending: '\$${pending.toStringAsFixed(0)}',
          ),

          const SizedBox(height: 18),
          const _SectionTitle(title: 'Integrantes'),
          const SizedBox(height: 10),
          group.members.isEmpty
              ? const _EmptyState(
                  icon: Icons.group_off_rounded,
                  title: 'Sin integrantes',
                  message:
                      'Este grupo todavía no tiene integrantes registrados.',
                )
              : _MembersPreview(members: group.members),

          const SizedBox(height: 18),
          const _SectionTitle(title: 'Deudas del grupo'),
          if (group.debts.isEmpty)
            const _EmptyState(
              icon: Icons.payments_outlined,
              title: 'Sin deudas',
              message: 'Todavía no existen deudas registradas en este grupo.',
            )
          else
            ...group.debts.map((debt) {
              final fromMember = _findMemberById(
                group.members,
                debt.fromMemberId,
              );
              final toMember = _findMemberById(group.members, debt.toMemberId);

              final fromMemberName = fromMember?.name ?? 'Integrante eliminado';
              final toMemberName = toMember?.name ?? 'Inegrante eliminado';

              return _DebtTile(
                name: fromMemberName,
                status: debt.statusLabel,
                amount: '\$${debt.remainingAmount.toStringAsFixed(0)}',
                detail:
                    'Debe a $toMemberName · Pagado: \$${debt.paidAmount.toStringAsFixed(0)} · ${debt.paymentMethodLabel}',
                isPaid: debt.isPaid,
                isPartial: debt.isPartiallyPaid,
                action: !debt.isPaid
                    ? TextButton.icon(
                        onPressed: () {
                          _showRegisterPaymentSheet(
                            context: context,
                            groupId: group.id,
                            debt: debt,
                          );
                        },
                        icon: const Icon(Icons.payments_rounded),
                        label: const Text('Registrar pago'),
                      )
                    : null,
              );
            }),
          const SizedBox(height: 18),
          _SectionTitle(title: 'Gastos recientes'),
          const SizedBox(height: 10),
          if (group.expenses.isEmpty)
            const _EmptyState(
              icon: Icons.receipt_long_rounded,
              title: 'Sin gastos',
              message: 'Aún no se han registrado gastos en este grupo.',
            )
          else
            ...group.expenses.map((expense) {
              final payer = _findMemberById(
                group.members,
                expense.paidByMemberId,
              );
              final payerName = payer?.name ?? 'Integrante eliminado';

              return _ExpenseTile(
                title: expense.title,
                subtitle: '$payerName pagó todo',
                amount: '\$${expense.amount.toStringAsFixed(0)}',
              );
            }),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddExpenseScreen(groupId: group.id),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Gasto'),
      ),
    );
  }
}

class _GroupHeaderCard extends StatelessWidget {
  final String groupName;
  final String total;
  final String members;
  final String pending;

  const _GroupHeaderCard({
    required this.groupName,
    required this.total,
    required this.members,
    required this.pending,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              groupName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              members,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(title: 'Total gastado', value: total),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MiniStat(title: 'Pendiente', value: pending),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({required this.title, required this.value});

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
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
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

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
    );
  }
}

class _DebtTile extends StatelessWidget {
  final String name;
  final String status;
  final String amount;
  final String detail;
  final bool isPaid;
  final bool isPartial;
  final Widget? action;

  const _DebtTile({
    required this.name,
    required this.status,
    required this.amount,
    required this.detail,
    required this.isPaid,
    required this.isPartial,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isPaid
        ? AppColors.success
        : isPartial
        ? AppColors.warning
        : AppColors.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.avatarBackground,
                child: Icon(Icons.person_rounded, color: AppColors.primary),
              ),
              title: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(detail),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            if (action != null)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: action!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;

  const _ExpenseTile({
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
          amount,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}

class _MembersPreview extends StatelessWidget {
  final List<Member> members;

  const _MembersPreview({required this.members});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: members.map((member) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    member.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.textSecondary),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _confirmDeleteGroup(BuildContext context, String groupId) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('Eliminar grupo'),
        content: const Text(
          '¿Seguro que quieres eliminar este grupo? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () {
              context.read<GroupProvider>().deleteGroup(groupId);

              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.delete_rounded),
            label: const Text('Eliminar'),
          ),
        ],
      );
    },
  );
}

void _showRegisterPaymentSheet({
  required BuildContext context,
  required String groupId,
  required Debt debt,
}) {
  final amountController = TextEditingController();
  PaymentMethod selectedMethod = PaymentMethod.transfer;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registrar pago',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 6),
                Text(
                  'Pendiente: \$${debt.remainingAmount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Monto pagado',
                    hintText: 'Ej: 5000',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                ),

                const SizedBox(height: 18),

                DropdownButtonFormField<PaymentMethod>(
                  value: selectedMethod,
                  decoration: const InputDecoration(
                    labelText: 'Método de pago',
                    prefixIcon: Icon(Icons.payments_rounded),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: PaymentMethod.transfer,
                      child: Text('Transferencia'),
                    ),
                    DropdownMenuItem(
                      value: PaymentMethod.cash,
                      child: Text('Efectivo'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setModalState(() {
                      selectedMethod = value;
                    });
                  },
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final amountText = amountController.text
                          .trim()
                          .replaceAll('.', '');
                      final amount = double.tryParse(amountText);

                      if (amount == null || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresa un monto válido'),
                          ),
                        );
                        return;
                      }

                      if (amount > debt.remainingAmount) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'El pago no puede superar el saldo pendiente',
                            ),
                          ),
                        );
                        return;
                      }

                      context.read<GroupProvider>().registerDebtPayment(
                        groupId: groupId,
                        debtId: debt.id,
                        paymentAmount: amount,
                        paymentMethod: selectedMethod,
                      );

                      Navigator.pop(sheetContext);
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text(
                      'Guardar pago',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

Member? _findMemberById(List<Member> members, String memberId) {
  for (final member in members) {
    return member;
  }

  return null;
}
