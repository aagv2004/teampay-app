import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../providers/group_provider.dart';

/// Pantalla para crear un grupo nuevo.
/// El usuario actual queda como organizador e integrante inicial.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

/// Guarda temporalmente el nombre del grupo y personas adicionales.
class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _groupNameController = TextEditingController();
  final _memberNameController = TextEditingController();

  final List<String> _members = [];

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberNameController.text.trim();

    if (name.isEmpty) return;

    setState(() {
      _members.add(name);
      _memberNameController.clear();
    });
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
    });
  }

  void _createGroup() {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para el grupo')),
      );
      return;
    }

    context.read<GroupProvider>().createGroup(
      name: groupName,
      memberNames: _members,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final avatarBackground = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;

    return Scaffold(
      appBar: AppBar(title: const Text('Crear grupo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Nuevo grupo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 6),

          const Text(
            'Crea un grupo para dividir gastos con amigos, companeros o familia.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Al crear este grupo, tu quedaras como organizador. Podras agregar personas y registrar gastos.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(
              labelText: 'Nombre del grupo',
              hintText: 'Ej: Viaje escolar',
              prefixIcon: Icon(Icons.groups_rounded),
            ),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: _memberNameController,
            onSubmitted: (_) => _addMember(),
            decoration: InputDecoration(
              labelText: 'Agregar integrante',
              hintText: 'Nombre del integrante',
              prefixIcon: const Icon(Icons.person_add_alt_1_rounded),
              suffixIcon: IconButton(
                onPressed: _addMember,
                icon: const Icon(Icons.add_circle_rounded),
              ),
            ),
          ),

          const SizedBox(height: 18),

          const Text(
            'Personas adicionales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 10),

          if (_members.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 6),
              child: Text(
                'Todavia no agregas integrantes adicionales. Por ahora solo estaras tu.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),

          ..._members.asMap().entries.map((entry) {
            final index = entry.key;
            final member = entry.value;
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: avatarBackground,
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                  ),
                ),
                title: Text(
                  member,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: const Text('Integrante'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _removeMember(index),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 28),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _createGroup,
              icon: const Icon(Icons.check_rounded),
              label: const Text(
                'Crear grupo',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
