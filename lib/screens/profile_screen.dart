import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    required this.onSignOut,
    required this.userEmail,
    super.key,
  });

  final Future<void> Function() onSignOut;

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
                        'RC',
                        style: TextStyle(
                          color: ReflexColors.orangeLight,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cuenta Reflexcam',
                            style: TextStyle(
                              color: ReflexColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            userEmail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ReflexColors.muted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
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
                      onTap: () => _closeSession(context),
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
                  fontSize: 10,
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

  final String userEmail;

  Future<void> _closeSession(BuildContext context) async {
    try {
      await onSignOut();
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('No se pudo cerrar la sesión: $error')),
        );
    }
  }

  void _notify(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$label próximamente.')));
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
          fontSize: 14,
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
