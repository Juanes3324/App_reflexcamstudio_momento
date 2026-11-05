import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({required this.onComplete, super.key});

  final VoidCallback onComplete;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  int _step = 0;
  DateTime _displayedMonth = DateTime(2026, 10);
  int _selectedDay = 8;
  String _selectedTime = '10:00';
  String _location = 'Estudio Reflexcam';
  bool _termsAccepted = false;
  bool _sent = false;
  final Set<String> _selectedServices = {'Fotografía de Producto & Branding'};
  final Set<String> _selectedExtras = {};
  final TextEditingController _addressController = TextEditingController();

  static const _services = [
    _BookingService(
      category: 'Foto estudio',
      title: 'Fotografía de Producto & Branding',
      description: 'Tarifas en alta resolución para ecommerce, catálogo y redes sociales.',
      deliverable: '30 fotos retocadas',
      price: 350000,
      icon: Icons.camera_alt_outlined,
      tag: '4H ESTUDIO',
    ),
    _BookingService(
      category: 'Video 4K / 60P',
      title: 'Video Promocional & Reels',
      description:
          'Producción audiovisual y reels verticales listos para redes.',
      deliverable: '3 formatos editados',
      price: 200000,
      icon: Icons.videocam_outlined,
      tag: 'TOP CHOICE',
    ),
    _BookingService(
      category: 'Multicámara',
      title: 'Cobertura de Evento',
      description:
          'Registro documental de congresos, pasarelas y lanzamientos.',
      deliverable: 'Galería digital rápida',
      price: 250000,
      icon: Icons.bolt_outlined,
      tag: 'EVENTO',
    ),
    _BookingService(
      category: 'Director de arte',
      title: 'Lookbook & Moda Editorial',
      description:
          'Modelos, estilismo y scouting de locación para tu colección.',
      deliverable: 'Full production pack',
      price: 250000,
      icon: Icons.copy_all_outlined,
      tag: 'EDITORIAL',
    ),
  ];

  static const _extras = [
    ('Asistente de estilismo', 80000),
    ('Iluminación extra', 50000),
    ('Entrega express', 70000),
  ];

  static const _monthNames = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  static const _weekdayNames = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo',
  ];

  int get _daysInMonth =>
      DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

  int get _leadingDays =>
      DateTime(_displayedMonth.year, _displayedMonth.month).weekday - 1;

  String get _monthName => _monthNames[_displayedMonth.month - 1];

  String get _selectedWeekday =>
      _weekdayNames[DateTime(
            _displayedMonth.year,
            _displayedMonth.month,
            _selectedDay,
          ).weekday -
          1];

  int get _servicesTotal => _services
      .where((service) => _selectedServices.contains(service.title))
      .fold(0, (total, service) => total + service.price);

  int get _extrasTotal => _extras
      .where((extra) => _selectedExtras.contains(extra.$1))
      .fold(0, (total, extra) => total + extra.$2);

  int get _total => _servicesTotal + _extrasTotal;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_sent) {
      return _ConfirmationScreen(onComplete: widget.onComplete);
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            key: PageStorageKey('booking-step-$_step'),
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ScreenHeader(
                  eyebrow: 'Servicios y gestión de sesiones',
                  title: _stepTitle,
                  subtitle: _stepSubtitle,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 17),
                  child: _ProgressHeader(currentStep: _step),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildStepContent(),
                ),
              ],
            ),
          ),
        ),
        _buildActionArea(),
      ],
    );
  }

  String get _stepTitle => switch (_step) {
    0 => 'Selecciona tu servicio',
    1 => 'Fecha y disponibilidad',
    2 => 'Ubicación de la sesión',
    _ => 'Resumen de tu reserva',
  };

  String get _stepSubtitle => switch (_step) {
    0 => 'Elige los servicios que mejor se ajustan a tu proyecto.',
    1 => 'Selecciona el día y el horario de tu sesión.',
    2 => 'Cuéntanos dónde y cómo quieres producir.',
    _ => 'Revisa los detalles antes de enviar tu solicitud.',
  };

  Widget _buildStepContent() {
    return switch (_step) {
      0 => _buildServiceSelection(),
      1 => _buildDateSelection(),
      2 => _buildLocationSelection(),
      _ => _buildSummary(),
    };
  }

  Widget _buildServiceSelection() {
    return Column(
      children: [
        for (final service in _services) ...[
          _ServiceOption(
            service: service,
            selected: _selectedServices.contains(service.title),
            onTap: () => setState(() {
              if (!_selectedServices.add(service.title)) {
                _selectedServices.remove(service.title);
              }
            }),
          ),
          const SizedBox(height: 12),
        ],
        SurfaceCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: ReflexColors.orange,
                    size: 17,
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Modalidad de Producción',
                      style: TextStyle(
                        color: ReflexColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Eyebrow('Requerido'),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _LocationChoice(
                      icon: Icons.apartment_outlined,
                      label: 'En Estudio\nReflexcam',
                      selected: _location == 'Estudio Reflexcam',
                      onTap: () =>
                          setState(() => _location = 'Estudio Reflexcam'),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: _LocationChoice(
                      icon: Icons.storefront_outlined,
                      label: 'En mi negocio /\nLocación',
                      selected: _location == 'Mi negocio / Locación',
                      onTap: () =>
                          setState(() => _location = 'Mi negocio / Locación'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelection() {
    final dayNames = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '$_monthName ${_displayedMonth.year}',
                      style: const TextStyle(
                        color: ReflexColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(-1),
                    icon: const Icon(Icons.chevron_left_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => _changeMonth(1),
                    icon: const Icon(Icons.chevron_right_rounded, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 9),
              Row(
                children: [
                  for (final day in dayNames)
                    Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _leadingDays + _daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  if (index < _leadingDays) return const SizedBox.shrink();
                  final day = index - _leadingDays + 1;
                  final isPast =
                      _displayedMonth.year == 2026 &&
                      _displayedMonth.month == 10 &&
                      day < 5;
                  final selected = day == _selectedDay;
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: Material(
                      color: selected
                          ? ReflexColors.orange
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: isPast
                            ? null
                            : () => setState(() => _selectedDay = day),
                        borderRadius: BorderRadius.circular(12),
                        child: Center(
                          child: Text(
                            '$day',
                            style: TextStyle(
                              color: selected
                                  ? const Color(0xFF17120E)
                                  : isPast
                                  ? ReflexColors.muted.withValues(alpha: 0.4)
                                  : ReflexColors.text,
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w900
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const Divider(color: ReflexColors.line, height: 21),
              const Row(
                children: [
                  Icon(Icons.circle, size: 8, color: ReflexColors.orange),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Fecha seleccionada',
                      style: TextStyle(color: ReflexColors.muted, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'ZONA HORARIA (GMT-5)',
                    style: TextStyle(
                      color: ReflexColors.muted,
                      fontSize: 7,
                      letterSpacing: 0.4,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Horarios disponibles',
                style: TextStyle(
                  color: ReflexColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '$_selectedWeekday $_selectedDay',
              style: const TextStyle(color: ReflexColors.muted, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 9,
          runSpacing: 9,
          children: [
            for (final time in ['09:00', '10:00', '14:00', '15:00', '16:00'])
              ChoiceChip(
                label: Text(time),
                selected: time == _selectedTime,
                onSelected: (_) => setState(() => _selectedTime = time),
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: time == _selectedTime
                      ? const Color(0xFF17120E)
                      : ReflexColors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                ),
                selectedColor: ReflexColors.orange,
                backgroundColor: ReflexColors.surface,
                side: BorderSide(
                  color: time == _selectedTime
                      ? ReflexColors.orange
                      : ReflexColors.line,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SurfaceCard(
          padding: const EdgeInsets.all(13),
          child: const Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                size: 17,
                color: ReflexColors.muted,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      color: ReflexColors.muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                    children: [
                      TextSpan(text: '¿No encuentras un horario conveniente? '),
                      TextSpan(
                        text: 'Escríbenos por WhatsApp',
                        style: TextStyle(
                          color: ReflexColors.orangeLight,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Elige el tipo de producción'),
              const SizedBox(height: 12),
              _LocationChoice(
                icon: Icons.apartment_outlined,
                label: 'En Estudio Reflexcam',
                selected: _location == 'Estudio Reflexcam',
                onTap: () => setState(() => _location = 'Estudio Reflexcam'),
              ),
              const SizedBox(height: 9),
              _LocationChoice(
                icon: Icons.storefront_outlined,
                label: 'En mi negocio / Locación',
                selected: _location == 'Mi negocio / Locación',
                onTap: () =>
                    setState(() => _location = 'Mi negocio / Locación'),
              ),
              if (_location == 'Mi negocio / Locación') ...[
                const SizedBox(height: 13),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    hintText: 'Dirección de la locación',
                    prefixIcon: Icon(Icons.location_on_outlined, size: 19),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bogotá, Colombia · La ubicación se confirma con el equipo.',
                  style: TextStyle(
                    color: ReflexColors.muted,
                    fontSize: 10,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 13),
        SurfaceCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    color: ReflexColors.orange,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Servicios adicionales',
                      style: TextStyle(
                        color: ReflexColors.text,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Eyebrow('Opcional'),
                ],
              ),
              const SizedBox(height: 5),
              const Text(
                'Personaliza tu producción.',
                style: TextStyle(color: ReflexColors.muted, fontSize: 11),
              ),
              const SizedBox(height: 7),
              for (final extra in _extras)
                Material(
                  color: Colors.transparent,
                  child: CheckboxListTile(
                    value: _selectedExtras.contains(extra.$1),
                    onChanged: (selected) => setState(() {
                      if (selected ?? false) {
                        _selectedExtras.add(extra.$1);
                      } else {
                        _selectedExtras.remove(extra.$1);
                      }
                    }),
                    title: Text(
                      extra.$1,
                      style: const TextStyle(
                        color: ReflexColors.text,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '+ \$${_formatPrice(extra.$2)}',
                      style: const TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 10,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    activeColor: ReflexColors.orange,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        SurfaceCard(
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: ReflexColors.orange,
                size: 18,
              ),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  '¿Requieres asistente de estilismo o iluminación extra? Puedes añadir extras en este paso o conversar con el director técnico.',
                  style: TextStyle(
                    color: ReflexColors.muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final deposit = (_total / 2).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Detalles de la sesión'),
              const SizedBox(height: 15),
              _SummaryRow(
                icon: Icons.camera_alt_outlined,
                label: 'Servicio(s)',
                value: _selectedServices.join(', '),
              ),
              const Divider(color: ReflexColors.line, height: 25),
              _SummaryRow(
                icon: Icons.calendar_month_outlined,
                label: 'Fecha y hora',
                value:
                    '$_selectedWeekday $_selectedDay de $_monthName · $_selectedTime',
              ),
              const Divider(color: ReflexColors.line, height: 25),
              _SummaryRow(
                icon: Icons.location_on_outlined,
                label: 'Lugar',
                value: _location,
              ),
              if (_selectedExtras.isNotEmpty) ...[
                const Divider(color: ReflexColors.line, height: 25),
                _SummaryRow(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Adicionales',
                  value: _selectedExtras.join(', '),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 13),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Resumen económico'),
              const SizedBox(height: 13),
              _PriceRow(label: 'Total de producción', value: _total),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF35261E),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ANTICIPO REQUERIDO (50%)',
                            style: TextStyle(
                              color: ReflexColors.orangeLight,
                              fontSize: 9,
                              letterSpacing: 0.7,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Para bloquear fecha y hora',
                            style: TextStyle(
                              color: ReflexColors.muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${_formatPrice(deposit)}',
                      style: const TextStyle(
                        color: ReflexColors.orange,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'Transferencia bancaria, PSE o tarjeta. El saldo restante se cancela antes de la sesión.',
                style: TextStyle(
                  color: ReflexColors.muted,
                  fontSize: 10,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        SurfaceCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Material(
            color: Colors.transparent,
            child: CheckboxListTile(
              value: _termsAccepted,
              onChanged: (value) =>
                  setState(() => _termsAccepted = value ?? false),
              activeColor: ReflexColors.orange,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: const Text(
                'Acepto los términos del servicio y la política de cancelación.',
                style: TextStyle(
                  color: ReflexColors.text,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionArea() {
    final canContinue = switch (_step) {
      0 => _selectedServices.isNotEmpty,
      3 => _termsAccepted,
      _ => true,
    };
    final label = switch (_step) {
      0 => 'CONTINUAR A FECHA',
      1 => 'CONTINUAR',
      2 => 'CONTINUAR A RESUMEN',
      _ => 'ENVIAR SOLICITUD DE RESERVA',
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 13),
      decoration: const BoxDecoration(
        color: ReflexColors.background,
        border: Border(top: BorderSide(color: ReflexColors.line, width: 0.6)),
      ),
      child: Column(
        children: [
          PrimaryButton(label: label, onPressed: canContinue ? _advance : null),
          const SizedBox(height: 6),
          Text(
            switch (_step) {
              0 => 'PASO 1 DE 4 · SERVICIO Y DISPONIBILIDAD',
              1 => 'PASO 2 DE 4 · FECHA Y HORARIO',
              2 => 'PASO 3 DE 4 · LUGAR Y LOGÍSTICA',
              _ => 'PASO 4 DE 4 · REVISIÓN Y ANTICIPO',
            },
            style: const TextStyle(
              color: ReflexColors.muted,
              fontSize: 8,
              letterSpacing: 0.75,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  void _advance() {
    if (_step < 3) {
      setState(() => _step++);
      return;
    }
    if (!_termsAccepted) return;
    setState(() => _sent = true);
  }

  void _changeMonth(int offset) {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + offset,
      );
      if (_selectedDay > _daysInMonth) _selectedDay = _daysInMonth;
    });
  }
}

class _BookingService {
  const _BookingService({
    required this.category,
    required this.title,
    required this.description,
    required this.deliverable,
    required this.price,
    required this.icon,
    required this.tag,
  });

  final String category;
  final String title;
  final String description;
  final String deliverable;
  final int price;
  final IconData icon;
  final String tag;
}

class _ServiceOption extends StatelessWidget {
  const _ServiceOption({
    required this.service,
    required this.selected,
    required this.onTap,
  });

  final _BookingService service;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(13),
      borderColor: selected ? ReflexColors.orange : ReflexColors.line,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: ReflexColors.surfaceRaised,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: ReflexColors.line),
              ),
              child: Icon(
                service.icon,
                color: ReflexColors.orangeLight,
                size: 19,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TagPill(service.tag),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          service.category.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 8,
                            letterSpacing: 0.55,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    service.title,
                    style: const TextStyle(
                      color: ReflexColors.text,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    service.description,
                    style: const TextStyle(
                      color: ReflexColors.muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome_outlined,
                        color: ReflexColors.orangeLight,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          service.deliverable.toUpperCase(),
                          style: const TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 8,
                            letterSpacing: 0.55,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      PriceLabel(price: '\$${_formatPrice(service.price)}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              selected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked_rounded,
              color: selected ? ReflexColors.orange : ReflexColors.line,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationChoice extends StatelessWidget {
  const _LocationChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFF30231B) : ReflexColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? ReflexColors.orange : ReflexColors.line,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: selected ? ReflexColors.orange : ReflexColors.muted,
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected
                        ? ReflexColors.orangeLight
                        : ReflexColors.text,
                    fontSize: 10,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.currentStep});
  final int currentStep;

  static const _labels = ['Servicio', 'Fecha', 'Lugar', 'Resumen'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var index = 0; index < _labels.length; index++) ...[
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: index <= currentStep
                      ? ReflexColors.orange
                      : ReflexColors.surfaceRaised,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: index <= currentStep
                        ? ReflexColors.orange
                        : ReflexColors.line,
                  ),
                ),
                child: Text(
                  index < currentStep ? '✓' : '${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF17120E),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _labels[index],
                style: TextStyle(
                  color: index == currentStep
                      ? ReflexColors.orangeLight
                      : ReflexColors.muted,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (index < _labels.length - 1)
            Expanded(
              child: Container(
                height: 1,
                margin: const EdgeInsets.only(left: 5, right: 5, bottom: 17),
                color: index < currentStep
                    ? ReflexColors.orange
                    : ReflexColors.line,
              ),
            ),
        ],
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: ReflexColors.orange, size: 17),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: ReflexColors.muted,
                  fontSize: 8,
                  letterSpacing: 0.7,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                value,
                style: const TextStyle(
                  color: ReflexColors.text,
                  fontSize: 11,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: ReflexColors.muted, fontSize: 11),
          ),
        ),
        Text(
          '\$${_formatPrice(value)}',
          style: const TextStyle(
            color: ReflexColors.text,
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _ConfirmationScreen extends StatelessWidget {
  const _ConfirmationScreen({required this.onComplete});
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: const Color(0xFF23352A),
                borderRadius: BorderRadius.circular(27),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: ReflexColors.success,
                size: 43,
              ),
            ),
            const SizedBox(height: 22),
            const Eyebrow('Solicitud enviada'),
            const SizedBox(height: 9),
            Text(
              'Tu momento\nempieza aquí.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontSize: 28, height: 1.12),
            ),
            const SizedBox(height: 12),
            const Text(
              'El equipo de ReflexCam revisará tu solicitud y se pondrá en contacto contigo para confirmar disponibilidad y pago.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ReflexColors.muted,
                height: 1.5,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 28),
            const SurfaceCard(
              child: Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    color: ReflexColors.orange,
                    size: 20,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Te responderemos dentro de las próximas 24 horas.',
                      style: TextStyle(
                        color: ReflexColors.text,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            PrimaryButton(
              label: 'VOLVER AL INICIO',
              onPressed: onComplete,
              icon: Icons.home_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

String _formatPrice(int price) {
  final digits = price.toString();
  final formatted = StringBuffer();
  for (var index = 0; index < digits.length; index++) {
    if (index > 0 && (digits.length - index) % 3 == 0) formatted.write('.');
    formatted.write(digits[index]);
  }
  return formatted.toString();
}
