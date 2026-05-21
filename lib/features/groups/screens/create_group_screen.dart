import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class CreateGroupScreen extends StatelessWidget {
  const CreateGroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final members = ['Alejandro', 'Oscar Dum', 'Carlo Emilion'];

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
            'Crea un grupo para dividir gastos con amigos, compañeros o familia.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(
              labelText: 'Nombre del grupo',
              hintText: 'Ej: Viaje escolar',
              prefixIcon: Icon(Icons.groups_rounded),
            ),
          ),

          const SizedBox(height: 18),
          TextField(
            decoration: InputDecoration(
              labelText: 'Agregar integrante',
              hintText: 'Nombre del integrante',
              prefixIcon: const Icon(Icons.person_add_alt_1_rounded),
              suffixIcon: IconButton(
                onPressed: () {},
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
          ...members.map(
            (member) => Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAEAF0),
                  child: Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                title: Text(
                  member,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                trailing: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {},
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
