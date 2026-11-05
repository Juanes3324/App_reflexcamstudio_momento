# ReflexCam Studio

Flutter application UI for the ReflexCam Studio photography service, based on
the screens in the linked Figma file.

## Run

```shell
flutter pub get
flutter run
```

The app starts at the sign-in screen. Use any valid email and a password with
at least six characters to enter the UI demo. Booking, gallery selection, and
navigation are interactive, but authentication and booking submission are not
connected to a backend.

Service and gallery preview photos are loaded from Unsplash and require an
internet connection.

The Montserrat variable font is bundled locally under the SIL Open Font
License; see `assets/fonts/OFL.txt`.
