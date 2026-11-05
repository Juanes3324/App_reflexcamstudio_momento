import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.onBook, required this.onServices, super.key});

  final VoidCallback onBook;
  final VoidCallback onServices;

  static const _featured = [
    _Feature(
      title: 'Fotografía de producto',
      detail: 'Imágenes que elevan tu marca.',
      price: 'Desde \$350.000',
      image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1000&q=85',
      badge: 'MÁS SOLICITADO',
    ),
    _Feature(
      title: 'Fotografía de joyería',
      detail: 'Cada detalle, en primer plano.',
      price: 'Desde \$550.000',
      image: 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=1000&q=85',
      badge: 'ESTUDIO',
    ),
    _Feature(
      title: 'Moda editorial',
      detail: 'Una identidad visual propia.',
      price: 'Desde \$1.600.000',
      image: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1000&q=85',
      badge: 'DIRECCIÓN DE ARTE',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('home-screen'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: ReflexColors.surfaceRaised,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: ReflexColors.line),
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    color: ReflexColors.orange,
                    size: 19,
                  ),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'REFLEXCAM',
                      style: TextStyle(
                        color: ReflexColors.text,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'STUDIO',
                      style: TextStyle(
                        color: ReflexColors.muted,
                        letterSpacing: 2.1,
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Notificaciones',
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('No tienes notificaciones nuevas.'),
                      ),
                    ),
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: ReflexColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 13, 20, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Bienvenido a ReflexCam Studio'),
                const SizedBox(height: 7),
                Text(
                  'Hola, Grano de Oro',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 5),
                const Text(
                  'Tu próxima gran imagen empieza aquí.',
                  style: TextStyle(color: ReflexColors.muted, fontSize: 13),
                ),
                const SizedBox(height: 19),
                _HeroCard(onBook: onBook),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Servicios destacados',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    TextButton(
                      onPressed: onServices,
                      child: const Text(
                        'Ver todos',
                        style: TextStyle(
                          color: ReflexColors.orangeLight,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 26),
          sliver: SliverList.separated(
            itemCount: _featured.length,
            separatorBuilder: (context, index) => const SizedBox(height: 14),
            itemBuilder: (context, index) =>
                _FeatureCard(feature: _featured[index], onTap: onBook),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 25),
            child: SurfaceCard(
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_outlined,
                    color: ReflexColors.orange,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '¿Tienes un proyecto especial?',
                      style: TextStyle(
                        color: ReflexColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onBook,
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      color: ReflexColors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.onBook});
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        height: 230,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=1100&q=85',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: ReflexColors.surfaceRaised,
                child: const Icon(
                  Icons.photo_camera_back_outlined,
                  color: ReflexColors.muted,
                  size: 45,
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x16000000), Color(0xE9000000)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const TagPill('Tu historia, en imágenes'),
                  const SizedBox(height: 10),
                  const Text(
                    'Creamos imágenes\nque hacen la diferencia.',
                    style: TextStyle(
                      fontSize: 21,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 40,
                    child: FilledButton(
                      onPressed: onBook,
                      style: FilledButton.styleFrom(
                        backgroundColor: ReflexColors.orange,
                        foregroundColor: const Color(0xFF17120E),
                        elevation: 6,
                        shadowColor: ReflexColors.orange.withValues(
                          alpha: 0.38,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'AGENDA SESIÓN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.7,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 16),
                        ],
                      ),
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

class _Feature {
  const _Feature({
    required this.title,
    required this.detail,
    required this.price,
    required this.image,
    required this.badge,
  });

  final String title;
  final String detail;
  final String price;
  final String image;
  final String badge;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.onTap});
  final _Feature feature;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoCover(
            url: feature.image,
            height: 160,
            overlay: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TagPill(feature.badge),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 12, 5, 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feature.title,
                        style: const TextStyle(
                          color: ReflexColors.text,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        feature.detail,
                        style: const TextStyle(
                          color: ReflexColors.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  feature.price,
                  style: const TextStyle(
                    color: ReflexColors.orangeLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              child: const Text(
                'Ver detalle  ›',
                style: TextStyle(
                  color: ReflexColors.orangeLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
