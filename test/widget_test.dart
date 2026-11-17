import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reflexcam_studio/reflexcam_app.dart';
import 'package:reflexcam_studio/services/auth_service.dart';
import 'package:reflexcam_studio/services/booking_repository.dart';
import 'package:reflexcam_studio/services/gallery_repository.dart';

void main() {
  testWidgets('sign in opens the studio and booking can be started', (
    tester,
  ) async {
    final authService = _FakeAuthService();
    addTearDown(authService.dispose);
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_testApp(authService));
    await tester.pumpAndSettle();

    expect(
      tester
          .renderObject<RenderParagraph>(find.text('REFLEXCAM STUDIO'))
          .text
          .style
          ?.fontFamily,
      'Montserrat',
    );
    expect(tester.takeException(), isNull);
    expect(find.text('REFLEXCAM STUDIO'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'cliente@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'fotografia123',
    );
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('INGRESAR AL ESTUDIO'));
    await tester.tap(find.text('INGRESAR AL ESTUDIO'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Hola, Grano de Oro'), findsOneWidget);
    expect(find.text('EN EDICIÓN'), findsOneWidget);
    expect(find.text('Flujo de revelado RAW'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('+ AGENDAR SESIÓN'), findsOneWidget);
    expect(find.text('DISCIPLINAS'), findsOneWidget);
    expect(find.text('04 DISPONIBLES'), findsOneWidget);
    expect(find.text('Capturas Recientes'), findsOneWidget);
    final homeScrollable = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Campaña Oro puro'),
      120,
      scrollable: homeScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Campaña Oro puro'), findsOneWidget);
    expect(find.text('PRODUCTO · 50MM F/1.2'), findsOneWidget);
    expect(find.text('RAW · DCI 4K'), findsOneWidget);
    expect(find.text('24 Archivos'), findsOneWidget);
    await tester.drag(homeScrollable, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-discipline-Video')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Reels nueva colección'),
      120,
      scrollable: homeScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Reels nueva colección'), findsOneWidget);
    expect(find.text('Campaña Oro puro'), findsNothing);
    await tester.drag(homeScrollable, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-discipline-Todos')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Campaña Oro puro'),
      120,
      scrollable: homeScrollable,
    );
    await tester.pumpAndSettle();
    expect(find.text('Campaña Oro puro'), findsOneWidget);
    await tester.drag(homeScrollable, const Offset(0, 600));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-portfolio')));
    await tester.pumpAndSettle();
    expect(find.text('Tus proyectos'), findsOneWidget);
    expect(find.text('Campaña Oro puro'), findsOneWidget);
    expect(find.text('Fotografías de producto'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('discipline-Video')));
    await tester.pumpAndSettle();
    expect(find.text('Reels nueva colección'), findsOneWidget);
    expect(find.text('Campaña Oro puro'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('discipline-Todos')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('session-Campaña Oro puro')));
    await tester.pumpAndSettle();
    expect(
      find.text('Esta galería solo es visible para ti y tu equipo creativo.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('gallery-back-to-sessions')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navigation-Inicio')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navigation-Agendar')));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona tu servicio'), findsOneWidget);
    expect(find.text('CONTINUAR A FECHA'), findsOneWidget);
    await tester.tap(find.text('CONTINUAR A FECHA'));
    await tester.pumpAndSettle();
    final bookingDate = DateTime.now().add(const Duration(days: 1));
    final months = [
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
    expect(
      find.text('${months[bookingDate.month - 1]} ${bookingDate.year}'),
      findsOneWidget,
    );
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    final nextMonth = DateTime(bookingDate.year, bookingDate.month + 1);
    expect(
      find.text('${months[nextMonth.month - 1]} ${nextMonth.year}'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('booking enforces acceptance before submitting', (tester) async {
    final authService = _FakeAuthService();
    final bookingRepository = _FakeBookingRepository();
    addTearDown(authService.dispose);
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _testApp(authService, bookingRepository: bookingRepository),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('login-email')),
      'cliente@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('login-password')),
      'fotografia123',
    );
    await tester.ensureVisible(find.text('INGRESAR AL ESTUDIO'));
    await tester.tap(find.text('INGRESAR AL ESTUDIO'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('navigation-Agendar')));
    await tester.pumpAndSettle();

    for (final label in [
      'CONTINUAR A FECHA',
      'CONTINUAR',
      'CONTINUAR A RESUMEN',
    ]) {
      await tester.ensureVisible(find.text(label));
      await tester.tap(find.text(label));
      await tester.pumpAndSettle();
    }

    expect(find.text('Resumen de tu reserva'), findsOneWidget);
    expect(find.text('PAGAR ANTICIPO (50%)'), findsOneWidget);
    await tester.tap(find.text('PAGAR ANTICIPO (50%)'));
    await tester.pumpAndSettle();
    expect(find.text('Resumen de tu reserva'), findsOneWidget);

    final termsCheckbox = find.byType(CheckboxListTile).last;
    await tester.ensureVisible(termsCheckbox);
    await tester.tap(termsCheckbox);
    await tester.pumpAndSettle();
    expect(tester.widget<CheckboxListTile>(termsCheckbox).value, isTrue);
    await tester.tap(find.text('PAGAR ANTICIPO (50%)'));
    await tester.pumpAndSettle();

    expect(find.text('PAGO DE ANTICIPO'), findsOneWidget);
    expect(bookingRepository.lastRequest, isNotNull);
    expect(
      bookingRepository.lastRequest!.serviceIds,
      contains('product_branding'),
    );
    expect(tester.takeException(), isNull);
  });
}

ReflexCamApp _testApp(
  _FakeAuthService authService, {
  _FakeBookingRepository? bookingRepository,
}) {
  return ReflexCamApp(
    authService: authService,
    bookingRepository: bookingRepository ?? _FakeBookingRepository(),
    galleryRepository: _FakeGalleryRepository(),
  );
}

class _FakeAuthService implements AuthService {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _user;

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> get authStateChanges async* {
    yield _user;
    yield* _controller.stream;
  }

  @override
  Future<void> createAccount(String email, String password) async {
    _user = AuthUser(uid: 'test-user', email: email);
    _controller.add(_user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signIn(String email, String password) async {
    _user = AuthUser(uid: 'test-user', email: email);
    _controller.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}

class _FakeBookingRepository implements BookingRepository {
  BookingRequest? lastRequest;

  @override
  Future<BookingCheckout> createCheckout(BookingRequest request) async {
    lastRequest = request;
    return BookingCheckout(
      bookingId: 'test-booking',
      reference: 'RFX-test-booking',
      checkoutUrl: Uri.https('checkout.wompi.co', '/p/'),
      totalAmount: 350000,
      depositAmount: 175000,
    );
  }

  @override
  Future<bool> openCheckout(Uri checkoutUrl) async => true;

  @override
  Stream<String> watchPaymentStatus(String bookingId) =>
      Stream<String>.value('pending');
}

class _FakeGalleryRepository implements GalleryRepository {
  @override
  Future<List<GallerySession>> listMyGalleries() async => [
    GallerySession(
      bookingId: 'booking-1',
      title: 'Campaña Oro puro',
      category: 'Fotografía',
      scheduledAt: DateTime(2026, 10, 8),
      photos: [
        Uri.parse(
          'https://images.unsplash.com/photo-1611652022419-a9419f74343d',
        ),
      ],
    ),
    GallerySession(
      bookingId: 'booking-2',
      title: 'Fotografías de producto',
      category: 'Fotografía',
      scheduledAt: DateTime(2026, 2, 18),
      photos: [
        Uri.parse(
          'https://images.unsplash.com/photo-1529139574466-a303027c1d8b',
        ),
      ],
    ),
    GallerySession(
      bookingId: 'booking-3',
      title: 'Reels nueva colección',
      category: 'Video',
      scheduledAt: DateTime(2026, 2, 12),
      photos: [
        Uri.parse(
          'https://images.unsplash.com/photo-1492691527719-9d1e07e534b4',
        ),
      ],
    ),
  ];
}
