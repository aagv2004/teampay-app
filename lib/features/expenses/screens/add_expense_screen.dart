import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teampayapp/features/groups/providers/group_provider.dart';
import '../../../core/constants/app_colors.dart';

class AddExpenseScreen extends StatefulWidget {
  final String groupId;

  const AddExpenseScreen({super.key, required this.groupId});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  String? _paidByMemberId;
  final Set<String> _selectedParticipantIds = {};

  bool _loaded = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _loadGroupData(BuildContext context) {
    if (_loaded) return;

    final group = context.read<GroupProvider>().getGroupById(widget.groupId);
    if (group == null || group.members.isEmpty) return;

    _paidByMemberId = group.members.first.id;
    _selectedParticipantIds.addAll(group.members.map((member) => member.id));

    _loaded = true;
  }

  void _saveExpense() {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim().replaceAll('.', '');
    final amount = double.tryParse(amountText);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para el gasto')),
      );
      return;
    }

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido')));
      return;
    }

    if (_paidByMemberId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Selecciona quién pagó')));
      return;
    }

    if (!_selectedParticipantIds.contains(_paidByMemberId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La persona que pagó debe participar en el gasto'),
        ),
      );
      return;
    }

    if (_selectedParticipantIds.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos 2 participantes')),
      );
      return;
    }

    context.read<GroupProvider>().addExpense(
      groupId: widget.groupId,
      title: title,
      amount: amount,
      paidByMemberId: _paidByMemberId!,
      splitBetweenMemberIds: _selectedParticipantIds.toList(),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _loadGroupData(context);

    final group = context.watch<GroupProvider>().getGroupById(widget.groupId);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grupo no encontrado')),
        body: const Center(child: Text('No se pudo encontrar este grupo.')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final avatarBackground = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar gasto')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Nuevo gasto',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          const Text(
            'Registra quién pagó y quiénes participaron en este gasto.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Nombre del gasto',
              hintText: 'Ej: Pizza, bencina, cabaña',
              prefixIcon: Icon(Icons.receipt_long_rounded),
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monto',
              hintText: 'Ej: 12000',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'Persona que pagó todo',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 10),

          DropdownButtonFormField<String>(
            value: _paidByMemberId,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.account_balance_wallet_rounded),
            ),
            items: group.members.map((member) {
              return DropdownMenuItem(
                value: member.id,
                child: Text(member.name),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _paidByMemberId = value;
                _selectedParticipantIds.add(value);
              });
            },
          ),

          const SizedBox(height: 22),

          const Text(
            'Participan en este gasto',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 6),

          const Text(
            'La deuda se calculará solo entre las personas seleccionadas.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 10),

          ...group.members.map((member) {
            final isSelected = _selectedParticipantIds.contains(member.id);
            final isPayer = member.id == _paidByMemberId;

            return Card(
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedParticipantIds.add(member.id);
                    } else {
                      if (isPayer) return;
                      _selectedParticipantIds.remove(member.id);
                    }
                  });
                },
                secondary: CircleAvatar(
                  backgroundColor: isPayer
                      ? AppColors.primary
                      : avatarBackground,
                  child: Icon(
                    isPayer
                        ? Icons.account_balance_wallet_rounded
                        : Icons.person_rounded,
                    color: isPayer ? Colors.white : AppColors.primary,
                  ),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  isPayer
                      ? 'Pagó todo y participa en el gasto'
                      : 'Participante',
                ),
                controlAffinity: ListTileControlAffinity.trailing,
              ),
            );
          }),

          const SizedBox(height: 28),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _saveExpense,
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Guardar gasto',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
