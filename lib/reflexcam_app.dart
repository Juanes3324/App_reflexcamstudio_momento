import 'package:flutter/material.dart';

import 'screens/booking_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'services/auth_service.dart';
import 'services/booking_repository.dart';
import 'services/gallery_repository.dart';
import 'screens/services_screen.dart';
import 'theme.dart';

class ReflexCamApp extends StatelessWidget {
  const ReflexCamApp({
    this.authService,
    this.bookingRepository,
    this.galleryRepository,
    super.key,
  });

  final AuthService? authService;
  final BookingRepository? bookingRepository;
  final GalleryRepository? galleryRepository;

  @override
  Widget build(BuildContext context) {
    final showServicesPreview =
        Uri.base.queryParameters['screen'] == 'services';
    final resolvedAuthService = authService ?? FirebaseAuthService();

    return MaterialApp(
      title: 'ReflexCam Studio',
      debugShowCheckedModeBanner: false,
      theme: ReflexTheme.dark,
      home: ReflexCamRoot(
        initialTab: showServicesPreview ? 1 : 0,
        previewSignedIn: showServicesPreview,
        authService: resolvedAuthService,
        bookingRepository: bookingRepository ?? FirebaseBookingRepository(),
        galleryRepository: galleryRepository ?? FirebaseGalleryRepository(),
      ),
    );
  }
}

class ReflexCamRoot extends StatefulWidget {
  const ReflexCamRoot({
    required this.initialTab,
    required this.previewSignedIn,
    required this.authService,
    required this.bookingRepository,
    required this.galleryRepository,
    super.key,
  });

  final int initialTab;
  final bool previewSignedIn;
  final AuthService authService;
  final BookingRepository bookingRepository;
  final GalleryRepository galleryRepository;

  @override
  State<ReflexCamRoot> createState() => _ReflexCamRootState();
}

class _ReflexCamRootState extends State<ReflexCamRoot> {
  late int _selectedTab = widget.initialTab;

  Future<void> _signOut() async {
    try {
      await widget.authService.signOut();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('No se pudo cerrar la sesión: $error')),
        );
    }
  }

  void _openBooking() {
    setState(() => _selectedTab = 2);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthUser?>(
      stream: widget.previewSignedIn
          ? null
          : widget.authService.authStateChanges,
      initialData: widget.previewSignedIn
          ? const AuthUser(uid: 'preview')
          : widget.authService.currentUser,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No se pudo comprobar la sesión: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (user == null) {
          return LoginScreen(authService: widget.authService);
        }
        return _buildAuthenticatedScaffold(user);
      },
    );
  }

  Widget _buildAuthenticatedScaffold(AuthUser user) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final contentWidth = screenWidth < 480 ? screenWidth : 480.0;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bodyWidth = constraints.maxWidth < 480
                ? constraints.maxWidth
                : 480.0;
            return Center(
              child: SizedBox(
                width: bodyWidth,
                height: constraints.maxHeight,
                child: _buildCurrentScreen(user),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: SizedBox(
          height: 66,
          child: Center(
            child: SizedBox(
              width: contentWidth,
              child: _BottomNavigation(
                selectedIndex: _selectedTab,
                onSelected: (index) => setState(() => _selectedTab = index),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentScreen(AuthUser user) {
    return switch (_selectedTab) {
      0 => HomeScreen(
        onBook: _openBooking,
        onProject: () => setState(() => _selectedTab = 3),
      ),
      1 => ServicesScreen(
        onBook: _openBooking,
        onBack: () => setState(() => _selectedTab = 0),
      ),
      2 => BookingScreen(
        repository: widget.bookingRepository,
        onComplete: () => setState(() => _selectedTab = 0),
      ),
      3 => GalleryScreen(repository: widget.galleryRepository),
      _ => ProfileScreen(userEmail: user.email ?? '', onSignOut: _signOut),
    };
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _items = [
    (icon: Icons.home_outlined, label: 'Inicio'),
    (icon: Icons.camera_alt_outlined, label: 'Servicios'),
    (icon: Icons.calendar_month_outlined, label: 'Agendar'),
    (icon: Icons.photo_library_outlined, label: 'Proyectos'),
    (icon: Icons.person_outline, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      decoration: const BoxDecoration(
        color: ReflexColors.nav,
        border: Border(top: BorderSide(color: ReflexColors.line, width: 0.6)),
      ),
      child: Row(
        children: [
          for (var index = 0; index < _items.length; index++)
            Expanded(
              child: InkWell(
                key: ValueKey('navigation-${_items[index].label}'),
                onTap: () => onSelected(index),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _items[index].icon,
                      size: 20,
                      color: selectedIndex == index
                          ? ReflexColors.orange
                          : ReflexColors.muted,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _items[index].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selectedIndex == index
                            ? ReflexColors.orange
                            : ReflexColors.muted,
                        fontSize: 10,
                        letterSpacing: 0.4,
                        fontWeight: selectedIndex == index
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
