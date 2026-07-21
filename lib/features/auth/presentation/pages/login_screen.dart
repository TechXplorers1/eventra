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
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideIn;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeIn = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slideIn = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
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
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() { _otpSent = true; _isLoading = false; });
  }

  void _handleVerify() {
    setState(() => _isLoading = true);
    ref.read(appProvider.notifier).setMobile('+91 ${_phoneController.text}');
    ref.read(appProvider.notifier).login();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          // ── Radial glow top ───────────────────────────────────────────
          Positioned(
            top: -80, left: size.width / 2 - 160,
            child: Container(
              width: 320, height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.primary.withAlpha(70), Colors.transparent],
                  stops: const [0.0, 1.0],
                ),
              ),
            ),
          ),
          // ── Accent glow bottom ────────────────────────────────────────
          Positioned(
            bottom: 0, right: -60,
            child: Container(
              width: 220, height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.accent.withAlpha(50), Colors.transparent],
                ),
              ),
            ),
          ),

          // ── Main Content ──────────────────────────────────────────────
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                  child: Column(
                    children: [
                      const Spacer(flex: 2),

                      // Logo + Brand
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: AppColors.primary.withAlpha(80), blurRadius: 24, offset: const Offset(0, 8))],
                        ),
                        child: const Icon(LucideIcons.calendarDays, size: 32, color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ShaderMask(
                        shaderCallback: (rect) => LinearGradient(
                          colors: [AppColors.primary, AppColors.accent],
                        ).createShader(rect),
                        child: const Text('Eventra', style: TextStyle(
                          fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white,
                        )),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your complete event ecosystem',
                        style: TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                      ),

                      const Spacer(flex: 2),

                      // ── Form Card ─────────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _otpSent ? 'Verify OTP' : 'Sign In',
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.foreground),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _otpSent
                                  ? 'Enter the 6-digit code sent to +91 ${_phoneController.text}'
                                  : 'Enter your phone number to continue',
                              style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                            ),
                            const SizedBox(height: AppSpacing.md),

                            if (!_otpSent) ...[
                              // Phone field
                              Row(children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(children: [
                                    Text('+91', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600, fontSize: 15)),
                                    const SizedBox(width: 4),
                                    Icon(Icons.keyboard_arrow_down, size: 16, color: AppColors.mutedForeground),
                                  ]),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    controller: _phoneController,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    style: TextStyle(color: AppColors.foreground, fontSize: 15, fontWeight: FontWeight.w500),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      hintText: '98765 43210',
                                      filled: true, fillColor: AppColors.secondary,
                                      prefixIcon: Icon(LucideIcons.smartphone, size: 16, color: AppColors.mutedForeground),
                                    ),
                                    onChanged: (_) => setState(() {}),
                                  ),
                                ),
                              ]),
                              const SizedBox(height: AppSpacing.md),
                              _PrimaryButton(
                                label: 'Get OTP',
                                loading: _isLoading,
                                enabled: _phoneController.text.length >= 10 && !_isLoading,
                                onTap: _handleGetOTP,
                              ),
                            ] else ...[
                              // OTP inputs
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (i) => _OtpBox(
                                  controller: _otpControllers[i],
                                  focusNode: _otpFocusNodes[i],
                                  onChanged: (v) {
                                    if (v.isNotEmpty && i < 5) _otpFocusNodes[i + 1].requestFocus();
                                    setState(() {});
                                  },
                                )),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              _PrimaryButton(
                                label: 'Verify & Continue',
                                loading: _isLoading,
                                enabled: !_isLoading,
                                onTap: _handleVerify,
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton(
                                  onPressed: () => setState(() { _otpSent = false; _isLoading = false; }),
                                  child: Text('Change Number',
                                      style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const Spacer(flex: 1),

                      // Terms
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          'By continuing, you agree to Eventra Terms of Service and Privacy Policy.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: AppColors.mutedForeground, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                    ],
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

// ── Primary Button ────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool loading;
  final VoidCallback? onTap;

  const _PrimaryButton({required this.label, required this.enabled, this.loading = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: enabled ? 1.0 : 0.5,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: enabled ? AppColors.primaryGradient : null,
            color: enabled ? null : AppColors.secondary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            boxShadow: enabled
                ? [BoxShadow(color: AppColors.primary.withAlpha(60), blurRadius: 16, offset: const Offset(0, 6))]
                : null,
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Text(label, style: const TextStyle(
                    color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

// ── OTP Box ───────────────────────────────────────────────────────────────────
class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({required this.controller, required this.focusNode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.foreground),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: AppColors.secondary,
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
