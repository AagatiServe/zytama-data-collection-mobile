import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/utils/dialog_utils.dart';
import 'package:zytama_data/features/product/presentation/screens/dashboard_screen.dart';

// ── Brand colours (from HTML Tailwind config) ─────────────────────────────
const _primary = Color(0xFF0d631b);
const _onSurfaceVariant = Color(0xFF40493d);
const _outlineVariant = Color(0xFFbfcaba);
const _outline = Color(0xFF707a6c);
const _onSurface = Color(0xFF071e27);
const _error = Color(0xFFba1a1a);
const _surface = Color(0xFFf3faff);
const _secondaryFixedDim = Color(0xFFbdcabe);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscure = true;
  bool _remember = false;

  initState() {
    super.initState();
    _emailCtrl.text =
        'devag1-0001@zytama.com'; // Optionally, load saved email here
    _passCtrl.text = 'TestPassword@456';
    // Optionally, load saved email/remember state here
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(LoginRequested(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        } else if (state is AuthError) {
          DialogUtils.showErrorDialog(context, state.message);
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // ── Gradient background ──────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0.0, 0.5, 1.0],
                  colors: [
                    Color(0xFFd6eeda), // primary/10
                    _surface,
                    _secondaryFixedDim,
                  ],
                ),
              ),
            ),

            // ── Decorative blurred circles ───────────────────────────
            Positioned(
              top: -100,
              right: -100,
              child: _blurCircle(280, _primary.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: _blurCircle(220, _primary.withValues(alpha: 0.06)),
            ),
            Positioned(
              top: 200,
              left: -60,
              child:
                  _blurCircle(160, _secondaryFixedDim.withValues(alpha: 0.5)),
            ),

            // ── Scrollable content ───────────────────────────────────
            SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.vertical,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        _LogoSection(),
                        const SizedBox(height: 24),
                        _GlassCard(
                          formKey: _formKey,
                          emailCtrl: _emailCtrl,
                          passCtrl: _passCtrl,
                          emailFocus: _emailFocus,
                          passFocus: _passFocus,
                          obscure: _obscure,
                          remember: _remember,
                          onToggleObscure: () =>
                              setState(() => _obscure = !_obscure),
                          onToggleRemember: (v) =>
                              setState(() => _remember = v),
                          onSubmit: _submit,
                        ),
                        const SizedBox(height: 28),
                        _Footer(),
                        const SizedBox(height: 56),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}

// ── Logo section ─────────────────────────────────────────────────────────────

class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: _primary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: _primary.withValues(alpha: 0.4),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(Icons.eco_rounded, color: Colors.white, size: 44),
        ),
        const SizedBox(height: 12),
        const Text(
          'Field Collection',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: _primary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Secure Agent Access',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── Glass login card ──────────────────────────────────────────────────────────

class _GlassCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final TextEditingController passCtrl;
  final FocusNode emailFocus;
  final FocusNode passFocus;
  final bool obscure;
  final bool remember;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool> onToggleRemember;
  final VoidCallback onSubmit;

  const _GlassCard({
    required this.formKey,
    required this.emailCtrl,
    required this.passCtrl,
    required this.emailFocus,
    required this.passFocus,
    required this.obscure,
    required this.remember,
    required this.onToggleObscure,
    required this.onToggleRemember,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
                color: Colors.white.withValues(alpha: 0.35), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 48,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Email
                _label('Phone or Email'),
                const SizedBox(height: 6),
                _EmailField(
                    ctrl: emailCtrl,
                    focusNode: emailFocus,
                    nextFocus: passFocus),
                const SizedBox(height: 16),

                // Password header row
                _label('Password'),
                const SizedBox(height: 6),
                _PasswordField(
                  ctrl: passCtrl,
                  focusNode: passFocus,
                  obscure: obscure,
                  onToggle: onToggleObscure,
                  onSubmit: onSubmit,
                ),
                const SizedBox(height: 10),

                // Remember me
                _RememberMe(value: remember, onChanged: onToggleRemember),
                const SizedBox(height: 20),

                // Login button — only this rebuilds
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (p, c) => c is AuthLoading || p is AuthLoading,
                  builder: (_, state) => _LoginButton(
                      loading: state is AuthLoading, onTap: onSubmit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: _onSurfaceVariant,
          letterSpacing: 0.1,
        ),
      );
}

// ── Input fields ──────────────────────────────────────────────────────────────

InputDecoration _inputDeco({
  required String hint,
  required Widget prefix,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(
        color: _outlineVariant, fontSize: 16, fontWeight: FontWeight.w400),
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.50),
    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
    isDense: false,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _outline.withValues(alpha: 0.30)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: _outline.withValues(alpha: 0.30)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _error, width: 1.5),
    ),
  );
}

class _EmailField extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final FocusNode nextFocus;

  const _EmailField({
    required this.ctrl,
    required this.focusNode,
    required this.nextFocus,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      focusNode: focusNode,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 16, color: _onSurface),
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(nextFocus),
      decoration: _inputDeco(
        hint: 'agent@sector.com',
        prefix: const Icon(Icons.person_outline_rounded,
            color: _onSurfaceVariant, size: 22),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return 'Email is required';
        if (!v.contains('@')) return 'Enter a valid email';
        return null;
      },
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focusNode;
  final bool obscure;
  final VoidCallback onToggle;
  final VoidCallback onSubmit;

  const _PasswordField({
    required this.ctrl,
    required this.focusNode,
    required this.obscure,
    required this.onToggle,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      focusNode: focusNode,
      obscureText: obscure,
      textInputAction: TextInputAction.done,
      style: const TextStyle(fontSize: 16, color: _onSurface),
      onFieldSubmitted: (_) => onSubmit(),
      decoration: _inputDeco(
        hint: '••••••••',
        prefix: const Icon(Icons.lock_outline_rounded,
            color: _onSurfaceVariant, size: 22),
        suffix: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: _onSurfaceVariant,
            size: 22,
          ),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Password is required';
        if (v.length < 6) return 'Minimum 6 characters';
        return null;
      },
    );
  }
}

// ── Remember me ───────────────────────────────────────────────────────────────

class _RememberMe extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _RememberMe({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: value,
              onChanged: (v) => onChanged(v ?? false),
              activeColor: _primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: _outline, width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Remember this device',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Login button ──────────────────────────────────────────────────────────────

class _LoginButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _LoginButton({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: loading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primary.withValues(alpha: 0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.pressed) ? 2 : 8,
          ),
          shadowColor: WidgetStateProperty.all(
            _primary.withValues(alpha: 0.30),
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Login',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1)),
                  SizedBox(width: 8),
                  Icon(Icons.login_rounded, size: 22),
                ],
              ),
      ),
    );
  }
}

// ── Footer ────────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 11, color: _onSurfaceVariant),
            children: [
              TextSpan(text: "Don't have an account? "),
              TextSpan(
                text: 'Contact Administrator',
                style: TextStyle(color: _primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.40),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _PulsingDot(),
                  const SizedBox(width: 8),
                  const Text(
                    'System Online',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Help FAB ──────────────────────────────────────────────────────────────────

class _HelpFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.80),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.60)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline_rounded,
                color: _primary, size: 24),
          ),
        ),
      ),
    );
  }
}

// ── Pulsing green dot ─────────────────────────────────────────────────────────

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: 10,
        height: 10,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
