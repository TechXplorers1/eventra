import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

// PaymentScreen MUST keep Riverpod to save the ticket via appProvider.notifier
// But we fix the body layout: use AppBar + ListView (not SafeArea+Column+Expanded)
class PaymentScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> bookingData;
  const PaymentScreen({super.key, required this.bookingData});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  static const _bg     = Color(0xFF09090B);
  static const _card   = Color(0xFF121214);
  static const _purple = Color(0xFF9B66E0);
  static const _border = Color(0xFF27272A);
  static const _muted  = Color(0xFFA1A1AA);

  String _selectedMethod = 'upi';

  final _paymentMethods = const [
    {'id': 'upi',        'label': 'UPI',               'desc': 'Google Pay, PhonePe, Paytm'},
    {'id': 'card',       'label': 'Credit/Debit Card',  'desc': 'Visa, Mastercard, RuPay'},
    {'id': 'netbanking', 'label': 'Net Banking',         'desc': 'All major banks'},
    {'id': 'wallet',     'label': 'Wallets',             'desc': 'Paytm, Amazon Pay'},
  ];

  @override
  Widget build(BuildContext context) {
    final data       = widget.bookingData;
    final grandTotal = data['grandTotal'] as double;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Payment',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Icon(Icons.lock_rounded, size: 14, color: Colors.greenAccent),
                const SizedBox(width: 4),
                const Text('Secure', style: TextStyle(fontSize: 12, color: Colors.greenAccent)),
              ],
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Amount due ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9B66E0), Color(0xFFB48CE8)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Amount Due', style: TextStyle(fontSize: 12, color: Colors.white70)),
                    Text('₹${grandTotal.toInt()}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                  ],
                ),
                const Icon(Icons.payment_rounded, size: 48, color: Colors.white30),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const Text('Select Payment Method',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),

          // ── Payment method options ─────────────────────────────────
          ...['upi', 'card', 'netbanking', 'wallet'].map((id) {
            final method = _paymentMethods.firstWhere((m) => m['id'] == id);
            final isSelected = _selectedMethod == id;
            final icon = {
              'upi': Icons.phone_android_rounded,
              'card': Icons.credit_card_rounded,
              'netbanking': Icons.account_balance_rounded,
              'wallet': Icons.account_balance_wallet_rounded,
            }[id]!;

            return GestureDetector(
              onTap: () => setState(() => _selectedMethod = id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? _purple.withAlpha(30) : _card,
                  border: Border.all(
                    color: isSelected ? _purple.withAlpha(120) : _border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: isSelected ? _purple : const Color(0xFF27272A),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 20, color: isSelected ? Colors.white : _muted),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(method['label']!,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text(method['desc']!,
                            style: const TextStyle(fontSize: 11, color: Colors.white54)),
                        ],
                      ),
                    ),
                    Container(
                      width: 20, height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? _purple : Colors.transparent,
                        border: Border.all(color: isSelected ? _purple : _muted, width: 2),
                      ),
                      child: isSelected
                        ? const Center(child: Icon(Icons.check, size: 12, color: Colors.white))
                        : null,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // ── Pay button ─────────────────────────────────────────────
          GestureDetector(
            onTap: () {
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
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF9B66E0), Color(0xFFB48CE8)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _purple.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              alignment: Alignment.center,
              child: Text('Pay ₹${grandTotal.toInt()}  →',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 16),

          // Secure notice
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_rounded, size: 12, color: Colors.white38),
              SizedBox(width: 6),
              Text('256-bit SSL encrypted · PCI DSS compliant',
                style: TextStyle(fontSize: 11, color: Colors.white38)),
            ],
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
