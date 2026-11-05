import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.onSignOut, super.key});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('profile-screen'),
      slivers: [
        const SliverToBoxAdapter(
          child: ScreenHeader(
            eyebrow: 'Tu cuenta',
            title: 'Perfil',
            subtitle: 'Gestiona tu información y preferencias.',
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              SurfaceCard(
                child: Row(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A3028),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'GO',
                        style: TextStyle(
                          color: ReflexColors.orangeLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Grano de Oro',
                            style: TextStyle(
                              color: ReflexColors.text,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'hola@granodeoro.co',
                            style: TextStyle(
                              color: ReflexColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Editar perfil',
                      onPressed: () => ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('Edición de perfil no disponible.'),
                          ),
                        ),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: ReflexColors.orangeLight,
                        size: 19,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Eyebrow('Tu actividad'),
              const SizedBox(height: 10),
              const SurfaceCard(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: [
                    _ActivityRow(
                      icon: Icons.calendar_month_outlined,
                      title: 'Próxima sesión',
                      subtitle: 'Fotografía de Producto · 08 Oct, 10:00',
                      status: 'PENDIENTE',
                    ),
                    Divider(color: ReflexColors.line, height: 24),
                    _ActivityRow(
                      icon: Icons.photo_library_outlined,
                      title: 'Galería privada',
                      subtitle: '12 fotografías disponibles',
                      status: 'ACTIVA',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Eyebrow('Preferencias'),
              const SizedBox(height: 10),
              SurfaceCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    _ProfileItem(
                      icon: Icons.notifications_none_rounded,
                      title: 'Notificaciones',
                      onTap: () =>
                          _notify(context, 'Preferencias de notificación'),
                    ),
                    const Divider(
                      color: ReflexColors.line,
                      height: 1,
                      indent: 52,
                    ),
                    _ProfileItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Ayuda y soporte',
                      onTap: () => _notify(context, 'Ayuda y soporte'),
                    ),
                    const Divider(
                      color: ReflexColors.line,
                      height: 1,
                      indent: 52,
                    ),
                    _ProfileItem(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacidad y términos',
                      onTap: () => _notify(context, 'Privacidad y términos'),
                    ),
                    const Divider(
                      color: ReflexColors.line,
                      height: 1,
                      indent: 52,
                    ),
                    _ProfileItem(
                      icon: Icons.logout_rounded,
                      title: 'Cerrar sesión',
                      color: const Color(0xFFFF8C80),
                      onTap: onSignOut,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'REFLEXCAM STUDIO  ·  VERSIÓN 1.0',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ReflexColors.muted,
                  fontSize: 9,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  void _notify(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label próximamente.')));
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: ReflexColors.orange, size: 19),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ReflexColors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: ReflexColors.muted, fontSize: 10),
              ),
            ],
          ),
        ),
        TagPill(status),
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = ReflexColors.text,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 19),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: ReflexColors.muted,
        size: 19,
      ),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15),
    );
  }
}
