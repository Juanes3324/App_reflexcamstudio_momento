import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  static const _photos = [
    'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1531123897727-8f129e1688ce?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1529139574466-a303027c1d8b?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1492562080023-ab3db95bfbce?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1504593811423-6dd665756598?auto=format&fit=crop&w=600&h=760&q=85',
    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=600&h=760&q=85',
  ];

  late final Set<int> _selected = Set<int>.of(
    List<int>.generate(_photos.length, (index) => index),
  );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const PageStorageKey('gallery-screen'),
      slivers: [
        SliverToBoxAdapter(
          child: ScreenHeader(
            eyebrow: 'Tus recuerdos, en privado',
            title: 'Galería privada',
            subtitle: 'Selecciona las fotografías que quieres recibir.',
            trailing: IconButton(
              tooltip: 'Más opciones',
              onPressed: () => ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  const SnackBar(content: Text('Tu galería es privada.')),
                ),
              icon: const Icon(Icons.more_horiz_rounded),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
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
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid.builder(
            itemCount: _photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.79,
            ),
            itemBuilder: (context, index) {
              final selected = _selected.contains(index);
              return Semantics(
                button: true,
                label:
                    'Fotografía ${index + 1}, ${selected ? 'seleccionada' : 'no seleccionada'}',
                child: GestureDetector(
                  onTap: () => setState(() {
                    if (!_selected.add(index)) _selected.remove(index);
                  }),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _photos[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                color: ReflexColors.surfaceRaised,
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: ReflexColors.muted,
                                ),
                              ),
                        ),
                        if (selected)
                          Container(
                            decoration: BoxDecoration(
                              color: ReflexColors.orange.withValues(
                                alpha: 0.13,
                              ),
                              border: Border.all(
                                color: ReflexColors.orange,
                                width: 1.5,
                              ),
                            ),
                          ),
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Icon(
                            selected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked_rounded,
                            color: selected
                                ? ReflexColors.orange
                                : Colors.white.withValues(alpha: 0.75),
                            size: 19,
                          ),
                        ),
                        Positioned(
                          left: 7,
                          bottom: 7,
                          child: Text(
                            (index + 1).toString().padLeft(2, '0'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              shadows: [Shadow(blurRadius: 4)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: SurfaceCard(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    color: ReflexColors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      '${_selected.length} de ${_photos.length} fotografías seleccionadas',
                      style: const TextStyle(
                        color: ReflexColors.text,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() {
                      if (_selected.length == _photos.length) {
                        _selected.clear();
                      } else {
                        _selected
                          ..clear()
                          ..addAll(
                            List<int>.generate(
                              _photos.length,
                              (index) => index,
                            ),
                          );
                      }
                    }),
                    child: Text(
                      _selected.length == _photos.length ? 'Limpiar' : 'Todas',
                      style: const TextStyle(
                        color: ReflexColors.orangeLight,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: PrimaryButton(
              label: 'ENVIAR SELECCIÓN (${_selected.length} FOTOS)',
              onPressed: _selected.isEmpty
                  ? null
                  : () => ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Selección de ${_selected.length} fotos lista para enviar.',
                          ),
                        ),
                      ),
              icon: Icons.send_rounded,
            ),
          ),
        ),
      ],
    );
  }
}
