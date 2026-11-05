import 'package:flutter/material.dart';

import 'screens/booking_screen.dart';
import 'screens/gallery_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/services_screen.dart';
import 'theme.dart';

class ReflexCamApp extends StatelessWidget {
  const ReflexCamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReflexCam Studio',
      debugShowCheckedModeBanner: false,
      theme: ReflexTheme.dark,
      home: const ReflexCamRoot(),
    );
  }
}

class ReflexCamRoot extends StatefulWidget {
  const ReflexCamRoot({super.key});

  @override
  State<ReflexCamRoot> createState() => _ReflexCamRootState();
}

class _ReflexCamRootState extends State<ReflexCamRoot> {
  bool _isSignedIn = false;
  int _selectedTab = 0;

  void _signIn() {
    setState(() {
      _isSignedIn = true;
      _selectedTab = 0;
    });
  }

  void _signOut() {
    setState(() {
      _isSignedIn = false;
      _selectedTab = 0;
    });
  }

  void _openBooking() {
    setState(() => _selectedTab = 2);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSignedIn) {
      return LoginScreen(onLogin: _signIn);
    }

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
                child: _buildCurrentScreen(),
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

  Widget _buildCurrentScreen() {
    return switch (_selectedTab) {
      0 => HomeScreen(
        onBook: _openBooking,
        onServices: () => setState(() => _selectedTab = 1),
      ),
      1 => ServicesScreen(onBook: _openBooking),
      2 => BookingScreen(onComplete: () => setState(() => _selectedTab = 0)),
      3 => const GalleryScreen(),
      _ => ProfileScreen(onSignOut: _signOut),
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
