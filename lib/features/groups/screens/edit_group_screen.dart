import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/models/member.dart';
import '../providers/group_provider.dart';

/// Pantalla para editar nombre e integrantes de un grupo.
/// El organizador no se puede borrar del grupo.
class EditGroupScreen extends StatefulWidget {
  final String groupId;

  const EditGroupScreen({super.key, required this.groupId});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

/// Carga el grupo una vez y mantiene cambios locales hasta guardar.
class _EditGroupScreenState extends State<EditGroupScreen> {
  final _groupNameController = TextEditingController();
  final _memberNameController = TextEditingController();

  final List<Member> _members = [];
  String? _organizerMemberId;

  bool _loaded = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    _memberNameController.dispose();
    super.dispose();
  }

  void _loadGroup() {
    if (_loaded) return;

    final group = context.read<GroupProvider>().getGroupById(widget.groupId);

    if (group == null) return;

    _groupNameController.text = group.name;
    _members.addAll(group.members);
    _organizerMemberId = group.organizerMemberId;

    _loaded = true;
  }

  void _addMember() {
    final name = _memberNameController.text.trim();

    if (name.isEmpty) return;

    final member = Member(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
    );

    setState(() {
      _members.add(member);
      _memberNameController.clear();

      _organizerMemberId ??= member.id;
    });
  }

  void _removeMember(Member member) {
    if (member.id == _organizerMemberId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El organizador debe seguir en el grupo')),
      );
      return;
    }

    if (_members.length == 1) return;

    setState(() {
      _members.removeWhere((item) => item.id == member.id);
    });
  }

  void _saveChanges() {
    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un nombre para el grupo')),
      );
      return;
    }

    if (_members.isEmpty || _organizerMemberId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El grupo necesita al menos un integrante'),
        ),
      );
      return;
    }

    context.read<GroupProvider>().editGroup(
      groupId: widget.groupId,
      name: groupName,
      members: _members,
      organizerMemberId: _organizerMemberId!,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    _loadGroup();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final avatarBackground = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;

    final group = context.watch<GroupProvider>().getGroupById(widget.groupId);

    if (group == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Grupo no encontrado')),
        body: const Center(child: Text('No se pudo encontrar este grupo.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar grupo')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Editar grupo',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 6),

          const Text(
            'Actualiza el nombre y las personas del grupo. Tu sigues como organizador.',
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
            'Integrantes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),

          const SizedBox(height: 10),

          ..._members.map((member) {
            final isOrganizer = member.id == _organizerMemberId;

            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isOrganizer
                      ? AppColors.primary
                      : avatarBackground,
                  child: Icon(
                    isOrganizer
                        ? Icons.admin_panel_settings_rounded
                        : Icons.person_rounded,
                    color: isOrganizer ? Colors.white : AppColors.primary,
                  ),
                ),
                title: Text(
                  member.name,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: isOrganizer
                    ? const Text('Organizador')
                    : const Text('Integrante'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: _members.length == 1 || isOrganizer
                          ? null
                          : () => _removeMember(member),
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
              onPressed: _saveChanges,
              icon: const Icon(Icons.save_rounded),
              label: const Text(
                'Guardar cambios',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
