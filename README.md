# ReflexCam Studio

Aplicación Flutter para reservas y galerías privadas de Reflexcam.

## Funcionalidades conectadas

- **Firebase Authentication:** registro, inicio/cierre de sesión y recuperación de contraseña con correo y clave.
- **Cloud Firestore:** las reservas se crean desde Cloud Functions; cada cliente solo puede leer sus propias reservas. Las reglas bloquean escrituras directas desde la app.
- **Wompi Colombia:** el servidor calcula el total desde un catálogo validado, genera el anticipo del 50% y la firma de integridad. El webhook valida el checksum y actualiza el estado del pago.
- **Google Maps y Geolocator:** pin movible y ubicación actual puntual para trabajos en locación externa. No hay rastreo en segundo plano.
- **Cloudinary:** las galerías se consultan desde una función autenticada. Las fotos deben ser de tipo `authenticated` y llevar la etiqueta `booking_<bookingId>`.

La app conserva el diseño existente. La disponibilidad de fechas no está conectada a un calendario: una fecha/hora es una solicitud y el estudio debe confirmarla. No se debe tratar como bloqueada automáticamente.

## Datos de Firebase

La integración usa estas colecciones:

- `bookings/{bookingId}`: `userId`, servicios/adicionales, fecha solicitada, dirección/coordenadas, logística, total, anticipo, estado de reserva, estado y referencia Wompi, fechas de creación y actualización.

Cloud Functions utiliza Admin SDK para crear y actualizar reservas. Firestore Rules permite leer un documento solo al usuario autenticado propietario y niega las escrituras del cliente. Las galerías se cargan mediante una función que valida UID y pago aprobado.

## Requisitos de configuración

### 1. Firebase

La configuración Flutter disponible en este checkout solo cubre Android. Habilita **Authentication > Email/Password** en Firebase Console. Crea/verifica Cloud Firestore antes de desplegar; su ubicación es irreversible. Las funciones están configuradas en `southamerica-east1`, una ubicación cercana a Colombia. Si el Firestore existente está en otra región, revisa `REGION` en `functions/src/index.ts` y la región de Functions en los repositorios Dart antes de desplegar.

En la terminal del proyecto, después de iniciar sesión en Firebase CLI:

```shell
firebase login
firebase projects:list
flutterfire configure --project=reflexcamstudioapp --platforms=android,ios,web
```

El proyecto debe estar en el plan Blaze para Cloud Functions y Secret Manager. No se requiere una clave privada de Firebase Admin en Flutter; las funciones usan la identidad de servicio de Google.

### 2. Google Maps

En Google Cloud Console habilita **Maps SDK for Android**, **Maps SDK for iOS** y, si usas Web, **Maps JavaScript API**. Crea una clave restringida por plataforma y habilita la facturación de Google Maps.

- Android: agrega `MAPS_API_KEY=TU_CLAVE` al archivo local `android/local.properties`. El archivo está excluido de Git. Restringe la clave al paquete `com.reflexcamstudio.app` y a los SHA-1 de tus builds.
- iOS: crea `ios/Flutter/MapsAPIKey.xcconfig` con `MAPS_API_KEY=TU_CLAVE`. El archivo está excluido de Git. Restringe la clave al identificador de paquete de iOS.
- Web: agrega antes de `flutter_bootstrap.js` en `web/index.html` el script oficial de Maps JavaScript API con una clave restringida a los dominios de despliegue.

No uses una clave sin restricciones. La selección de ubicación funciona al configurar la clave de Maps y conceder permiso de ubicación “al usar la app”.

### 3. Wompi

Usa inicialmente las credenciales de **pruebas** de tu cuenta Wompi. Configura los secretos desde una terminal local autenticada; Firebase CLI solicitará el valor. No los incluyas en Flutter, Git ni en el chat:

```shell
firebase functions:secrets:set WOMPI_PUBLIC_KEY
firebase functions:secrets:set WOMPI_INTEGRITY_SECRET
firebase functions:secrets:set WOMPI_EVENTS_SECRET
```

Configura en el Dashboard de Wompi el webhook `transaction.updated` con la URL HTTPS de la función `wompiWebhook` después del despliegue. El secreto de eventos es distinto al secreto de integridad y a la llave privada. Cambia a credenciales de producción solo después de probar todo el flujo en pruebas.

### 4. Cloudinary

Configura las credenciales del servidor como secretos de Functions:

```shell
firebase functions:secrets:set CLOUDINARY_CLOUD_NAME
firebase functions:secrets:set CLOUDINARY_API_KEY
firebase functions:secrets:set CLOUDINARY_API_SECRET
```

Desde el Dashboard de Cloudinary, sube cada entrega como recurso de tipo **authenticated** y añade la etiqueta `booking_<bookingId>` correspondiente al documento de reserva. La función solo consulta reservas pagadas del usuario autenticado y firma las URLs de entrega. Las URLs firmadas son credenciales portadoras: quien las reciba puede compartirlas; no tienen vencimiento en esta configuración. Para expiración temporal se requiere habilitar Cloudinary Token-based Access (función de pago).

## Ejecutar y desplegar

```shell
flutter pub get
flutter run
```

Instala y valida las funciones:

```shell
cd functions
npm ci
npm run build
npm run lint
cd ..
```

Después de configurar Firebase, los secretos, la base de datos y el webhook:

```shell
firebase deploy --only firestore:rules,functions
```

Pruebas locales:

```shell
flutter analyze
flutter test
```

Las pruebas widget usan servicios falsos inyectados. No prueban cargos, autenticación remota, permisos reales de ubicación, mapas con tiles ni galerías Cloudinary. Esas comprobaciones requieren las credenciales y el despliegue del proyecto.

## Limitaciones pendientes

- Firebase Flutter está configurado solo para Android hasta ejecutar FlutterFire CLI para iOS/Web.
- Las claves de Maps y los secretos de Wompi/Cloudinary no están en el repositorio y deben configurarse localmente.
- No se ha desplegado Cloud Functions ni se ha probado el webhook o un pago real/de pruebas.
- Cloudinary consulta fotografías; la subida la realiza el equipo desde el Dashboard.
- Las fechas solicitadas aún no se sincronizan con un calendario ni se bloquean automáticamente.
- Firebase App Check no está activado.
