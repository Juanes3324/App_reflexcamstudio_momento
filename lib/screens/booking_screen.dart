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
  bool _assistantRequired = true;
  final Set<String> _selectedServices = {'Fotografía de Producto & Branding'};
  final Set<String> _selectedExtras = {};
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _logisticsController = TextEditingController();

  static const _services = [
    _BookingService(
      category: 'Foto estudio',
      title: 'Fotografía de Producto & Branding',
      description: 'Tomas en alta resolución para ecommerce, catálogo y redes con calibración de color, iluminación estroboscópica y tethering en vivo.',
      deliverable: '30 fotos retocadas',
      price: 350000,
      icon: Icons.camera_alt_outlined,
      tag: '4H ESTUDIO',
    ),
    _BookingService(
      category: 'Video 4K / 60P',
      title: 'Video Promocional & Reels',
      description: 'Producción audiovisual y reels verticales 9:16 cinematográficos, etalonaje profesional y optimización para anuncios de alto impacto.',
      deliverable: '3 formatos editados',
      price: 200000,
      icon: Icons.videocam_outlined,
      tag: 'TOP CHOICE',
    ),
    _BookingService(
      category: 'Multicámara',
      title: 'Cobertura de Evento',
      description: 'Registro documental de congresos, pasarelas y lanzamientos de producto con entrega express para prensa y comunicación digital.',
      deliverable: 'Galería digital rápida',
      price: 250000,
      icon: Icons.bolt_outlined,
      tag: 'EVENTO',
    ),
    _BookingService(
      category: 'Director de arte',
      title: 'Lookbook & Moda Editorial',
      description: 'Dirección de arte completa, modelos, estilismo y scouting de locación enfocado en colecciones de temporada y campañas editoriales.',
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
    _logisticsController.dispose();
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
                _BookingHeader(
                  step: _step,
                  onBack: _step == 0
                      ? widget.onComplete
                      : () => setState(() => _step--),
                  onClose: widget.onComplete,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 9, 20, 13),
                  child: _ProgressHeader(currentStep: _step),
                ),
                if (_step == 0)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selecciona tu servicio',
                          style: TextStyle(
                            color: ReflexColors.text,
                            fontSize: 23,
                            height: 1.15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Elige el tipo de producción que requiere tu marca o proyecto comercial.',
                          style: TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 12,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
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
        _SelectedSessionCard(
          title: _services
              .firstWhere(
                (service) => _selectedServices.contains(service.title),
                orElse: () => _services.first,
              )
              .title,
          stepLabel: 'SERVICIO SELECCIONADO',
          trailing: '4H ESTUDIO',
        ),
        const SizedBox(height: 13),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_outlined,
                    color: ReflexColors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
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
              '· $_selectedWeekday $_selectedDay',
              style: const TextStyle(color: ReflexColors.muted, fontSize: 11),
            ),
            const SizedBox(width: 8),
            const Text(
              'TACHADO = OCUPADO',
              style: TextStyle(
                color: ReflexColors.muted,
                fontSize: 8,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 2.15,
          children: [
            for (final slot in [
              (time: '08:00', busy: true),
              (time: '09:00', busy: false),
              (time: '10:00', busy: false),
              (time: '14:00', busy: true),
              (time: '15:00', busy: false),
              (time: '16:00', busy: false),
            ])
              _TimeSlot(
                time: slot.time,
                selected: slot.time == _selectedTime,
                busy: slot.busy,
                onTap: slot.busy
                    ? null
                    : () => setState(() => _selectedTime = slot.time),
              ),
          ],
        ),
        const SizedBox(height: 14),
        SurfaceCard(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: ReflexColors.muted,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      color: ReflexColors.muted,
                      fontSize: 11,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text: '¿No encuentras un horario conveniente para tu equipo? ',
                      ),
                      TextSpan(
                        text: 'Escríbenos por WhatsApp',
                        style: const TextStyle(
                          color: ReflexColors.orange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const TextSpan(text: ' ↗'),
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
        _SelectedSessionCard(
          title:
              'Fotografía de Producto · $_selectedWeekday $_selectedDay Oct, $_selectedTime AM',
          stepLabel: 'SESIÓN CONFIRMADA',
          trailing: '4H ESTUDIO',
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: Text(
                'Ubicación de la Sesión',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontSize: 23, height: 1.25),
              ),
            ),
            const TagPill('Logística'),
          ],
        ),
        const SizedBox(height: 5),
        const Text(
          'Elige el espacio ideal para el despliegue del equipo técnico.',
          style: TextStyle(
            color: ReflexColors.muted,
            fontSize: 12,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 14),
        _LocationDetailCard(
          selected: _location == 'Estudio Reflexcam',
          icon: Icons.storefront_outlined,
          title: 'Estudio Reflexcam',
          badge: 'RECOMENDADO',
          subtitle: 'Estudio Central · Calle 93 # 12-40, Piso 3',
          detail: 'Ciclorama blanco, iluminación Profoto y set de producto equipado incluido.',
          onTap: () => setState(() => _location = 'Estudio Reflexcam'),
        ),
        const SizedBox(height: 12),
        _LocationDetailCard(
          selected: _location == 'Mi negocio / Locación',
          icon: Icons.apartment_rounded,
          title: 'En mi negocio o locación externa',
          subtitle: 'Desplazamiento del equipo técnico a tu sede u oficina.',
          detail: 'Incluye montaje portátil de luces y tethering en vivo para clientes en Bogotá D.C.',
          onTap: () => setState(() => _location = 'Mi negocio / Locación'),
        ),
        if (_location == 'Mi negocio / Locación') ...[
          const SizedBox(height: 10),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: 'Dirección de la locación',
              prefixIcon: Icon(Icons.location_on_outlined, size: 19),
            ),
          ),
        ],
        const SizedBox(height: 13),
        const _StudioMapPreview(),
        const SizedBox(height: 14),
        SurfaceCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.subject_rounded,
                    color: ReflexColors.orange,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Indicaciones de acceso y logística especial',
                      style: TextStyle(
                        color: ReflexColors.text,
                        fontSize: 14,
                        height: 1.3,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _logisticsController,
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Ej: Traeremos 2 modelos, productos frágiles de cristalería, requerimos zona de parqueadero de carga o refrigerador para bebidas...',
                  hintStyle: const TextStyle(
                    color: ReflexColors.muted,
                    fontSize: 11,
                    height: 1.5,
                  ),
                  fillColor: ReflexColors.background,
                  contentPadding: const EdgeInsets.all(13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: ReflexColors.line),
                  ),
                ),
              ),
              const Divider(color: ReflexColors.line, height: 22),
              Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                  value: _assistantRequired,
                  onChanged: (value) =>
                      setState(() => _assistantRequired = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: ReflexColors.orange,
                  title: const Text(
                    '¿Requieres asistente de estilismo o iluminación extra?',
                    style: TextStyle(
                      color: ReflexColors.text,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: const Text(
                    'Incluye apoyo técnico de calibración y setup de colorímetro X-Rite.',
                    style: TextStyle(
                      color: ReflexColors.muted,
                      fontSize: 10,
                      height: 1.4,
                    ),
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
    final deposit = (_total * 0.5).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            'Resumen de tu reserva',
            style: TextStyle(
              color: ReflexColors.text,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.1,
            ),
          ),
        ),
        SurfaceCard(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.fact_check_outlined,
                    color: ReflexColors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Eyebrow('Detalles de la sesión')),
                  TextButton.icon(
                    onPressed: () => setState(() => _step = 0),
                    icon: const Icon(Icons.edit_outlined, size: 14),
                    label: const Text('Editar'),
                    style: TextButton.styleFrom(
                      foregroundColor: ReflexColors.orange,
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
              const Divider(color: ReflexColors.line, height: 18),
              _SummaryRow(
                icon: Icons.camera_alt_outlined,
                label: 'Servicio',
                value: _selectedServices.isEmpty
                    ? _services.first.title
                    : _selectedServices.join(', '),
                detail: '4H ESTUDIO  ·  HASTA 30 FOTOS RAW  ·  COLOR GRADING',
              ),
              const Divider(color: ReflexColors.line, height: 20),
              _SummaryRow(
                icon: Icons.calendar_month_outlined,
                label: 'Fecha y hora',
                value:
                    '$_selectedWeekday $_selectedDay de $_monthName, ${_displayedMonth.year}',
                detail: '$_selectedTime AM (GMT-5) · Duración estimada 4h',
              ),
              const Divider(color: ReflexColors.line, height: 20),
              _SummaryRow(
                icon: Icons.location_on_outlined,
                label: 'Lugar',
                value: _location == 'Estudio Reflexcam'
                    ? 'Estudio Reflexcam'
                    : _addressController.text.isEmpty
                    ? 'Mi negocio / Locación'
                    : _addressController.text,
                detail: _location == 'Estudio Reflexcam'
                    ? 'Calle 93 # 12-40, Piso 3 · Bogotá, Colombia'
                    : 'Bogotá, Colombia',
              ),
              if (_selectedExtras.isNotEmpty) ...[
                const Divider(color: ReflexColors.line, height: 20),
                _SummaryRow(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Adicionales',
                  value: _selectedExtras.join(', '),
                ),
              ],
              const SizedBox(height: 11),
              const _StudioMapPreview(compact: true),
            ],
          ),
        ),
        const SizedBox(height: 13),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.payments_outlined,
                    color: ReflexColors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(child: Eyebrow('Resumen económico')),
                  const TagPill('ANTICIPO 50%'),
                ],
              ),
              const Divider(color: ReflexColors.line, height: 20),
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
                'Transferencia bancaria, PSE o tarjeta de crédito. Puedes adjuntar tu comprobante ahora o después de reservar desde tu panel.',
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

