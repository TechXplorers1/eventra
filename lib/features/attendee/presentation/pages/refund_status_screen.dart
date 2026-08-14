import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class RefundStatusScreen extends StatelessWidget {
  final String bookingId;
  final double amount;
  final String entityName;
  final String type; // 'ticket' or 'service'

  const RefundStatusScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.entityName,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
          onPressed: () => _navigateBack(context),
        ),
        title: Text('Refund Status', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3), width: 4),
                ),
                child: const Icon(LucideIcons.checkCircle2, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 24),
              const Text('Cancellation Successful', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                'Your booking for $entityName has been cancelled.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.4),
              ),
              const SizedBox(height: 32),
              
              // Refund Details Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text('Refund Amount', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                    const SizedBox(height: 8),
                    Text('₹${amount.toInt()}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Reference No', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        Text('REF-${bookingId.toUpperCase()}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Timeline Tracker
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('REFUND TIMELINE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 16),
              
              _buildTimelineStep(
                title: 'Cancellation Confirmed',
                subtitle: 'Just now',
                isCompleted: true,
                isLast: false,
              ),
              _buildTimelineStep(
                title: 'Refund Initiated',
                subtitle: 'Usually within 1-2 hours',
                isCompleted: true,
                isLast: false,
              ),
              _buildTimelineStep(
                title: 'Refund Processed',
                subtitle: 'Expected within 3-5 business days depending on your bank',
                isCompleted: false,
                isLast: true,
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateBack(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  Widget _buildTimelineStep({required String title, required String subtitle, required bool isCompleted, required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: isCompleted ? Colors.green : AppColors.border, width: 2),
              ),
              child: isCompleted ? const Icon(LucideIcons.check, size: 14, color: Colors.white) : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green.withValues(alpha: 0.5) : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isCompleted ? AppColors.foreground : AppColors.mutedForeground)),
              const SizedBox(height: 4),
              Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
