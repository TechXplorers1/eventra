import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class PrivacySecurityScreen extends StatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  State<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends State<PrivacySecurityScreen> {
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  Map<String, String> _errors = {};
  bool _pwSaved = false;

  bool _twoFAEnabled = true;
  bool _biometric = false;
  bool _loginAlerts = true;

  bool _showDeleteModal = false;
  String _deleteConfirm = '';

  bool _show2FAModal = false;
  bool _otpStep = false;
  String _otp = '';

  int _getStrength(String pw) {
    int s = 0;
    if (pw.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(pw)) s++;
    if (RegExp(r'[0-9]').hasMatch(pw)) s++;
    if (RegExp(r'[^a-zA-Z0-9]').hasMatch(pw)) s++;
    return s;
  }

  bool _validatePassword() {
    final e = <String, String>{};
    if (_currentCtrl.text.isEmpty) e['current'] = 'Current password is required';
    if (_newCtrl.text.length < 8) e['new'] = 'Password must be at least 8 characters';
    if (_newCtrl.text != _confirmCtrl.text) e['confirm'] = 'Passwords do not match';
    setState(() => _errors = e);
    return e.isEmpty;
  }

  void _handleChangePassword() {
    if (!_validatePassword()) return;
    setState(() {
      _pwSaved = true;
      _currentCtrl.clear();
      _newCtrl.clear();
      _confirmCtrl.clear();
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) setState(() => _pwSaved = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final strength = _getStrength(_newCtrl.text);
    const strengthLabels = ['', 'Weak', 'Fair', 'Good', 'Strong'];
    final strengthColors = [Colors.transparent, AppColors.destructive, Colors.orange, Colors.yellow, Colors.green];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Privacy & Security', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              Text('Manage your account security', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Security Score
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                          child: Icon(LucideIcons.shield, size: 18, color: AppColors.primaryForeground),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Security Score: Good', style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.bold)),
                              Text('Enable 2FA for maximum security', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CircularProgressIndicator(value: 0.75, backgroundColor: AppColors.border, color: AppColors.primary, strokeWidth: 3),
                              Center(child: Text('75%', style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold))),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Change Password
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.lock, size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Change Password', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              if (_pwSaved)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), border: Border.all(color: Colors.green.withOpacity(0.2)), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    children: [
                                      Icon(LucideIcons.check, size: 14, color: Colors.green),
                                      const SizedBox(width: 8),
                                      Text('Password updated successfully!', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              _buildPasswordField('Current Password', _currentCtrl, _showCurrent, (v) => setState(() => _showCurrent = v), _errors['current']),
                              const SizedBox(height: 12),
                              _buildPasswordField('New Password', _newCtrl, _showNew, (v) => setState(() => _showNew = v), _errors['new']),
                              if (_newCtrl.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: List.generate(4, (i) {
                                          return Expanded(
                                            child: Container(
                                              height: 4,
                                              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                                              decoration: BoxDecoration(
                                                color: (i + 1) <= strength ? strengthColors[strength] : AppColors.border,
                                                borderRadius: BorderRadius.circular(2),
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(strengthLabels[strength], style: TextStyle(color: AppColors.mutedForeground, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 12),
                              _buildPasswordField('Confirm Password', _confirmCtrl, _showConfirm, (v) => setState(() => _showConfirm = v), _errors['confirm']),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _handleChangePassword,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Update Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Authentication
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.smartphone, size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Authentication', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              _buildAuthItem(LucideIcons.shield, 'Two-Factor Authentication', _twoFAEnabled ? 'Enabled via SMS' : 'Add extra layer of security', _twoFAEnabled, () {
                                if (!_twoFAEnabled) {
                                  setState(() => _show2FAModal = true);
                                } else {
                                  setState(() => _twoFAEnabled = false);
                                }
                              }, true, AppColors.primary),
                              _buildAuthItem(LucideIcons.fingerprint, 'Biometric Login', 'Use fingerprint or Face ID', _biometric, () => setState(() => _biometric = !_biometric), true, AppColors.primary),
                              _buildAuthItem(LucideIcons.alertTriangle, 'Login Alerts', 'Notify on new device login', _loginAlerts, () => setState(() => _loginAlerts = !_loginAlerts), false, Colors.orange),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Sessions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Active Sessions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              _buildSessionItem('iPhone 14 Pro', 'Mumbai, India', 'Now (Current)', true, true),
                              _buildSessionItem('MacBook Air', 'Mumbai, India', '2 hours ago', false, true),
                              _buildSessionItem('Chrome on Windows', 'Delhi, India', '3 days ago', false, false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Danger
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.destructive.withOpacity(0.1),
                        border: Border.all(color: AppColors.destructive.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(LucideIcons.alertTriangle, size: 18, color: AppColors.destructive),
                              const SizedBox(width: 8),
                              Text('Danger Zone', style: TextStyle(color: AppColors.destructive, fontSize: 14, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Deleting your account is permanent and cannot be undone. All your bookings, saved events, and data will be lost.', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => setState(() => _showDeleteModal = true),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: AppColors.destructive.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Delete Account', style: TextStyle(color: AppColors.destructive, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (_showDeleteModal) _buildDeleteModal(),
          if (_show2FAModal) _build2FAModal(),
          
          const BottomNav(),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String hint, TextEditingController ctrl, bool show, Function(bool) onToggle, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: ctrl,
          obscureText: !show,
          onChanged: (v) => setState(() {}),
          style: TextStyle(color: AppColors.foreground, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.mutedForeground),
            filled: true,
            fillColor: AppColors.input,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error != null ? AppColors.destructive : AppColors.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error != null ? AppColors.destructive : AppColors.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error != null ? AppColors.destructive : AppColors.primary)),
            suffixIcon: IconButton(
              icon: Icon(show ? LucideIcons.eyeOff : LucideIcons.eye, color: AppColors.mutedForeground, size: 16),
              onPressed: () => onToggle(!show),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(error, style: TextStyle(color: AppColors.destructive, fontSize: 12)),
          ),
      ],
    );
  }

  Widget _buildAuthItem(IconData icon, String label, String desc, bool value, VoidCallback onToggle, bool border, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: border ? Border(bottom: BorderSide(color: AppColors.border)) : null),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(desc, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: (v) => onToggle(),
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionItem(String device, String loc, String time, bool current, bool border) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: border ? Border(bottom: BorderSide(color: AppColors.border)) : null),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
            child: Icon(LucideIcons.smartphone, size: 16, color: current ? AppColors.primary : AppColors.mutedForeground),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(device, style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                Text('$loc · $time', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ),
          ),
          if (current)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: const Text('Active', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
            )
          else
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening detailed privacy policy...')));
              },
              child: Text('Revoke', style: TextStyle(color: AppColors.destructive, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildDeleteModal() {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(24)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.destructive.withOpacity(0.2), shape: BoxShape.circle),
                  child: Icon(LucideIcons.alertTriangle, color: AppColors.destructive, size: 22),
                ),
                const SizedBox(height: 16),
                Text('Delete Account?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
                    children: [
                      const TextSpan(text: 'Type '),
                      TextSpan(text: 'DELETE', style: TextStyle(color: AppColors.destructive, fontWeight: FontWeight.bold)),
                      const TextSpan(text: ' to confirm'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  onChanged: (v) => setState(() => _deleteConfirm = v),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.foreground, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Type DELETE',
                    hintStyle: TextStyle(color: AppColors.mutedForeground),
                    filled: true,
                    fillColor: AppColors.input,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => setState(() { _showDeleteModal = false; _deleteConfirm = ''; }),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.muted, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Text('Cancel', style: TextStyle(color: AppColors.foreground)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _deleteConfirm == 'DELETE' ? () {} : null,
                        style: ElevatedButton.styleFrom(backgroundColor: _deleteConfirm == 'DELETE' ? AppColors.destructive : AppColors.destructive.withOpacity(0.3), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _build2FAModal() {
    return Container(
      color: Colors.black87,
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Enable 2FA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                IconButton(
                  icon: Icon(LucideIcons.x, size: 18, color: AppColors.mutedForeground),
                  onPressed: () => setState(() => _show2FAModal = false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!_otpStep) ...[
              Text("We'll send a verification code to +91 98765 43210", style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => setState(() => _otpStep = true),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Send OTP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ] else ...[
              Text('Enter the 6-digit OTP sent to your phone', style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => setState(() => _otp = v),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(color: AppColors.foreground, fontSize: 18, letterSpacing: 8),
                decoration: InputDecoration(
                  hintText: '• • • • • •',
                  hintStyle: TextStyle(color: AppColors.mutedForeground, letterSpacing: 8),
                  filled: true,
                  fillColor: AppColors.input,
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_otp.length == 6) {
                      setState(() {
                        _twoFAEnabled = true;
                        _show2FAModal = false;
                        _otpStep = false;
                        _otp = '';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: const Text('Verify & Enable', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
            const SizedBox(height: 24), // spacing for bottom nav if needed
          ],
        ),
      ),
    );
  }
}
