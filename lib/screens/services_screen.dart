import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({required this.onBook, required this.onBack, super.key});

  final VoidCallback onBook;
  final VoidCallback onBack;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String _query = '';

  static const _services = [
    _StudioService(
      category: 'Producto · Estudio',
      title: 'Fotografía de Producto & Branding',
      description: 'Imágenes para ecommerce, catálogo y redes con iluminación profesional y retoque.',
      price: '\$350.000',
      image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1000&q=85',
      turnaround: '30 fotos retocadas',
    ),
    _StudioService(
      category: 'Audiovisual',
      title: 'Video Promocional & Reels',
      description: 'Producción audiovisual y reels verticales listos para tus plataformas.',
      price: '\$200.000',
      image: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=1000&q=85',
      turnaround: '3 formatos editados',
    ),
    _StudioService(
      category: 'Multicámara',
      title: 'Cobertura de Evento',
      description: 'Registro documental de congresos, pasarelas y lanzamientos de producto.',
      price: '\$250.000',
      image: 'https://images.unsplash.com/photo-1503095396549-807759245b35?auto=format&fit=crop&w=1000&q=85',
      turnaround: 'Galería digital rápida',
    ),
    _StudioService(
      category: 'Director de arte',
      title: 'Lookbook & Moda Editorial',
      description: 'Dirección de arte, modelos y estilismo en locaciones para tu colección.',
      price: '\$250.000',
      image: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1000&q=85',
      turnaround: 'Full production pack',
    ),
    _StudioService(
      category: 'Diseño gráfico',
      title: 'Branding o re-branding de marca',
      description:
          'Identidad visual, estrategia y contenido fotográfico para tu marca.',
      price: '\$1.600.000',
      image: 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?auto=format&fit=crop&w=1000&q=85',
      turnaround: 'Entrega en 16 días',
    ),
    _StudioService(
      category: 'Video 4K / 60p',
      title: 'Cinefotografía & contenido audiovisual',
      description:
          'Producción cinematográfica para proyectos que necesitan contar más.',
      price: '\$400.000',
      image: 'https://images.unsplash.com/photo-1485846234645-a62644f84728?auto=format&fit=crop&w=1000&q=85',
      turnaround: 'Log & LUT',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredServices = _services.where((service) {
      final query = _query.trim().toLowerCase();
      return query.isEmpty ||
          service.title.toLowerCase().contains(query) ||
          service.category.toLowerCase().contains(query);
    }).toList();

    return CustomScrollView(
      key: const PageStorageKey('services-screen'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              children: [
                _HeaderButton(
                  icon: Icons.arrow_back_rounded,
                  label: 'Volver',
                  onPressed: widget.onBack,
                ),
                const SizedBox(width: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/images/reflexcam_logo.png',
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REFLEXCAM',
                        style: TextStyle(
                          color: ReflexColors.orange,
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        'SERVICIOS',
                        style: TextStyle(
                          color: ReflexColors.text,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          height: 1.05,
                        ),
                      ),
                    ],
                  ),
                ),
                _HeaderButton(
                  icon: Icons.notifications_none_rounded,
                  label: 'Notificaciones',
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('No tienes notificaciones nuevas.'),
                      ),
                    ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 34, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PRODUCCIÓN AUDIOVISUAL',
                  style: TextStyle(
                    color: ReflexColors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.6,
                  ),
                ),
                SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Catálogo de Servicios',
                    softWrap: false,
                    style: TextStyle(
                      color: ReflexColors.text,
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1.2,
                      height: 1.1,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Soluciones técnicas y artísticas de alta fidelidad cinematográfica en fotografía fija, cinematografía digital y diseño gráfico.',
                  style: TextStyle(
                    color: ReflexColors.muted,
                    fontSize: 18,
                    height: 1.65,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Buscar servicio...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: IconButton(
                  tooltip: 'Filtros',
                  onPressed: () => ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Mostrando todos los servicios.'),
                      ),
                    ),
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: filteredServices.isEmpty
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 38),
                    child: Text(
                      'No encontramos servicios para esa búsqueda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: ReflexColors.muted, fontSize: 14),
                    ),
                  ),
                )
              : SliverList.separated(
                  itemCount: filteredServices.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 15),
                  itemBuilder: (context, index) => _ServiceCard(
                    service: filteredServices[index],
                    onBook: widget.onBook,
                  ),
                ),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: label,
      style: IconButton.styleFrom(
        backgroundColor: ReflexColors.surface,
        foregroundColor: ReflexColors.text,
        fixedSize: const Size(54, 54),
      ),
      icon: Icon(icon, size: 25),
    );
  }
}

class _StudioService {
  const _StudioService({
    required this.category,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.turnaround,
  });

  final String category;
  final String title;
  final String description;
  final String price;
  final String image;
  final String turnaround;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service, required this.onBook});

  final _StudioService service;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhotoCover(
            url: service.image,
            height: 164,
            overlay: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: TagPill(service.category),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 12, 5, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    service.title,
                    style: const TextStyle(
                      color: ReflexColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Desde ${service.price}',
                  style: const TextStyle(
                    color: ReflexColors.orangeLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 7, 5, 0),
            child: Text(
              service.description,
              style: const TextStyle(
                color: ReflexColors.muted,
                fontSize: 14,
                height: 1.45,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(5, 12, 5, 2),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_outlined,
                  color: ReflexColors.orangeLight,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    service.turnaround,
                    style: const TextStyle(
                      color: ReflexColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onBook,
                  child: const Text(
                    'Ver detalle  ›',
                    style: TextStyle(
                      color: ReflexColors.orangeLight,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
