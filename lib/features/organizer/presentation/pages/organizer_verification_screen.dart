import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';

class OrganizerVerificationScreen extends ConsumerStatefulWidget {
  const OrganizerVerificationScreen({super.key});

  @override
  ConsumerState<OrganizerVerificationScreen> createState() => _OrganizerVerificationScreenState();
}

class _OrganizerVerificationScreenState extends ConsumerState<OrganizerVerificationScreen> {
  int _step = 0;
  bool _submitted = false;

  final _aadhaarCtrl = TextEditingController();
  final _panCtrl = TextEditingController();
  final _passportCtrl = TextEditingController();
  final _licenseCtrl = TextEditingController();

  final _orgNameCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _socialsCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();

  final _holderCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();

  final _prevCountCtrl = TextEditingController();
  final _portfolioCtrl = TextEditingController();

  final _steps = ['Identity', 'Business', 'Bank', 'Experience'];

  @override
  void initState() {
    super.initState();
    final organizer = ref.read(appProvider).organizer;
    _orgNameCtrl.text = organizer.orgName;
    _cityCtrl.text = organizer.city;
    _stateCtrl.text = organizer.state;
  }

  void _submit() {
    // Immediately mark as pending in AppState — dashboard shows "Pending Review"
    ref.read(appProvider.notifier).updateOrganizerStatus('pending');
    setState(() => _submitted = true);
    // Simulate approval after a delay (auto-approve for demo)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        ref.read(appProvider.notifier).updateOrganizerStatus('verified');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_submitted) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30)],
                  ),
                  child: Icon(LucideIcons.shieldCheck, size: 40, color: AppColors.primaryForeground),
                ),
                const SizedBox(height: 24),
                Text('Submitted for Review', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 8),
                Text('Our team typically reviews within 24-48 hours. You\'ll be notified once approved.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Pending Review', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/organizer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Back to Dashboard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (_step == 0) {
                        context.pop();
                      } else {
                        setState(() => _step--);
                      }
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Organizer Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('Step ${_step + 1} of ${_steps.length}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: List.generate(_steps.length, (i) {
                  final isActive = i <= _step;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        children: [
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: isActive ? AppColors.primary : AppColors.secondary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(_steps[i], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? AppColors.primary : AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  if (_step == 0) _buildSection('Identity Verification', LucideIcons.fileText, [
                    _buildInput('Aadhaar / Government ID *', _aadhaarCtrl, placeholder: 'XXXX XXXX XXXX'),
                    _buildInput('PAN Number *', _panCtrl, placeholder: 'ABCDE1234F'),
                    _buildInput('Passport (Optional)', _passportCtrl),
                    _buildInput('Driving License (Optional)', _licenseCtrl),
                  ]),
                  if (_step == 1) _buildSection('Business Information', LucideIcons.briefcase, [
                    _buildInput('Organization Name *', _orgNameCtrl),
                    _buildInput('Website (Optional)', _websiteCtrl, placeholder: 'https://'),
                    _buildInput('Social Media Links', _socialsCtrl, placeholder: '@handle'),
                    Row(
                      children: [
                        Expanded(child: _buildInput('City *', _cityCtrl)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildInput('State *', _stateCtrl)),
                      ],
                    ),
                  ]),
                  if (_step == 2) _buildSection('Financial Information', LucideIcons.landmark, [
                    _buildInput('Account Holder Name *', _holderCtrl),
                    _buildInput('Bank Name *', _bankCtrl),
                    _buildInput('Account Number *', _accountCtrl),
                    _buildInput('IFSC Code *', _ifscCtrl),
                    _buildInput('UPI ID', _upiCtrl, placeholder: 'you@upi'),
                  ]),
                  if (_step == 3) _buildSection('Experience', LucideIcons.image, [
                    _buildInput('Number of Previous Events', _prevCountCtrl, placeholder: '0', keyboardType: TextInputType.number),
                    _buildInput('Event Portfolio (link, optional)', _portfolioCtrl, placeholder: 'https://'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, style: BorderStyle.solid), // No dashed border native easy, solid is fine
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.image, size: 16, color: AppColors.mutedForeground),
                          const SizedBox(width: 8),
                          Text('Upload Event Images (optional)', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ]),
                  
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      if (_step > 0) ...[
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => setState(() => _step--),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: AppColors.foreground,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Back', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _step < _steps.length - 1 ? () => setState(() => _step++) : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primaryForeground,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _step < _steps.length - 1
                              ? const Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(LucideIcons.checkCircle2, size: 16),
                                    SizedBox(width: 8),
                                    Text('Submit for Review', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.foreground),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInput(String label, TextEditingController controller, {String? placeholder, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppColors.mutedForeground)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(color: AppColors.foreground, fontSize: 14),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: AppColors.mutedForeground.withOpacity(0.5)),
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
