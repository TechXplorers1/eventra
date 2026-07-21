import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/mock_data.dart';

class OrderSummaryScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const OrderSummaryScreen({super.key, required this.bookingData});

  @override
  State<OrderSummaryScreen> createState() => _OrderSummaryScreenState();
}

class _OrderSummaryScreenState extends State<OrderSummaryScreen> {
  String _coupon = '';
  bool _couponApplied = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.bookingData;
    final totalPrice = data['totalPrice'] as double;
    final platformFee = totalPrice * 0.02;
    final tax = totalPrice * 0.18;
    final discount = _couponApplied ? totalPrice * 0.10 : 0.0;
    final grandTotal = totalPrice + platformFee + tax - discount;

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
                  Text('Order Summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  // Event Card
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.network(getEventImage(data['eventImageKey']), height: 144, width: double.infinity, fit: BoxFit.cover),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(data['eventTitle'], style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(LucideIcons.calendar, size: 12, color: AppColors.mutedForeground),
                                  const SizedBox(width: 4),
                                  Text('${data['eventDate']} • ${data['eventTime']}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(LucideIcons.mapPin, size: 12, color: AppColors.mutedForeground),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text('${data['eventVenue']}, ${data['eventCity']}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Ticket Details
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ticket Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 8),
                        _buildRow('Ticket Category', data['sectionName']),
                        _buildRow('Selected Seats', (data['seats'] as List).join(', ')),
                        _buildRow('Quantity', data['seatCount'].toString()),
                        _buildRow('Price per Ticket', '₹${(data['pricePerSeat'] as double).toInt()}'),
                      ],
                    ),
                  ),

                  // Coupon
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.tag, size: 14, color: AppColors.mutedForeground),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        onChanged: (val) => setState(() => _coupon = val),
                                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                                        decoration: InputDecoration(
                                          hintText: 'Enter coupon code',
                                          hintStyle: TextStyle(color: AppColors.mutedForeground),
                                          border: InputBorder.none,
                                          isDense: true,
                                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                if (_coupon.isNotEmpty) setState(() => _couponApplied = true);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text('Apply', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        if (_couponApplied)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('✓ 10% discount applied!', style: TextStyle(fontSize: 12, color: Colors.green)),
                          ),
                      ],
                    ),
                  ),

                  // Price breakdown
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        _buildRow('Subtotal', '₹${totalPrice.toInt()}'),
                        _buildRow('Platform Fee', '₹${platformFee.toInt()}'),
                        _buildRow('Tax (18% GST)', '₹${tax.toInt()}'),
                        if (discount > 0) _buildRow('Discount', '-₹${discount.toInt()}', isGreen: true),
                        const SizedBox(height: 8),
                        Divider(color: AppColors.border),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Total Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                            Text('₹${grandTotal.toInt()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  ElevatedButton(
                    onPressed: () {
                      final payload = Map<String, dynamic>.from(data);
                      payload['platformFee'] = platformFee;
                      payload['tax'] = tax;
                      payload['discount'] = discount;
                      payload['grandTotal'] = grandTotal;
                      context.push('/payment', extra: payload);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Proceed to Payment — ₹${grandTotal.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
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

  Widget _buildRow(String label, String value, {bool isGreen = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isGreen ? Colors.green : AppColors.foreground)),
        ],
      ),
    );
  }
}
