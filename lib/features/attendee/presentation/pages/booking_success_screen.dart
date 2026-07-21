import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/mock_data.dart';

class BookingSuccessScreen extends ConsumerWidget {
  final Map<String, dynamic> bookingData;
  const BookingSuccessScreen({super.key, required this.bookingData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final ticket = state.bookedTickets.isNotEmpty ? state.bookedTickets.last : null;
    // Look up from allEvents first (handles organizer-created events), fallback to mockEvents
    final eventId = bookingData['eventId'] ?? ticket?.eventId ?? '';
    final eventFromState = state.allEvents.where((e) => e.id == eventId).toList();
    final event = eventFromState.isNotEmpty
        ? eventFromState.first
        : mockEvents.firstWhere((e) => e.id == eventId, orElse: () => mockEvents[0]);

    if (ticket == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Booking unavailable', style: TextStyle(color: AppColors.foreground))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Success icon
              Container(
                width: 96, height: 96,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                ),
                child: Icon(LucideIcons.checkCircle, size: 48, color: AppColors.primaryForeground),
              ),
              const SizedBox(height: 24),
              
              Text('Booking Confirmed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.foreground)),
              const SizedBox(height: 4),
              Text('Your tickets are ready', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
              const SizedBox(height: 24),

              // QR Code and Event Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(24)),
                child: Column(
                  children: [
                    Container(
                      width: 128, height: 128,
                      decoration: BoxDecoration(color: AppColors.foreground, borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8)),
                        alignment: Alignment.center,
                        child: Text(ticket.qrCode, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.mutedForeground)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(event.title, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 4),
                    Text('${event.date} • ${event.time}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    Text(event.venue, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    const SizedBox(height: 8),
                    Text('${ticket.seats.join(', ')} • ${ticket.ticketType}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppColors.card,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: Text('Add to Calendar', style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
                            content: Text('"${event.title}" on ${event.date} at ${event.time} has been added to your calendar.', style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Done', style: TextStyle(color: AppColors.primary)))],
                          ),
                        );
                      },
                      icon: Icon(LucideIcons.calendarPlus, size: 16, color: AppColors.foreground),
                      label: Text('Calendar', style: TextStyle(color: AppColors.foreground)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Sharing: ${event.title} on ${event.date} @ ${event.venue}'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.primary,
                        ));
                      },
                      icon: Icon(LucideIcons.share2, size: 16, color: AppColors.foreground),
                      label: Text('Share', style: TextStyle(color: AppColors.foreground)),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/tickets'),
                  icon: Icon(LucideIcons.ticket, size: 16, color: AppColors.primaryForeground),
                  label: Text('View Tickets', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => context.go('/home'),
                child: Text('Back to Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
