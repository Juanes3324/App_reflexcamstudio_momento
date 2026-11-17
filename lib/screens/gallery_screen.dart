import 'package:flutter/material.dart';

import '../services/gallery_repository.dart';
import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({required this.repository, super.key});

  final GalleryRepository repository;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const _disciplines = ['Todos', 'Fotografía', 'Video'];

  late Future<List<GallerySession>> _sessionsFuture;
  String _selectedDiscipline = 'Todos';
  bool _showPortfolio = false;
  GallerySession? _activeSession;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = widget.repository.listMyGalleries();
  }

  void _reload() {
    setState(() {
      _activeSession = null;
      _sessionsFuture = widget.repository.listMyGalleries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeSession = _activeSession;
    if (activeSession != null) return _buildPhotoGallery(activeSession);

    return FutureBuilder<List<GallerySession>>(
      future: _sessionsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildError(snapshot.error!);
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(color: ReflexColors.orange),
          );
        }

        final allSessions = snapshot.data ?? const <GallerySession>[];
        final matchingSessions = allSessions.where((session) {
          return _selectedDiscipline == 'Todos' ||
              session.category == _selectedDiscipline;
        }).toList();
        final sessions = !_showPortfolio && _selectedDiscipline == 'Todos'
            ? matchingSessions.take(2).toList()
            : matchingSessions;

        return _buildSessions(allSessions, sessions);
      },
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              color: ReflexColors.orange,
              size: 35,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar tus galerías.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ReflexColors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: ReflexColors.muted, fontSize: 11),
            ),
            const SizedBox(height: 14),
            TextButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Intentar de nuevo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessions(
    List<GallerySession> allSessions,
    List<GallerySession> sessions,
  ) {
    return CustomScrollView(
      key: const PageStorageKey('gallery-screen'),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Eyebrow(
                    'Entregas privadas',
                    color: ReflexColors.muted,
                  ),
                ),
                const Spacer(),
                Text(
                  '${sessions.length.toString().padLeft(2, '0')} DISPONIBLES',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ReflexColors.muted,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              scrollDirection: Axis.horizontal,
              itemCount: _disciplines.length,
              separatorBuilder: (context, index) => const SizedBox(width: 7),
              itemBuilder: (context, index) {
                final discipline = _disciplines[index];
                final selected = _selectedDiscipline == discipline;
                return ChoiceChip(
                  key: ValueKey('discipline-$discipline'),
                  label: Text(discipline),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) =>
                      setState(() => _selectedDiscipline = discipline),
                  backgroundColor: ReflexColors.surface,
                  selectedColor: ReflexColors.orange,
                  side: BorderSide(
                    color: selected ? ReflexColors.orange : ReflexColors.line,
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? const Color(0xFF17120E)
                        : ReflexColors.muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  shape: const StadiumBorder(),
                );
              },
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tus proyectos',
                    style: TextStyle(
                      color: ReflexColors.text,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('gallery-refresh'),
                  tooltip: 'Actualizar galerías',
                  onPressed: _reload,
                  icon: const Icon(Icons.refresh_rounded),
                ),
                IconButton(
                  key: const ValueKey('gallery-portfolio-toggle'),
                  tooltip: _showPortfolio ? 'Mostrar recientes' : 'Ver todas',
                  onPressed: () =>
                      setState(() => _showPortfolio = !_showPortfolio),
                  icon: Icon(
                    _showPortfolio
                        ? Icons.history_rounded
                        : Icons.arrow_forward_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (sessions.isEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 24),
              child: Text(
                allSessions.isEmpty
                    ? 'Tus entregas aparecerán aquí cuando Reflexcam las publique.'
                    : 'No hay entregas en esta disciplina.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ReflexColors.muted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 22),
            sliver: SliverList.separated(
              itemCount: sessions.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _SessionCard(
                session: sessions[index],
                onTap: () => setState(() => _activeSession = sessions[index]),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoGallery(GallerySession session) {
    return CustomScrollView(
      key: const PageStorageKey('gallery-photo-selection'),
      slivers: [
        SliverToBoxAdapter(
          child: ScreenHeader(
            eyebrow: 'Entrega privada · ${session.category}',
            title: session.title,
            subtitle: session.dateLabel,
            trailing: IconButton(
              key: const ValueKey('gallery-back-to-sessions'),
              tooltip: 'Volver a sesiones',
              onPressed: () => setState(() => _activeSession = null),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 15),
            child: SurfaceCard(
              padding: const EdgeInsets.all(14),
              child: const Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: ReflexColors.orange,
                    size: 19,
                  ),
                  SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      'Esta galería solo es visible para ti y tu equipo creativo.',
                      style: TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (session.photos.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'La entrega todavía no tiene fotografías publicadas.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ReflexColors.muted, fontSize: 13),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid.builder(
              itemCount: session.photos.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.79,
              ),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  session.photos[index].toString(),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: ReflexColors.surfaceRaised,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.image_not_supported_outlined,
                      color: ReflexColors.muted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
            child: Text(
              '${session.photos.length} fotografías',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ReflexColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({required this.session, required this.onTap});

  final GallerySession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cover = session.photos.isEmpty ? null : session.photos.first;
    return Material(
      color: ReflexColors.surface,
      child: InkWell(
        key: ValueKey('session-${session.title}'),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: ReflexColors.line, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 210,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (cover == null)
                      const ColoredBox(
                        color: ReflexColors.surfaceRaised,
                        child: Icon(
                          Icons.photo_library_outlined,
                          color: ReflexColors.muted,
                          size: 32,
                        ),
                      )
                    else
                      Image.network(
                        cover.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const ColoredBox(
                              color: ReflexColors.surfaceRaised,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: ReflexColors.muted,
                                size: 28,
                              ),
                            ),
                      ),
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: _SessionImageLabel('ENTREGA PRIVADA'),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: _SessionImageLabel(
                        '${session.photos.length} FOTOS',
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: ReflexColors.text,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          session.dateLabel,
                          style: const TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      '${session.category} · ${session.photos.length} fotografías disponibles.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          color: ReflexColors.muted,
                          size: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${session.photos.length} Archivos',
                          style: const TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.lock_outline_rounded,
                          color: ReflexColors.muted,
                          size: 15,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          session.status,
                          style: const TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SessionImageLabel extends StatelessWidget {
  const _SessionImageLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE8202022),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: const TextStyle(
            color: ReflexColors.text,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
