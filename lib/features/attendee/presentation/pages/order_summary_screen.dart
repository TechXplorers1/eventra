import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/data/mock_data.dart';

class OrderSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const OrderSummaryScreen({super.key, required this.bookingData});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  static const _bg   = Color(0xFF0A0A0F);
  static const _card = Color(0xFF18181B);
  static const _muted = Color(0xFF71717A);
  static const _purple = Color(0xFF7C3AED);
  static const _border = Color(0xFF27272A);

  String _coupon = '';
  bool _couponApplied = false;

  @override
  Widget build(BuildContext context) {
    final data        = widget.bookingData;
    final totalPrice  = data['totalPrice'] as double;
    final platformFee = totalPrice * 0.02;
    final tax         = totalPrice * 0.18;
    final discount    = _couponApplied ? totalPrice * 0.10 : 0.0;
    final grandTotal  = totalPrice + platformFee + tax - discount;
    final imageKey    = data['eventImageKey'] as String? ?? 'concert';
    // Category color from section
    const catColor    = _purple;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: const Text('Order Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Event Banner (gradient, no network image) ──────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [catColor.withAlpha(200), catColor.withAlpha(80)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['eventTitle'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.calendar_today_rounded, size: 13, color: Colors.white60),
                  const SizedBox(width: 6),
                  Text('${data['eventDate']} · ${data['eventTime']}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70)),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.location_on_rounded, size: 13, color: Colors.white60),
                  const SizedBox(width: 6),
                  Expanded(child: Text('${data['eventVenue']}, ${data['eventCity']}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70))),
                ]),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Ticket Details ─────────────────────────────────────────
          _card_(
            title: 'Ticket Details',
            icon: Icons.confirmation_number_rounded,
            child: Column(
              children: [
                _row('Category', data['sectionName'] ?? ''),
                _row('Seats', (data['seats'] as List?)?.join(', ') ?? '—'),
                _row('Quantity', '${data['seatCount']}'),
                _row('Price / Seat', '₹${(data['pricePerSeat'] as double).toInt()}'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Coupon ─────────────────────────────────────────────────
          _card_(
            title: 'Coupon Code',
            icon: Icons.local_offer_rounded,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        enabled: !_couponApplied,
                        onChanged: (v) => setState(() => _coupon = v),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Enter code (try SAVE10)',
                          hintStyle: TextStyle(color: _muted),
                          filled: true,
                          fillColor: _bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: _border),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _couponApplied
                        ? () => setState(() { _couponApplied = false; _coupon = ''; })
                        : () { if (_coupon.isNotEmpty) setState(() => _couponApplied = true); },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                        decoration: BoxDecoration(
                          color: _couponApplied ? const Color(0xFF166534) : _purple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_couponApplied ? 'Remove' : 'Apply',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                  ],
                ),
                if (_couponApplied) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF166534).withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF166534).withAlpha(80)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 16),
                        SizedBox(width: 8),
                        Text('10% discount applied!',
                          style: TextStyle(fontSize: 13, color: Colors.greenAccent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Price Breakdown ────────────────────────────────────────
          _card_(
            title: 'Price Breakdown',
            icon: Icons.receipt_long_rounded,
            child: Column(
              children: [
                _row('Subtotal', '₹${totalPrice.toInt()}'),
                _row('Platform Fee (2%)', '₹${platformFee.toInt()}'),
                _row('Tax (18% GST)', '₹${tax.toInt()}'),
                if (discount > 0) _row('Discount', '−₹${discount.toInt()}', green: true),
                const SizedBox(height: 10),
                const Divider(color: _border),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Grand Total',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('₹${grandTotal.toInt()}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _purple)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── Proceed Button ─────────────────────────────────────────
          GestureDetector(
            onTap: () {
              final payload = Map<String, dynamic>.from(data);
              payload['platformFee'] = platformFee;
              payload['tax'] = tax;
              payload['discount'] = discount;
              payload['grandTotal'] = grandTotal;
              context.push('/payment', extra: payload);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFF9333EA)]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: _purple.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              alignment: Alignment.center,
              child: Text('Proceed to Payment — ₹${grandTotal.toInt()}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _card_({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: _purple),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool green = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white54)),
          Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: green ? Colors.greenAccent : Colors.white)),
        ],
      ),
    );
  }
}
