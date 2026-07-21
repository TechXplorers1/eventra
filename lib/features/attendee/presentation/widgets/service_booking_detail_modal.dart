import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/data/services_marketplace_data.dart';

void showServiceBookingDetailModal(BuildContext context, ServiceBooking booking) {
  final svc = findUserService(booking.serviceId);
  final icon = svc?.icon ?? LucideIcons.sparkles;
  bool isExpanded = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)]), // gradient-primary equivalent
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(booking.serviceName.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.white.withOpacity(0.8))),
                              Text(booking.vendorName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
                                    child: Text(booking.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(booking.status))),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(booking.packageName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.9)))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: !isExpanded
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSummaryRow(LucideIcons.briefcase, 'Service', '${booking.serviceName} • ${booking.packageName}'),
                                const SizedBox(height: 16),
                                _buildSummaryRow(LucideIcons.calendar, 'Event Date', '${booking.eventDate} • ${booking.startTime}'),
                                const SizedBox(height: 16),
                                _buildSummaryRow(LucideIcons.receipt, 'Amount', '₹${booking.total.toInt()}', highlight: true),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => setState(() => isExpanded = true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text('View Details', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(width: 4),
                                        Icon(LucideIcons.chevronRight, size: 16, color: AppColors.primaryForeground),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildGroup('Event Details', [
                                  _buildDetailRow('Event Name', booking.eventName, icon: LucideIcons.sparkles),
                                  _buildDetailRow('Event Type', booking.eventType, icon: LucideIcons.briefcase),
                                  _buildDetailRow('Date', booking.eventDate, icon: LucideIcons.calendar),
                                  _buildDetailRow('Time', '${booking.startTime} – ${booking.endTime}', icon: LucideIcons.clock),
                                  _buildDetailRow('Venue', '${booking.venueName}, ${booking.city}', icon: LucideIcons.mapPin),
                                  _buildDetailRow('Guests', '${booking.guests}', icon: LucideIcons.users),
                                ]),
                                const SizedBox(height: 16),
                                _buildGroup('Booking & Payment', [
                                  _buildDetailRow('Booking ID', booking.orderNumber, mono: true),
                                  _buildDetailRow('Payment ID', 'PAY-${booking.id.substring(booking.id.length > 8 ? booking.id.length - 8 : 0).toUpperCase()}', mono: true),
                                  _buildDetailRow('Payment Method', booking.paymentMethod),
                                  _buildDetailRow('Booked On', _formatDate(booking.bookedAt)),
                                  _buildDetailRow('Service Price', '₹${booking.servicePrice.toInt()}'),
                                  _buildDetailRow('Platform Fee', '₹${booking.platformFee.toInt()}'),
                                  _buildDetailRow('Taxes', '₹${booking.taxes.toInt()}'),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text('Amount Paid', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                        Text('₹${booking.total.toInt()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ]),
                                if (booking.specialRequirements.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  _buildGroup('Special Requirements', [
                                    Text(booking.specialRequirements, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                  ]),
                                ],
                                const SizedBox(height: 16),
                                _buildGroup('Contact Information', [
                                  _buildDetailRow('Provider', booking.vendorName, icon: LucideIcons.user),
                                  _buildDetailRow('Support', '+91 98XXX 12345', icon: LucideIcons.phone),
                                ]),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Provider will contact you shortly'))),
                                        icon: Icon(LucideIcons.messageCircle, size: 14, color: AppColors.foreground),
                                        label: Text('Contact', style: TextStyle(fontSize: 12, color: AppColors.foreground)),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invoice download started'))),
                                        icon: Icon(LucideIcons.download, size: 14, color: AppColors.primaryForeground),
                                        label: Text('Invoice', style: TextStyle(fontSize: 12, color: AppColors.primaryForeground)),
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Close', style: TextStyle(color: AppColors.foreground)),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Color _getStatusColor(String status) {
  switch (status) {
    case 'Pending': return Colors.amber;
    case 'Confirmed': return AppColors.primary;
    case 'In Progress': return Colors.blue;
    case 'Completed': return Colors.green;
    case 'Cancelled': return Colors.red;
    default: return AppColors.primary;
  }
}

Widget _buildSummaryRow(IconData icon, String label, String value, {bool highlight = false}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
      Expanded(
        child: Text(
          value, 
          textAlign: TextAlign.right, 
          style: TextStyle(fontSize: highlight ? 16 : 14, fontWeight: FontWeight.bold, color: highlight ? AppColors.primary : AppColors.foreground),
        ),
      ),
    ],
  );
}

Widget _buildGroup(String title, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.mutedForeground)),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ],
  );
}

Widget _buildDetailRow(String label, String value, {IconData? icon, bool mono = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: AppColors.primary),
              const SizedBox(width: 6),
            ],
            Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, fontFamily: mono ? 'monospace' : null, color: AppColors.foreground),
          ),
        ),
      ],
    ),
  );
}

String _formatDate(String dateStr) {
  final d = DateTime.tryParse(dateStr);
  if (d == null) return dateStr;
  return '${d.day}/${d.month}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}
