import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _phoneController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (_) => FocusNode());
      
  late final AnimationController _anim;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _slideIn = Tween(begin: const Offset(0, 1.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _phoneController.dispose();
    for (var c in _otpControllers) c.dispose();
    for (var f in _otpFocusNodes) f.dispose();
    super.dispose();
  }

  Future<void> _handleGetOTP() async {
    if (_phoneController.text.length < 10) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() { _otpSent = true; _isLoading = false; });
  }

  void _handleVerify() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      ref.read(appProvider.notifier).setMobile('+91 ${_phoneController.text}');
      ref.read(appProvider.notifier).login();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Immersive Background ──────────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/eventra_bg.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Subtle dark gradient from bottom so text/sheet pops
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.5),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),

          // ── Hero Branding ───────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: const Icon(LucideIcons.calendarHeart, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Eventra',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Discover and book\nunforgettable events.',
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1, letterSpacing: -1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join the premier ecosystem for event organizers and attendees today.',
                    style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8), height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Sheet Form ───────────────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: _slideIn,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 48),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                      border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.5))),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 40, height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: !_otpSent 
                            ? Column(
                                key: const ValueKey('phone'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Get Started', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  const SizedBox(height: 8),
                                  Text('Enter your mobile number to sign in or create an account', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                                  const SizedBox(height: 24),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: Text('+91', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600, fontSize: 16)),
                                        ),
                                        Container(width: 1, height: 24, color: AppColors.border),
                                        Expanded(
                                          child: TextField(
                                            controller: _phoneController,
                                            keyboardType: TextInputType.phone,
                                            maxLength: 10,
                                            style: TextStyle(color: AppColors.foreground, fontSize: 16),
                                            decoration: InputDecoration(
                                              counterText: '',
                                              hintText: 'Phone number',
                                              hintStyle: TextStyle(color: AppColors.mutedForeground),
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                            ),
                                            onChanged: (_) => setState(() {}),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  _PrimaryButton(
                                    label: 'Continue',
                                    loading: _isLoading,
                                    enabled: _phoneController.text.length >= 10 && !_isLoading,
                                    onTap: _handleGetOTP,
                                  ),
                                ],
                              )
                            : Column(
                                key: const ValueKey('otp'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Verify Number', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  const SizedBox(height: 8),
                                  Text('We sent a 6-digit code to +91 ${_phoneController.text}', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                                  const SizedBox(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: List.generate(6, (i) => _OtpBox(
                                      controller: _otpControllers[i],
                                      focusNode: _otpFocusNodes[i],
                                      onChanged: (v) {
                                        if (v.isNotEmpty && i < 5) _otpFocusNodes[i + 1].requestFocus();
                                        if (v.isEmpty && i > 0) _otpFocusNodes[i - 1].requestFocus();
                                        setState(() {});
                                      },
                                    )),
                                  ),
                                  const SizedBox(height: 32),
                                  _PrimaryButton(
                                    label: 'Verify & Login',
                                    loading: _isLoading,
                                    enabled: !_isLoading,
                                    onTap: _handleVerify,
                                  ),
                                  const SizedBox(height: 16),
                                  Center(
                                    child: TextButton(
                                      onPressed: () {
                                        setState(() { _otpSent = false; _isLoading = false; for(var c in _otpControllers) { c.clear(); }});
                                      },
                                      child: Text('Edit phone number', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({required this.label, required this.enabled, this.loading = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled ? 1.0 : 0.5,
      child: InkWell(
        onTap: enabled && !loading ? onTap : null,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.foreground,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Center(
            child: loading
                ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.background))
                : Text(label, style: TextStyle(color: AppColors.background, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.foreground),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