class _BookingHeader extends StatelessWidget {
  const _BookingHeader({
    required this.step,
    required this.onBack,
    required this.onClose,
  });

  final int step;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(13, 9, 13, 10),
      child: Column(
        children: [
          SizedBox(
            height: 36,
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Atrás'),
                  style: TextButton.styleFrom(
                    foregroundColor: ReflexColors.text,
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    textStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const Text('🦅', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 6),
                const Text(
                  'REFLEXCAM',
                  style: TextStyle(
                    color: ReflexColors.text,
                    fontSize: 13,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onClose,
                  tooltip: 'Cerrar',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close_rounded, size: 19),
                  style: IconButton.styleFrom(
                    backgroundColor: ReflexColors.surface,
                    foregroundColor: ReflexColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Eyebrow('PASO 0${step + 1} / 04', color: ReflexColors.orange),
          const SizedBox(height: 3),
          const Text(
            'AGENDAR SESIÓN',
            style: TextStyle(
              color: ReflexColors.text,
              fontSize: 23,
              height: 1.2,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
          const Divider(color: ReflexColors.line, height: 15),
        ],
      ),
    );
  }
}

class _SelectedSessionCard extends StatelessWidget {
  const _SelectedSessionCard({
    required this.title,
    required this.stepLabel,
    required this.trailing,
  });

  final String title;
  final String stepLabel;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: ReflexColors.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: ReflexColors.orange,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(stepLabel),
                const SizedBox(height: 4),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ReflexColors.text,
                    fontSize: 13,
                    height: 1.3,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TagPill(trailing),
        ],
      ),
    );
  }
}

