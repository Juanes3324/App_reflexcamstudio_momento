import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/reflex_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      widget.onLogin();
    }
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 30, 28, 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.camera_alt_outlined,
                          color: ReflexColors.orange,
                          size: 40,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'REFLEXCAM STUDIO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ReflexColors.text,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            letterSpacing: 2.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'FOTOGRAFÍA PROFESIONAL',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 9,
                            letterSpacing: 2.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 36),
                        const Eyebrow('Tu estudio creativo'),
                        const SizedBox(height: 8),
                        Text(
                          'Captura momentos\nque se quedan.',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontSize: 29, height: 1.12),
                        ),
                        const SizedBox(height: 11),
                        const Text(
                          'Ingresa a tu cuenta para gestionar tus sesiones y proyectos.',
                          style: TextStyle(
                            color: ReflexColors.muted,
                            height: 1.5,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const _FieldLabel('Correo electrónico'),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: const ValueKey('login-email'),
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            hintText: 'tu@correo.com',
                            prefixIcon: Icon(Icons.mail_outline, size: 19),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Ingresa tu correo electrónico';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const _FieldLabel('Contraseña'),
                        const SizedBox(height: 8),
                        TextFormField(
                          key: const ValueKey('login-password'),
                          controller: _passwordController,
                          obscureText: _hidePassword,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          autofillHints: const [AutofillHints.password],
                          decoration: InputDecoration(
                            hintText: '••••••••',
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
                                size: 19,
                              ),
                            ),
                          ),
                          validator: (value) =>
                              value == null || value.length < 6
                              ? 'Usa al menos 6 caracteres'
                              : null,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Contacta al estudio para restablecer tu contraseña.',
                                  ),
                                ),
                              ),
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: ReflexColors.orangeLight,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        PrimaryButton(
                          label: 'INGRESAR AL ESTUDIO',
                          onPressed: _submit,
                          icon: Icons.arrow_forward_rounded,
                        ),
                        const SizedBox(height: 22),
                        const Row(
                          children: [
                            Expanded(child: Divider(color: ReflexColors.line)),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'O CONTINÚA CON',
                                style: TextStyle(
                                  color: ReflexColors.muted,
                                  fontSize: 9,
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Expanded(child: Divider(color: ReflexColors.line)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _SocialButton(
                                label: 'Google',
                                onPressed: () => _showUnavailable(context),
                                icon: Icons.g_mobiledata_rounded,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SocialButton(
                                label: 'Apple',
                                onPressed: () => _showUnavailable(context),
                                icon: Icons.apple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),
                        const Text(
                          'Al continuar aceptas las condiciones del servicio y la política de privacidad.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: ReflexColors.muted,
                            fontSize: 10,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showUnavailable(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'El acceso con esta plataforma aún no está configurado.',
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
        color: ReflexColors.text,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.onPressed,
    required this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: ReflexColors.text,
        side: const BorderSide(color: ReflexColors.line),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
