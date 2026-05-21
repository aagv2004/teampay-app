import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = ['Viaje escolar', 'Departamento', 'Taekwondo'];

    final members = ['Alejandro', 'Oscar Dum', 'Carlo Emilion', 'Martina'];

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
            'Registra un gasto y define quién lo pagó para calcular las deudas del grupo.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),

          const TextField(
            decoration: InputDecoration(
              labelText: 'Nombre del gasto',
              hintText: 'Ej: Comida, transporte, entradas',
              prefixIcon: Icon(Icons.receipt_long_rounded),
            ),
          ),

          const SizedBox(height: 18),
          const TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto total',
              hintText: 'Ej: 25000',
              prefixIcon: Icon(Icons.attach_money_rounded),
            ),
          ),

          const SizedBox(height: 18),
          const Text(
            'Grupo a agregar el gasto',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          _FakeSelector(
            icon: Icons.groups_rounded,
            title: groups.first,
            trailing: Icons.keyboard_arrow_down_rounded,
          ),

          const SizedBox(height: 18),
          const Text(
            'Persona que paga todo',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 4),
          const Text(
            'Persona que pagó el gasto completo inicialmente.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          _FakeSelector(
            icon: Icons.person_rounded,
            title: members.first,
            trailing: Icons.keyboard_arrow_down_rounded,
          ),

          const SizedBox(height: 22),
          const Text(
            'Dividir entre',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          ...members.map(
            (member) => Card(
              child: CheckboxListTile(
                value: true,
                onChanged: (_) {},
                title: Text(
                  member,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                secondary: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkSurfaceVariant
                      : AppColors.lightSurfaceVariant,
                  child: Icon(Icons.person_rounded, color: AppColors.primary),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Agregar gasto',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FakeSelector extends StatelessWidget {
  final IconData icon;
  final String title;
  final IconData trailing;

  const _FakeSelector({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        trailing: Icon(trailing),
      ),
    );
  }
}
