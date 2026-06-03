import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/auth_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dialog_utils.dart';
import 'package:zytama_data/features/product/presentation/screens/dashboard_screen.dart';
import 'privacy_policy_screen.dart';

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
                    AppColors.background,
                    AppColors.background,
                    AppColors.accent,
                  ],
                ),
              ),
            ),

            // ── Decorative blurred circles ───────────────────────────
            Positioned(
              top: -100,
              right: -100,
              child:
                  _blurCircle(280, AppColors.primary.withValues(alpha: 0.08)),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child:
                  _blurCircle(220, AppColors.primary.withValues(alpha: 0.06)),
            ),
            Positioned(
              top: 200,
              left: -60,
              child: _blurCircle(160, AppColors.accent.withValues(alpha: 0.5)),
            ),

            // ── Scrollable content ───────────────────────────────────
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  final hPad = isWide ? (constraints.maxWidth - 480) / 2 : 16.0;
                  return SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.symmetric(horizontal: hPad),
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
                  );
                },
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
          // decoration: BoxDecoration(
          //   color: AppColors.primary,
          //   borderRadius: BorderRadius.circular(20),
          //   border: Border.all(
          //       color: Colors.white.withValues(alpha: 0.5), width: 2),
          //   boxShadow: [
          //     BoxShadow(
          //       color: AppColors.primary.withValues(alpha: 0.4),
          //       blurRadius: 24,
          //       offset: const Offset(0, 10),
          //     ),
          //   ],
          // ),
          // child: const Icon(Icons.inventory_2_rounded, color: Colors.white, size: 44),
          child: SvgPicture.asset(
            'assets/svg/LOGO.svg',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Zytama',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Product Data Collection',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textLight,
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
          color: AppColors.textLight,
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
        color: AppColors.outline, fontSize: 16, fontWeight: FontWeight.w400),
    prefixIcon: prefix,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.50),
    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
    isDense: false,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          BorderSide(color: AppColors.outlineDim.withValues(alpha: 0.30)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
          BorderSide(color: AppColors.outlineDim.withValues(alpha: 0.30)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
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
      style: const TextStyle(fontSize: 16, color: AppColors.textDark),
      onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(nextFocus),
      decoration: _inputDeco(
        hint: 'agent@sector.com',
        prefix: const Icon(Icons.person_outline_rounded,
            color: AppColors.textLight, size: 22),
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
      style: const TextStyle(fontSize: 16, color: AppColors.textDark),
      onFieldSubmitted: (_) => onSubmit(),
      decoration: _inputDeco(
        hint: '••••••••',
        prefix: const Icon(Icons.lock_outline_rounded,
            color: AppColors.textLight, size: 22),
        suffix: IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: AppColors.textLight,
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
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4)),
              side: const BorderSide(color: AppColors.outlineDim, width: 1.5),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Remember this device',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.textLight,
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
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ).copyWith(
          elevation: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.pressed) ? 2 : 8,
          ),
          shadowColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.30),
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
  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.35),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.admin_panel_settings_rounded,
              color: AppColors.primary, size: 28),
        ),
        title: const Text(
          'Create an Account',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: AppColors.textDark),
        ),
        content: const Text(
          'Agent accounts are managed by your administrator.\n\n'
          'To request access, please contact your team lead or sign up directly through the Zytama web portal.',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 14, height: 1.6, color: AppColors.textMedium),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close',
                style: TextStyle(color: AppColors.textLight)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.of(context).pop();
              final uri = Uri.parse('https://www.zytama.com');
              if (await canLaunchUrl(uri)) launchUrl(uri);
            },
            icon: const Icon(Icons.open_in_browser_rounded, size: 18),
            label: const Text('Open Web Portal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(fontSize: 11, color: AppColors.textLight),
            ),
            GestureDetector(
              onTap: () => _showContactDialog(context),
              child: const Text(
                'Contact Administrator',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
          ),
          child: const Text(
            'Privacy Policy',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
            ),
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
                      color: AppColors.textLight,
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
                color: AppColors.primary, size: 24),
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
          color: AppColors.secondary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
