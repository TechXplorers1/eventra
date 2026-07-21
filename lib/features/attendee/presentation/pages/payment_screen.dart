import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;
  const PaymentScreen({super.key, required this.bookingData});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedMethod = 'upi';

  final _paymentMethods = [
    {'id': 'upi', 'label': 'UPI', 'icon': LucideIcons.smartphone, 'desc': 'Google Pay, PhonePe, Paytm'},
    {'id': 'card', 'label': 'Credit/Debit Card', 'icon': LucideIcons.creditCard, 'desc': 'Visa, Mastercard, RuPay'},
    {'id': 'netbanking', 'label': 'Net Banking', 'icon': LucideIcons.building2, 'desc': 'All major banks'},
    {'id': 'wallet', 'label': 'Wallets', 'icon': LucideIcons.wallet, 'desc': 'Paytm, Amazon Pay'},
  ];

  @override
  Widget build(BuildContext context) {
    final data = widget.bookingData;
    final grandTotal = data['grandTotal'] as double;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => context.pop(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Payment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                ],
              ),
            ),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Secure badge
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Icon(LucideIcons.shieldCheck, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Text('Secured by 256-bit encryption', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.green)),
                      ],
                    ),
                  ),

                  Text('Select Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  const SizedBox(height: 12),

                  ..._paymentMethods.map((m) {
                    final isSelected = _selectedMethod == m['id'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedMethod = m['id'] as String),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                            border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.3) : Colors.transparent),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(
                                  gradient: isSelected ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                                  color: isSelected ? null : AppColors.muted,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(m['icon'] as IconData, size: 18, color: isSelected ? AppColors.primaryForeground : AppColors.mutedForeground),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(m['label'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                    Text(m['desc'] as String, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                  ],
                                ),
                              ),
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.mutedForeground, width: 2),
                                  color: isSelected ? AppColors.primary : Colors.transparent,
                                ),
                                child: isSelected
                                    ? Center(child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primaryForeground, shape: BoxShape.circle)))
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: () {
                      final ticket = BookedTicket(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        eventId: data['eventId'],
                        eventTitle: data['eventTitle'],
                        eventDate: data['eventDate'],
                        eventTime: data['eventTime'],
                        eventVenue: data['eventVenue'],
                        ticketType: data['sectionName'],
                        quantity: data['seatCount'],
                        seats: List<String>.from(data['seats']),
                        totalPrice: data['grandTotal'],
                        qrCode: 'EVT-${data['eventId']}-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}',
                        bookedAt: DateTime.now().toIso8601String(),
                        eventImageKey: data['eventImageKey'],
                      );
                      ref.read(appProvider.notifier).addBooking(ticket);
                      context.go('/booking-success', extra: data);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Pay ₹${grandTotal.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
