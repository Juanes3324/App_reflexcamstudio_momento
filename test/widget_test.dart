import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:reflexcam_studio/reflexcam_app.dart';

void main() {
  testWidgets('sign in opens the studio and booking can be started', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ReflexCamApp());

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
    await tester.tap(find.byKey(const ValueKey('navigation-Agendar')));
    await tester.pumpAndSettle();

    expect(find.text('Selecciona tu servicio'), findsOneWidget);
    expect(find.text('CONTINUAR A FECHA'), findsOneWidget);
    await tester.tap(find.text('CONTINUAR A FECHA'));
    await tester.pumpAndSettle();
    expect(find.text('Octubre 2026'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Noviembre 2026'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('booking enforces acceptance before submitting', (tester) async {
    tester.view.physicalSize = const Size(393, 852);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ReflexCamApp());
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
    expect(find.text('ENVIAR SOLICITUD DE RESERVA'), findsOneWidget);
    await tester.tap(find.text('ENVIAR SOLICITUD DE RESERVA'));
    await tester.pumpAndSettle();
    expect(find.text('Resumen de tu reserva'), findsOneWidget);

    const termsLabel =
        'Acepto los términos del servicio y la política de cancelación.';
    await tester.ensureVisible(find.text(termsLabel));
    await tester.tap(find.text(termsLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('ENVIAR SOLICITUD DE RESERVA'));
    await tester.pumpAndSettle();

    expect(find.text('SOLICITUD ENVIADA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
