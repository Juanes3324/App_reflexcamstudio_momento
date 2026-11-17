import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.onBook, required this.onProject, super.key});

  final VoidCallback onBook;
  final VoidCallback onProject;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _disciplines = ['Todos', 'Fotografía', 'Video', 'Diseño'];
  String _selectedDiscipline = 'Todos';

  static const _sessions = [
    _RecentSession(
      discipline: 'Fotografía',
      title: 'Campaña Oro puro',
      detail: '18 tomas master aprobadas en resolución editorial y reels 9:16.',
      date: 'Hace 2 días',
      files: 24,
      status: 'Sincronizado',
      camera: 'PRODUCTO · 50MM F/1.2',
      format: 'RAW · DCI 4K',
      image: 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=1000&h=620&q=85',
    ),
    _RecentSession(
      discipline: 'Fotografía',
      title: 'Fotografías de producto',
      detail:
          'Retratos naturales de equipo con óptica fija y revelado analógico.',
      date: '18 Feb',
      files: 36,
      status: 'Finalizado',
      camera: 'RETRATOS · 85MM F/1.4',
      format: 'VER · 14',
      image: 'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=1000&h=620&q=85',
    ),
    _RecentSession(
      discipline: 'Video',
      title: 'Reels nueva colección',
      detail:
          'Piezas verticales listas para redes con edición cinematográfica.',
      date: '12 Feb',
      files: 12,
      status: 'En edición',
      camera: 'VIDEO · 4K / 60P',
      format: 'VER · 6',
      image: 'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4?auto=format&fit=crop&w=1000&h=620&q=85',
    ),
    _RecentSession(
      discipline: 'Diseño',
      title: 'Identidad visual ORO',
      detail: 'Dirección de arte y recursos visuales para la marca.',
      date: '06 Feb',
      files: 18,
      status: 'Finalizado',
      camera: 'DIRECCIÓN DE ARTE',
      format: 'VER · 18',
      image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=1000&h=620&q=85',
    ),
  ];

  List<_RecentSession> get _visibleSessions => _sessions
      .where(
        (session) =>
            _selectedDiscipline == 'Todos' ||
            session.discipline == _selectedDiscipline,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final visibleSessions = _visibleSessions;
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/reflexcam_logo.png',
                      fit: BoxFit.cover,
                    ),
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
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'STUDIO',
                      style: TextStyle(
                        color: ReflexColors.muted,
                        letterSpacing: 2.1,
                        fontSize: 10,
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
                  style: TextStyle(color: ReflexColors.muted, fontSize: 16),
                ),
                const SizedBox(height: 18),
                _ProjectTimelineCard(onTap: widget.onProject),
                const SizedBox(height: 14),
                PrimaryButton(
                  label: '+ AGENDAR SESIÓN',
                  onPressed: widget.onBook,
                  icon: null,
                  height: 54,
                ),
                const SizedBox(height: 17),
                Row(
                  children: [
                    const Eyebrow('Disciplinas', color: ReflexColors.muted),
                    const Spacer(),
                    Text(
                      '${_sessions.length.toString().padLeft(2, '0')} DISPONIBLES',
                      style: const TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _disciplines.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final discipline = _disciplines[index];
                      final selected = _selectedDiscipline == discipline;
                      return ChoiceChip(
                        key: ValueKey('home-discipline-$discipline'),
                        label: Text(discipline),
                        selected: selected,
                        showCheckmark: false,
                        onSelected: (_) =>
                            setState(() => _selectedDiscipline = discipline),
                        backgroundColor: ReflexColors.surface,
                        selectedColor: ReflexColors.orange,
                        side: BorderSide(
                          color: selected
                              ? ReflexColors.orange
                              : ReflexColors.line,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? const Color(0xFF17120E)
                              : ReflexColors.muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        shape: const StadiumBorder(),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Capturas Recientes',
                        style: const TextStyle(
                          color: ReflexColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      key: const ValueKey('home-portfolio'),
                      onPressed: widget.onProject,
                      style: TextButton.styleFrom(
                        foregroundColor: ReflexColors.orangeLight,
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text(
                        'PORTAFOLIO →',
                        style: TextStyle(
                          color: ReflexColors.orangeLight,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
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
          sliver: visibleSessions.isEmpty
              ? const SliverToBoxAdapter(
                  child: Text(
                    'No hay capturas en esta disciplina.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: ReflexColors.muted, fontSize: 12),
                  ),
                )
              : SliverList.separated(
                  itemCount: visibleSessions.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 14),
                  itemBuilder: (context, index) => _RecentSessionCard(
                    session: visibleSessions[index],
                    onTap: widget.onProject,
                  ),
                ),
        ),
      ],
    );
  }
}

class _ProjectTimelineCard extends StatelessWidget {
  const _ProjectTimelineCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF211F20), Color(0xFF1A191B)],
        ),
        border: Border.all(color: ReflexColors.line),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TagPill('Foto + video'),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'ID: RC-894',
                  style: TextStyle(
                    color: ReflexColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: ReflexColors.orange,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'EN EDICIÓN',
                style: TextStyle(
                  color: ReflexColors.orangeLight,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Fotografía de producto',
            style: TextStyle(
              color: ReflexColors.text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Línea de productos de joyería',
            style: TextStyle(color: ReflexColors.muted, fontSize: 14),
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Flujo de revelado RAW',
                  style: TextStyle(color: ReflexColors.muted, fontSize: 13),
                ),
              ),
              Text(
                '75%',
                style: TextStyle(
                  color: ReflexColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: const LinearProgressIndicator(
              value: 0.75,
              minHeight: 6,
              backgroundColor: ReflexColors.line,
              valueColor: AlwaysStoppedAnimation(ReflexColors.orange),
            ),
          ),
          const SizedBox(height: 13),
          const Divider(color: ReflexColors.line, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Entrega estimada: Mañana 18:00',
                  style: TextStyle(color: ReflexColors.muted, fontSize: 12),
                ),
              ),
              TextButton(
                key: const ValueKey('home-view-project'),
                onPressed: onTap,
                style: TextButton.styleFrom(
                  foregroundColor: ReflexColors.orangeLight,
                  padding: const EdgeInsets.only(left: 8),
                  visualDensity: VisualDensity.compact,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver proyecto',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 3),
                    Icon(Icons.arrow_forward_rounded, size: 15),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentSession {
  const _RecentSession({
    required this.discipline,
    required this.title,
    required this.detail,
    required this.date,
    required this.files,
    required this.status,
    required this.camera,
    required this.format,
    required this.image,
  });

  final String discipline;
  final String title;
  final String detail;
  final String date;
  final int files;
  final String status;
  final String camera;
  final String format;
  final String image;
}

class _RecentSessionCard extends StatelessWidget {
  const _RecentSessionCard({required this.session, required this.onTap});
  final _RecentSession session;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ReflexColors.surface,
      child: InkWell(
        key: ValueKey('home-session-${session.title}'),
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
                    Image.network(
                      session.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: ReflexColors.surfaceRaised,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: ReflexColors.muted,
                          size: 28,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _CaptureImageLabel(session.camera),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: _CaptureImageLabel(session.format),
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
                          session.date,
                          style: const TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 7),
                    Text(
                      session.detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 14,
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
                          '${session.files} Archivos',
                          style: const TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          session.status == 'Finalizado'
                              ? Icons.verified_outlined
                              : Icons.cloud_done_outlined,
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

class _CaptureImageLabel extends StatelessWidget {
  const _CaptureImageLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xE8202022),
        borderRadius: BorderRadius.circular(22),
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
