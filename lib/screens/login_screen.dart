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
  bool _useSessionCode = false;

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
                                width: 78,
                                height: 78,
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: ReflexColors.surface,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: ReflexColors.line),
                                ),
                                child: const Center(
                                  child: Text(
                                    '🦅',
                                    style: TextStyle(fontSize: 41),
                                  ),
                                ),
                              ),
                              const Text(
                                'REFLEXCAM STUDIO',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ReflexColors.text,
                                  fontSize: 25,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Eyebrow(
                                'PORTAL CLIENTES',
                                color: ReflexColors.orangeLight,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Acceso a galerías privadas, entregas 5.1K y descarga RAW',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ReflexColors.muted,
                                  fontSize: 11,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 22),
                              _LoginModeSwitch(
                                sessionCode: _useSessionCode,
                                onChanged: (value) =>
                                    setState(() => _useSessionCode = value),
                              ),
                              const SizedBox(height: 19),
                              _FieldLabel(
                                _useSessionCode
                                    ? 'CÓDIGO DE SESIÓN'
                                    : 'CORREO O ID DE CLIENTE',
                              ),
                              const SizedBox(height: 7),
                              TextFormField(
                                key: const ValueKey('login-email'),
                                controller: _emailController,
                                keyboardType: _useSessionCode
                                    ? TextInputType.text
                                    : TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: _useSessionCode
                                    ? null
                                    : const [AutofillHints.email],
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: _useSessionCode
                                      ? 'RFX-9821'
                                      : 'cliente@dominio.com o RFX-9821',
                                  prefixIcon: Icon(
                                    _useSessionCode
                                        ? Icons.key_outlined
                                        : Icons.badge_outlined,
                                    size: 19,
                                  ),
                                ),
                                validator: (value) {
                                  final text = value?.trim() ?? '';
                                  if (text.isEmpty) {
                                    return _useSessionCode
                                        ? 'Ingresa tu código de sesión'
                                        : 'Ingresa tu correo o ID de cliente';
                                  }
                                  if (!_useSessionCode &&
                                      text.contains('@') &&
                                      (!text.contains('.') ||
                                          text.startsWith('@'))) {
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
                                    onPressed: () => _showMessage(
                                      'Contacta al Concierge Reflexcam para recuperar tu clave.',
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                    child: const Text(
                                      '¿Olvidaste tu clave?',
                                      style: TextStyle(
                                        color: ReflexColors.orangeLight,
                                        fontSize: 10,
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
                                  fontSize: 13,
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
                                label: 'INGRESAR AL ESTUDIO',
                                onPressed: _submit,
                                height: 53,
                              ),
                              const SizedBox(height: 19),
                              const _OrDivider(label: 'O ACCEDER CON'),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _SocialButton(
                                      label: 'Google',
                                      icon: Icons.g_mobiledata_rounded,
                                      onPressed: () => _showMessage(
                                        'El acceso con Google aún no está configurado.',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _SocialButton(
                                      label: 'Apple',
                                      icon: Icons.apple,
                                      onPressed: () => _showMessage(
                                        'El acceso con Apple aún no está configurado.',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                '¿Problemas con tus credenciales o clave de entrega?',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: ReflexColors.muted,
                                  fontSize: 11,
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
  const _LoginModeSwitch({required this.sessionCode, required this.onChanged});

  final bool sessionCode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            selected: !sessionCode,
            icon: Icons.person_outline_rounded,
            label: 'Cuenta Cliente',
            onTap: () => onChanged(false),
          ),
        ),
        Expanded(
          child: _ModeButton(
            selected: sessionCode,
            icon: Icons.key_outlined,
            label: 'Código de Sesión',
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

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: ReflexColors.line)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            label,
            style: const TextStyle(
              color: ReflexColors.muted,
              fontSize: 8,
              letterSpacing: 1,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Expanded(child: Divider(color: ReflexColors.line)),
      ],
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
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: ReflexColors.text,
        side: const BorderSide(color: ReflexColors.line),
        minimumSize: const Size.fromHeight(44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
