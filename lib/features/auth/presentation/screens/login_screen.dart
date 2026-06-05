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
  bool _trustDevice = false;

  @override
  void initState() {
    super.initState();
    // _emailCtrl.text = 'devag1-0001@zytama.com';
    // _passCtrl.text = 'TestPassword@456';
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
    final size = MediaQuery.of(context).size;
    final isWide = size.width > 600;
    final hPad = isWide ? (size.width - 480) / 2 : 28.0;

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
          body: Container(
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: const AssetImage('assets/images/login_bg.png'),
                  fit: BoxFit.cover),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.1),
                      SvgPicture.asset(
                        'assets/svg/logo1.svg',
                        height: (size.height * 0.13).clamp(72.0, 110.0),
                      ),
                      SizedBox(height: size.height * 0.01),
                      SvgPicture.asset(
                        'assets/svg/zytama.svg',
                        width: (size.width * 0.28).clamp(160.0, 160.0),
                      ),
                      SizedBox(height: size.height * 0.016),
                      Text(
                        'Hey, Welcome Back!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: (size.width * 0.062).clamp(20.0, 26.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Login to your Account',
                        style: TextStyle(
                          fontSize: (size.width * 0.036).clamp(12.0, 15.0),
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: size.height * 0.028),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _fieldLabel('Email'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailCtrl,
                                focusNode: _emailFocus,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.textDark),
                                onFieldSubmitted: (_) => FocusScope.of(context)
                                    .requestFocus(_passFocus),
                                decoration: _inputDeco(
                                  hint: 'agent@zytama.com',
                                  suffix: const Icon(Icons.mail_outline,
                                      color: Colors.grey, size: 20),
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!v.contains('@')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _fieldLabel('Password'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passCtrl,
                                focusNode: _passFocus,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                style: const TextStyle(
                                    fontSize: 14, color: AppColors.textDark),
                                onFieldSubmitted: (_) => _submit(),
                                decoration: _inputDeco(
                                  hint: '••••••••',
                                  suffix: IconButton(
                                    icon: Icon(
                                      _obscure
                                          ? Icons.lock_outline
                                          : Icons.lock_open,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                  ),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (v.length < 6) {
                                    return 'Minimum 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              GestureDetector(
                                onTap: () => setState(
                                    () => _trustDevice = !_trustDevice),
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Checkbox(
                                        value: _trustDevice,
                                        onChanged: (v) => setState(
                                            () => _trustDevice = v ?? false),
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'Trust This Device for 30 Days',
                                      style: TextStyle(
                                          fontSize: 13, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              BlocBuilder<AuthBloc, AuthState>(
                                buildWhen: (p, c) =>
                                    c is AuthLoading || p is AuthLoading,
                                builder: (_, state) {
                                  final loading = state is AuthLoading;
                                  return SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: loading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: AppColors
                                            .primary
                                            .withValues(alpha: 0.6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        elevation: 4,
                                      ),
                                      child: loading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 2.5),
                                            )
                                          : const Row(
                                              children: [
                                                Spacer(),
                                                Text(
                                                  'Login',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                Spacer(),
                                                Icon(Icons.arrow_forward,
                                                    size: 20),
                                                SizedBox(width: 4),
                                              ],
                                            ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.028),
                      GestureDetector(
                        onTap: () => _showContactDialog(context),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(fontSize: 13),
                            children: [
                              TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(color: AppColors.primary),
                              ),
                              TextSpan(
                                text: 'Contact Administrator',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.012),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const PrivacyPolicyScreen()),
                        ),
                        child: const Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget _fieldLabel(String text) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      );

  InputDecoration _inputDeco({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.30),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.admin_panel_settings_rounded,
              color: AppColors.primary, size: 26),
        ),
        title: const Text(
          'Create an Account',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: AppColors.textDark),
        ),
        content: const Text(
          'Agent accounts are managed by your administrator.\n\n'
          'To request access, contact your team lead or sign up via the Zytama web portal.',
          textAlign: TextAlign.center,
          style:
              TextStyle(fontSize: 13, height: 1.6, color: AppColors.textMedium),
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
            icon: const Icon(Icons.open_in_browser_rounded, size: 16),
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
}
