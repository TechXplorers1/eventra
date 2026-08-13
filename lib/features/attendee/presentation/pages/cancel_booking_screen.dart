import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

class CancelBookingScreen extends ConsumerStatefulWidget {
  final String bookingType; // 'ticket' or 'service'
  final String bookingId;

  const CancelBookingScreen({
    super.key,
    required this.bookingType,
    required this.bookingId,
  });

  @override
  ConsumerState<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends ConsumerState<CancelBookingScreen> {
  bool _isProcessing = false;

  void _processCancellation(double refundAmount, String entityName) async {
    setState(() => _isProcessing = true);
    
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final appState = ref.read(appProvider.notifier);

    if (widget.bookingType == 'ticket') {
      appState.removeBooking(widget.bookingId);
    } else {
      appState.removeServiceBooking(widget.bookingId);
    }

    context.go('/refund-status/${widget.bookingId}', extra: {
      'amount': refundAmount,
      'entityName': entityName,
      'type': widget.bookingType,
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    
    String entityName = '';
    double totalPaid = 0;
    
    if (widget.bookingType == 'ticket') {
      final tickets = appState.bookedTickets.where((t) => t.id == widget.bookingId).toList();
      if (tickets.isEmpty) return const Scaffold(body: Center(child: Text('Ticket not found')));
      final ticket = tickets.first;
      entityName = '${ticket.eventTitle} (${ticket.ticketType})';
      totalPaid = ticket.totalPrice;
    } else {
      final bookings = appState.serviceBookings.where((b) => b.id == widget.bookingId).toList();
      if (bookings.isEmpty) return const Scaffold(body: Center(child: Text('Service not found')));
      final booking = bookings.first;
      entityName = booking.serviceName;
      totalPaid = booking.total;
    }

    // Example Refund Policy Logic
    // If we had actual dates, we'd calculate based on proximity to event.
    // We'll mock it as a 100% refund for demonstration.
    final refundAmount = totalPaid;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
          onPressed: () => context.pop(),
        ),
        title: Text('Cancel Booking', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.destructive.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: Icon(LucideIcons.alertCircle, color: AppColors.destructive, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Are you sure?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          const SizedBox(height: 4),
                          Text('You are about to cancel your booking for $entityName.', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Text('REFUND POLICY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.mutedForeground)),
              const SizedBox(height: 12),
              _buildPolicyItem(LucideIcons.checkCircle2, '100% refund if cancelled 48 hours prior to the event start.'),
              _buildPolicyItem(LucideIcons.info, '50% refund if cancelled within 48 hours.'),
              _buildPolicyItem(LucideIcons.alertTriangle, 'No refund for no-shows or post-event cancellations.'),
              
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildAmountRow('Total Paid', totalPaid),
                    const SizedBox(height: 8),
                    _buildAmountRow('Cancellation Fee', 0),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(),
                    ),
                    _buildAmountRow('Estimated Refund', refundAmount, isTotal: true),
                  ],
                ),
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : () => _processCancellation(refundAmount, entityName),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.destructive,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isProcessing 
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('Confirm Cancellation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isProcessing ? null : () => context.pop(),
                  child: Text('Keep Booking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicyItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.mutedForeground),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: AppColors.foreground, height: 1.4))),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, double amount, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? AppColors.foreground : AppColors.mutedForeground)),
        Text(
          amount == 0 ? 'Free' : '₹${amount.toInt()}', 
          style: TextStyle(
            fontSize: isTotal ? 18 : 14, 
            fontWeight: FontWeight.bold, 
            color: isTotal ? Colors.green : AppColors.foreground
          ),
        ),
      ],
    );
  }
}
