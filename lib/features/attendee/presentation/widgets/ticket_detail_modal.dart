import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/models/app_models.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:go_router/go_router.dart';

void showTicketDetailModal(BuildContext context, BookedTicket ticket) {
  final bookingId = 'BKG-${ticket.id.substring(ticket.id.length > 8 ? ticket.id.length - 8 : 0).toUpperCase()}';
  final qrPayload = ticket.qrCode;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.92,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(width: 48, height: 6, decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(3))),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  children: [
                    // Banner
                    Container(
                      height: 160,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: NetworkImage(getEventImage(ticket.eventImageKey)),
                          fit: BoxFit.cover,
                        ),
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [Colors.black.withOpacity(0.9), Colors.transparent],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(LucideIcons.ticket, size: 10, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(ticket.ticketType, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(ticket.eventTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white, height: 1.1)),
                          ],
                        ),
                      ),
                    ),
                    
                    // Quick Meta
                    Row(
                      children: [
                        _buildMetaCard(LucideIcons.calendar, 'Date', ticket.eventDate),
                        const SizedBox(width: 8),
                        _buildMetaCard(LucideIcons.clock, 'Time', ticket.eventTime),
                        const SizedBox(width: 8),
                        _buildMetaCard(LucideIcons.mapPin, 'Venue', ticket.eventVenue),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // QR
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Text('SCAN AT ENTRY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.mutedForeground)),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                            child: QrImageView(data: qrPayload, version: QrVersions.auto, size: 176, eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black), dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black)),
                          ),
                          const SizedBox(height: 12),
                          Text(qrPayload, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Details
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow('Booking ID', bookingId),
                          _buildDetailRow('Ticket ID', ticket.id),
                          _buildDetailRow('Category', ticket.ticketType),
                          _buildDetailRow('Seats', ticket.seats.isNotEmpty ? ticket.seats.join(', ') : '—'),
                          _buildDetailRow('Quantity', '${ticket.quantity} ticket${ticket.quantity > 1 ? 's' : ''}'),
                          _buildDetailRow('Booked on', _formatDate(ticket.bookedAt)),
                          _buildDetailRow('Payment', 'Paid', isSuccess: true),
                          _buildDetailRow('Total Amount', '₹${ticket.totalPrice.toInt()}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Actions
                    Row(
                      children: [
                        _buildActionButton(context, LucideIcons.download, 'Download'),
                        const SizedBox(width: 8),
                        _buildActionButton(context, LucideIcons.share2, 'Share'),
                        const SizedBox(width: 8),
                        _buildActionButton(context, LucideIcons.calendarPlus, 'Calendar'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildActionOutlinedButton(context, LucideIcons.star, 'Write Review', () {
                          context.pop();
                          context.push('/write-review/${ticket.id}');
                        }),
                        const SizedBox(width: 8),
                        _buildActionOutlinedButton(context, LucideIcons.alertTriangle, 'Report Issue', () {
                          context.pop();
                          context.push('/dispute/${ticket.id}');
                        }, color: AppColors.destructive),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildActionOutlinedButton(context, LucideIcons.xCircle, 'Cancel Booking', () {
                          context.pop();
                          context.push('/cancel-booking/ticket/${ticket.id}');
                        }, color: AppColors.destructive),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildMetaCard(IconData icon, String title, String value) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
          Text(value, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        ],
      ),
    ),
  );
}

Widget _buildDetailRow(String label, String value, {bool isSuccess = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: AppColors.mutedForeground)),
        if (isSuccess)
          Row(
            children: [
              const Icon(LucideIcons.checkCircle2, size: 12, color: Colors.green),
              const SizedBox(width: 4),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
            ],
          )
        else
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
      ],
    ),
  );
}

Widget _buildActionButton(BuildContext context, IconData icon, String label) {
  return Expanded(
    child: ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\$label clicked')));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

Widget _buildActionOutlinedButton(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
  final c = color ?? AppColors.primary;
  return Expanded(
    child: OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: c,
        side: BorderSide(color: c.withOpacity(0.5)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

String _formatDate(String dateStr) {
  final d = DateTime.tryParse(dateStr);
  if (d == null) return dateStr;
  final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${d.day} ${months[d.month - 1]}, ${d.year}';
}
