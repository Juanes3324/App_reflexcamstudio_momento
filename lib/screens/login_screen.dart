import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.authService, super.key});

  final AuthService authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;
  bool _createAccount = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting || !(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubmitting = true);
    try {
      if (_createAccount) {
        await widget.authService.createAccount(
          _emailController.text.trim(),
          _passwordController.text,
        );
      } else {
        await widget.authService.signIn(
          _emailController.text.trim(),
          _passwordController.text,
        );
      }
    } catch (error) {
      if (mounted) _showMessage(_authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendPasswordReset() async {
    final email = _emailController.text.trim();
    if (!email.contains('@') || !email.contains('.')) {
      _showMessage(
        'Ingresa tu correo para enviarte el enlace de recuperación.',
      );
      return;
    }
    try {
      await widget.authService.sendPasswordResetEmail(email);
      if (mounted) _showMessage('Revisa tu correo para restablecer la clave.');
    } catch (error) {
      if (mounted) _showMessage(_authErrorMessage(error));
    }
  }

  String _authErrorMessage(Object error) {
    if (error is! FirebaseAuthException) {
      return 'No se pudo completar la autenticación. Inténtalo de nuevo.';
    }
    return switch (error.code) {
      'invalid-email' => 'El correo electrónico no es válido.',
      'email-already-in-use' => 'Ya existe una cuenta con ese correo.',
      'weak-password' => 'La contraseña debe tener al menos 6 caracteres.',
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' => 'Correo o contraseña incorrectos.',
      'too-many-requests' =>
        'Demasiados intentos. Espera un momento y vuelve a intentarlo.',
      'network-request-failed' =>
        'No hay conexión. Revisa internet e inténtalo de nuevo.',
      'operation-not-allowed' =>
        'El acceso por correo y contraseña no está habilitado en Firebase.',
      _ => 'No se pudo autenticar la cuenta. Inténtalo de nuevo.',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = constraints.maxWidth < 480
                ? constraints.maxWidth
                : 480.0;
            return Center(
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LoginTopBar(
                                onBack: () {},
                                onSecure: () => _showMessage(
                                  'Portal seguro de clientes Reflexcam.',
                                ),
                              ),
                              const SizedBox(height: 27),
                              Container(
                                width: 100,
                                height: 78,
                                margin: const EdgeInsets.only(bottom: 10),
                                alignment: Alignment.center,
                                child: Image.asset(
                                  'assets/images/reflexcam_logo.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const Text(
                                'REFLEXCAM STUDIO',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ReflexColors.text,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Center(
                                child: Eyebrow(
                                  'PORTAL CLIENTES',
                                  color: ReflexColors.orangeLight,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Acceso a galerías privadas, entregas 5.1K y descarga RAW',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ReflexColors.muted,
                                  fontSize: 14,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _LoginModeSwitch(
                                createAccount: _createAccount,
                                onChanged: (value) =>
                                    setState(() => _createAccount = value),
                              ),
                              const SizedBox(height: 19),
                              const _FieldLabel('CORREO ELECTRÓNICO'),
                              const SizedBox(height: 7),
                              TextFormField(
                                key: const ValueKey('login-email'),
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                style: const TextStyle(fontSize: 14),
                                decoration: InputDecoration(
                                  hintText: 'cliente@dominio.com',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    size: 19,
                                  ),
                                ),
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (!text.contains('@') ||
                                      !text.contains('.') ||
                                      text.startsWith('@')) {
                                    return 'Ingresa un correo válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              Row(
                                children: [
                                  const Expanded(
                                    child: _FieldLabel(
                                      'CONTRASEÑA / PIN MASTER',
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: _sendPasswordReset,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: const Text(
                                      '¿Olvidaste tu clave?',
                                      style: TextStyle(
                                        color: ReflexColors.orangeLight,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 7),
                              TextFormField(
                                key: const ValueKey('login-password'),
                                controller: _passwordController,
                                obscureText: _hidePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _submit(),
                                autofillHints: const [AutofillHints.password],
                                style: const TextStyle(
                                  fontSize: 14,
                                  letterSpacing: 1.1,
                                ),
                                decoration: InputDecoration(
                                  hintText: '••••••••••',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    size: 19,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () => setState(
                                      () => _hidePassword = !_hidePassword,
                                    ),
                                    icon: Icon(
                                      _hidePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                validator: (value) =>
                                    value == null || value.length < 6
                                    ? 'Ingresa al menos 6 caracteres'
                                    : null,
                              ),
                              const SizedBox(height: 15),
                              PrimaryButton(
                                label: _isSubmitting
                                    ? 'CONECTANDO...'
                                    : _createAccount
                                    ? 'CREAR CUENTA'
                                    : 'INGRESAR AL ESTUDIO',
                                onPressed: _isSubmitting ? null : _submit,
                                height: 53,
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Tu cuenta protege el acceso a tus reservas y galerías.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ReflexColors.muted,
                                  fontSize: 13,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _showMessage(
                                  'Escríbenos por WhatsApp para recibir asistencia.',
                                ),
                                icon: const Icon(
                                  Icons.support_agent_rounded,
                                  size: 17,
                                ),
                                label: const Text(
                                  'Contactar Concierge Reflexcam',
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: ReflexColors.orangeLight,
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: ReflexColors.line, width: 0.6),
                        ),
                      ),
                      child: const Text(
                        '●  DRON 5.1K · FOTO + VIDEO RAW\n© REFLEXCAM STUDIO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: ReflexColors.muted,
                          fontSize: 9,
                          height: 1.8,
                          letterSpacing: 1.1,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: ReflexColors.orange.withValues(alpha: 0.28),
              blurRadius: 16,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _showMessage('Escríbenos por WhatsApp.'),
          backgroundColor: ReflexColors.orange,
          foregroundColor: const Color(0xFF17120E),
          elevation: 0,
          highlightElevation: 1,
          child: const Icon(Icons.chat_rounded),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _LoginTopBar extends StatelessWidget {
  const _LoginTopBar({required this.onBack, required this.onSecure});

  final VoidCallback onBack;
  final VoidCallback onSecure;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton.icon(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded, size: 17),
          label: const Text('Volver'),
          style: TextButton.styleFrom(
            foregroundColor: ReflexColors.text,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            textStyle: const TextStyle(fontSize: 12),
          ),
        ),
        const Spacer(),
        OutlinedButton.icon(
          onPressed: onSecure,
          icon: const Icon(Icons.circle, size: 7, color: ReflexColors.orange),
          label: const Text('PORTAL SEGURO'),
          style: OutlinedButton.styleFrom(
            foregroundColor: ReflexColors.muted,
            side: const BorderSide(color: ReflexColors.line),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            textStyle: const TextStyle(
              fontSize: 9,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoginModeSwitch extends StatelessWidget {
  const _LoginModeSwitch({
    required this.createAccount,
    required this.onChanged,
  });

  final bool createAccount;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            selected: !createAccount,
            icon: Icons.person_outline_rounded,
            label: 'Ingresar',
            onTap: () => onChanged(false),
          ),
        ),
        Expanded(
          child: _ModeButton(
            selected: createAccount,
            icon: Icons.person_add_alt_outlined,
            label: 'Crear cuenta',
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? ReflexColors.orange : ReflexColors.line,
              width: selected ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: selected ? ReflexColors.orange : ReflexColors.muted,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? ReflexColors.orange : ReflexColors.muted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: ReflexColors.orangeLight,
        fontSize: 9,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}
