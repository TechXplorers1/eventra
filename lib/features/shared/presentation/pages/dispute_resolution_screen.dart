import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

class DisputeResolutionScreen extends ConsumerStatefulWidget {
  final String id;
  const DisputeResolutionScreen({super.key, required this.id});

  @override
  ConsumerState<DisputeResolutionScreen> createState() => _DisputeResolutionScreenState();
}

class _DisputeResolutionScreenState extends ConsumerState<DisputeResolutionScreen> {
  final _descriptionController = TextEditingController();
  bool _isSubmitting = false;
  String? _selectedReason;

  final List<String> _reasons = [
    'Vendor No-Show',
    'Poor Quality of Service',
    'Payment Dispute',
    'Unprofessional Behavior',
    'Other'
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_selectedReason == null || _descriptionController.text.trim().isEmpty) return;
    
    setState(() => _isSubmitting = true);
    
    // Simulate network request
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Column(
            children: [
              const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 48),
              const SizedBox(height: 16),
              Text('Issue Reported', textAlign: TextAlign.center, style: TextStyle(color: AppColors.foreground)),
            ],
          ),
          content: Text(
            'We have received your report. Our support team will review the details and contact you within 24-48 hours.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.mutedForeground, height: 1.5),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                context.pop(); // close dialog
                context.pop(); // close screen
              },
              child: Text('Return to Booking', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
          onPressed: () => context.pop(),
        ),
        title: Text('Report an Issue', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What went wrong?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide details so our team can help resolve this issue as quickly as possible.',
              style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.4),
            ),
            const SizedBox(height: 32),
            
            // Reason Dropdown
            Text('Select a Reason', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedReason,
                  hint: Text('Choose a reason...', style: TextStyle(color: AppColors.mutedForeground)),
                  dropdownColor: AppColors.card,
                  isExpanded: true,
                  icon: Icon(LucideIcons.chevronDown, color: AppColors.mutedForeground),
                  style: TextStyle(color: AppColors.foreground, fontSize: 16),
                  items: _reasons.map((reason) {
                    return DropdownMenuItem(
                      value: reason,
                      child: Text(reason),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedReason = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Description Text
            Text('Provide Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _descriptionController,
                maxLines: 6,
                style: TextStyle(color: AppColors.foreground),
                decoration: InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  hintStyle: TextStyle(color: AppColors.mutedForeground),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Attachment Mock
            Text('Attachments (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                // Mock attachment picker
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File picker opened...')));
              },
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(LucideIcons.uploadCloud, color: AppColors.primary, size: 32),
                    const SizedBox(height: 12),
                    Text('Tap to upload photos or documents', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Max size 10MB', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Submit Button
            GestureDetector(
              onTap: _selectedReason != null && _descriptionController.text.trim().isNotEmpty && !_isSubmitting ? _handleSubmit : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _selectedReason != null && _descriptionController.text.trim().isNotEmpty && !_isSubmitting ? 1.0 : 0.5,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.destructive,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  alignment: Alignment.center,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Submit Report', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
