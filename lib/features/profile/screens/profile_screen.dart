import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/constants/app_colors.dart';

/// Pantalla de perfil del usuario autenticado.
/// Por ahora muestra datos simples y permite cerrar sesion.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _ProfileHeader(),
          const SizedBox(height: 22),
          const _ProfileBentoStats(),
          const SizedBox(height: 24),
          const _AppVersionCard(),
          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child: OutlinedButton.icon(
              onPressed: () async {
                final shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text('¿Seguro que quieres cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Cerrar sesión'),
                        ),
                      ],
                    );
                  },
                );

                if (shouldLogout == true) {
                  await FirebaseAuth.instance.signOut();
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta que muestra la version instalada de la app.
class _AppVersionCard extends StatelessWidget {
  const _AppVersionCard();

  static final Future<PackageInfo> _packageInfoFuture =
      PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        final hasError = snapshot.hasError;

        final versionText = hasError
            ? 'Versión no disponible'
            : snapshot.data == null
            ? 'Cargando versión...'
            : '${snapshot.data!.version}+${snapshot.data!.buildNumber}';

        final subtitleText = hasError
            ? 'No se pudo leer la metadata del build'
            : snapshot.data == null
            ? 'Leyendo la metadata del build'
            : 'Versión marcada desde pubspec.yaml';

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Versión de la app',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        versionText,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitleText,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tarjeta superior con nombre y correo del usuario.
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName ?? 'Usuario TeamPay';
    final email = user?.email ?? 'Sin correo';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.person_rounded, color: Colors.white, size: 42),
            ),
            SizedBox(height: 14),
            Text(
              name,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(
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

/// Bloque visual con estadisticas de ejemplo del perfil.
class _ProfileBentoStats extends StatelessWidget {
  const _ProfileBentoStats();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _SmallBentoCard(
                icon: Icons.groups_rounded,
                title: 'Grupos',
                value: '3',
                subtitle: 'Activos',
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _SmallBentoCard(
                icon: Icons.receipt_long_rounded,
                title: 'Gastos',
                value: '12',
                subtitle: 'Registrados',
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        _WideBentoCard(
          icon: Icons.account_balance_wallet_rounded,
          title: 'Balance pendiente',
          value: '\$22.500',
          subtitle: 'Saldo general considerando todos tus grupos',
        ),
      ],
    );
  }
}

/// Tarjeta chica usada dentro de las estadisticas del perfil.
class _SmallBentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _SmallBentoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: SizedBox(
          height: 128,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightSurfaceVariant,
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tarjeta ancha para destacar un dato del perfil.
class _WideBentoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;

  const _WideBentoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.warning.withValues(alpha: 0.14),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