class _TimeSlot extends StatelessWidget {
  const _TimeSlot({
    required this.time,
    required this.selected,
    required this.busy,
    required this.onTap,
  });

  final String time;
  final bool selected;
  final bool busy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? ReflexColors.orange : ReflexColors.surface,
      borderRadius: BorderRadius.circular(28),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: selected ? ReflexColors.orange : ReflexColors.line,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selected) ...[
                const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF17120E),
                  size: 14,
                ),
                const SizedBox(width: 3),
              ],
              Text(
                time,
                style: TextStyle(
                  color: selected
                      ? const Color(0xFF17120E)
                      : busy
                      ? ReflexColors.muted.withValues(alpha: 0.35)
                      : ReflexColors.text,
                  decoration: busy ? TextDecoration.lineThrough : null,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationDetailCard extends StatelessWidget {
  const _LocationDetailCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.onTap,
    this.badge,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final String? badge;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ReflexColors.surface,
      borderRadius: BorderRadius.circular(38),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(38),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: selected ? ReflexColors.orange : ReflexColors.line,
              width: selected ? 1.2 : 0.9,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 37,
                height: 37,
                decoration: const BoxDecoration(
                  color: ReflexColors.surfaceRaised,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: ReflexColors.orange, size: 17),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: ReflexColors.text,
                              fontSize: 15,
                              height: 1.3,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (selected)
                          const Icon(
                            Icons.check_circle,
                            color: ReflexColors.orange,
                            size: 19,
                          ),
                      ],
                    ),
                    if (badge != null) ...[
                      const SizedBox(height: 5),
                      TagPill(badge!),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const Divider(color: ReflexColors.line, height: 17),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 10,
                        height: 1.45,
                      ),
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

class _StudioMapPreview extends StatelessWidget {
  const _StudioMapPreview({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          SizedBox(
            height: compact ? 76 : 137,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(child: CustomPaint(painter: _MapPainter())),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: ReflexColors.orange,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x663B1A04),
                        blurRadius: 16,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF17120E),
                    size: 20,
                  ),
                ),
                Positioned(
                  bottom: 11,
                  left: 10,
                  child: TagPill(
                    compact ? 'PISO 3 · REFLEXCAM LAB' : 'ESTUDIO REFLEXCAM',
                  ),
                ),
                if (!compact)
                  const Positioned(
                    top: 10,
                    right: 12,
                    child: TagPill('GPS: 4.6781° N, 74.0534° W'),
                  ),
              ],
            ),
          ),
          if (!compact)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              color: ReflexColors.surface,
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    color: ReflexColors.orange,
                    size: 17,
                  ),
                  SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      'Bogotá, Parque de la 93 (Zona Norte)',
                      style: TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 10,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Text(
                    'VER EN GOOGLE MAPS ↗',
                    style: TextStyle(
                      color: ReflexColors.orange,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
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

class _MapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFF171A1D),
    );
    final roadPaint = Paint()
      ..color = const Color(0xFF292C30)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    final thinRoadPaint = Paint()
      ..color = const Color(0xFF202327)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final y in [0.2, 0.52, 0.82]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * (y - 0.03)),
        roadPaint,
      );
    }
    for (final x in [0.18, 0.68, 0.9]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * (x + 0.08), size.height),
        thinRoadPaint,
      );
    }
    final routePaint = Paint()
      ..color = ReflexColors.orange.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
      Offset(size.width * 0.63, 0),
      Offset(size.width * 0.55, size.height),
      routePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
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
    return Material(
      color: ReflexColors.surface,
      borderRadius: BorderRadius.circular(38),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(38),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 15, 14, 14),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF211E1F) : ReflexColors.surface,
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: selected ? ReflexColors.orange : ReflexColors.line,
              width: selected ? 1.5 : 0.9,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: ReflexColors.orange.withValues(alpha: 0.12),
                      blurRadius: 16,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: ReflexColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(color: ReflexColors.line),
                    ),
                    child: Icon(
                      service.icon,
                      color: selected ? ReflexColors.orange : ReflexColors.text,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 5,
                          children: [
                            TagPill(service.tag),
                            if (service == _BookingScreenState._services.first)
                              const TagPill('TOP CHOICE'),
                          ],
                        ),
                        const SizedBox(height: 7),
                        Text(
                          service.title,
                          style: const TextStyle(
                            color: ReflexColors.text,
                            fontSize: 14,
                            height: 1.3,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 7),
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked_rounded,
                    color: selected ? ReflexColors.orange : ReflexColors.line,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 11),
              Text(
                service.description,
                style: const TextStyle(
                  color: ReflexColors.muted,
                  fontSize: 11,
                  height: 1.55,
                ),
              ),
              const Divider(color: ReflexColors.line, height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.workspace_premium_outlined,
                    color: ReflexColors.orangeLight,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      service.deliverable.toUpperCase(),
                      style: const TextStyle(
                        color: ReflexColors.muted,
                        fontSize: 8,
                        letterSpacing: 0.7,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    'Desde \$${_formatPrice(service.price)}',
                    style: TextStyle(
                      color: selected ? ReflexColors.orange : ReflexColors.text,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: ReflexColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: ReflexColors.line),
      ),
      child: Row(
        children: [
          for (var index = 0; index < _labels.length; index++) ...[
            Column(
              children: [
                Container(
                  width: currentStep == index ? 36 : 31,
                  height: currentStep == index ? 36 : 31,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: currentStep == index
                        ? ReflexColors.orange
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: index <= currentStep
                          ? ReflexColors.orange
                          : ReflexColors.line,
                      width: currentStep == index ? 2 : 1,
                    ),
                    boxShadow: currentStep == index
                        ? [
                            BoxShadow(
                              color: ReflexColors.orange.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    index < currentStep ? '✓' : '${index + 1}',
                    style: TextStyle(
                      color: currentStep == index
                          ? const Color(0xFF17120E)
                          : ReflexColors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _labels[index],
                  style: TextStyle(
                    color: index <= currentStep
                        ? ReflexColors.orangeLight
                        : ReflexColors.muted.withValues(alpha: 0.55),
                    fontSize: 9,
                    letterSpacing: 0.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            if (index < _labels.length - 1)
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(left: 7, right: 7, bottom: 19),
                  color: index < currentStep
                      ? ReflexColors.orange
                      : ReflexColors.line,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? detail;

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
              if (detail != null) ...[
                const SizedBox(height: 5),
                Text(
                  detail!,
                  style: const TextStyle(
                    color: ReflexColors.muted,
                    fontSize: 8,
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
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
