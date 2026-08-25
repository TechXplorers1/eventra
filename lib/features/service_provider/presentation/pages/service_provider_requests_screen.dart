import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_components.dart';
import '../../../../core/models/app_models.dart';

class ServiceProviderRequestsScreen extends ConsumerStatefulWidget {
  const ServiceProviderRequestsScreen({super.key});

  @override
  ConsumerState<ServiceProviderRequestsScreen> createState() => _ServiceProviderRequestsScreenState();
}

class _ServiceProviderRequestsScreenState extends ConsumerState<ServiceProviderRequestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final vendorId = appState.serviceProvider.vendorId.isNotEmpty ? appState.serviceProvider.vendorId : 'v1';
    
    // Service Requests
    final serviceReqs = appState.serviceRequests.where((r) => r.vendorId == vendorId || r.vendorId == null || r.vendorId!.isEmpty).toList();
    
    // Venue Requests (converted from EventData)
    final venueReqs = appState.allEventsUnfiltered.where((e) => e.linkedVenueId == vendorId).map((e) {
      return ServiceRequest(
        id: 'venue_${e.id}',
        categoryId: 'venue',
        categoryName: 'Venue Booking',
        status: e.venueStatus.toLowerCase() == 'pending' ? 'Quote Requested' : e.venueStatus, // map 'pending' to 'Quote Requested' to show in New tab
        budget: 0,
        professionals: 1,
        duration: e.time,
        notes: e.description,
        quotes: 1,
        createdAt: DateTime.now(),
        vendorId: vendorId,
        vendorName: appState.serviceProvider.businessName,
        vendorPrice: 0,
        eventId: e.id,
        eventName: e.title,
        eventDate: e.date,
        eventVenue: e.venue,
      );
    }).toList();

    final requests = [...serviceReqs, ...venueReqs];
    
    final pending = requests.where((r) => r.status == 'Quote Requested').toList();
    final active = requests.where((r) => r.status == 'Confirmed' || r.status == 'Vendor Selected').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const EvBackButton(),
        title: Text('Booking Requests', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.mutedForeground,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'New (${pending.length})'),
            Tab(text: 'Active (${active.length})'),
            Tab(text: 'Direct Bookings'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildRequestsList(pending, true),
              _buildRequestsList(active, false),
              _buildDirectBookingsList(appState.serviceBookings.where((b) => b.vendorId == vendorId).toList()),
            ],
          ),
          const BottomNav(),
        ],
      ),
    );
  }


  void _showQuoteDialog(BuildContext context, ServiceRequest req) {
    final priceCtrl = TextEditingController(text: req.budget.toInt().toString());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Send Quote', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                GestureDetector(onTap: () => Navigator.pop(context), child: Icon(LucideIcons.x, color: AppColors.mutedForeground)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Client is requesting ${req.categoryName} for their event. The suggested budget is ₹${req.budget.toInt()}.', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
            
            if (req.eventDate.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.warning.withAlpha(20), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warning.withAlpha(50))),
                child: Row(children: [
                  Icon(LucideIcons.calendarOff, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${req.eventDate} will be auto-blocked in your calendar upon submission.', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600))),
                ]),
              ),
            ],
            
            const SizedBox(height: 24),
            Text('Your Price (₹)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
            const SizedBox(height: 8),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.foreground, fontSize: 28, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w800),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceCtrl.text) ?? req.budget;
                  final notifier = ref.read(appProvider.notifier);
                  notifier.acceptServiceRequest(
                    req.id,
                    ref.read(appProvider).serviceProvider.businessName,
                    price,
                  );
                  // Auto-block the event date on calendar
                  if (req.eventDate.isNotEmpty) {
                    try {
                      final dateKey = _normaliseDateKey(req.eventDate);
                      if (dateKey != null &&
                          !ref.read(appProvider).blockedDates.contains(dateKey)) {
                        notifier.toggleBlockDate(dateKey);
                      }
                    } catch (_) {}
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Quote of ₹${price.toInt()} submitted!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Confirm Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryForeground)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Converts a date string (various formats) to 'yyyy-MM-dd' key.
  String? _normaliseDateKey(String raw) {
    raw = raw.trim();
    // Already in yyyy-MM-dd
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) return raw;
    // e.g. "Mar 15, 2026" or "Mar 15 2026"
    const months = {
      'jan': '01', 'feb': '02', 'mar': '03', 'apr': '04',
      'may': '05', 'jun': '06', 'jul': '07', 'aug': '08',
      'sep': '09', 'oct': '10', 'nov': '11', 'dec': '12',
    };
    final m = RegExp(r'([A-Za-z]{3})\s+(\d{1,2}),?\s+(\d{4})').firstMatch(raw);
    if (m != null) {
      final mo = months[m.group(1)!.toLowerCase()];
      if (mo != null) {
        final day = m.group(2)!.padLeft(2, '0');
        return '${m.group(3)}-$mo-$day';
      }
    }
    return null;
  }


  Widget _buildRequestsList(List<ServiceRequest> list, bool isPending) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 64, color: AppColors.mutedForeground.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No requests found', style: TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final req = list[index];
        return _buildRequestCard(req, isPending);
      },
    );
  }

  Widget _buildDirectBookingsList(List<ServiceBooking> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.inbox, size: 64, color: AppColors.mutedForeground.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('No direct bookings yet', style: TextStyle(color: AppColors.mutedForeground, fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 100),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final b = list[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary, width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.purple.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                      child: Text('Attendee Booking', style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        b.status,
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('${b.serviceName} • ${b.packageName}', style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(b.eventName.isNotEmpty ? b.eventName : 'Event Details TBD', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badge(LucideIcons.calendar, b.eventDate.isNotEmpty ? b.eventDate : 'TBD'),
                    _badge(LucideIcons.indianRupee, 'Paid: ₹${b.total.toInt()}'),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.foreground, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildRequestCard(ServiceRequest req, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPending ? AppColors.border : AppColors.primary, width: isPending ? 1 : 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.blue.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                      child: Text('Organizer Request', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? AppColors.warning.withAlpha(25) : AppColors.success.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        req.status,
                        style: TextStyle(
                          color: isPending ? AppColors.warning : AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(req.categoryName, style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(req.eventName.isNotEmpty ? req.eventName : 'Event Details TBD', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badge(LucideIcons.calendar, req.eventDate.isNotEmpty ? req.eventDate : 'TBD'),
                    _badge(LucideIcons.mapPin, req.eventVenue.isNotEmpty ? req.eventVenue : 'Location TBD'),
                    if (!req.id.startsWith('venue_'))
                      _badge(LucideIcons.indianRupee, 'Budget: ₹${req.budget.toInt()}'),
                  ],
                ),
              ],
            ),
          ),
          if (isPending)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        if (req.id.startsWith('venue_')) {
                          final eventId = req.id.replaceFirst('venue_', '');
                          final event = ref.read(appProvider).allEventsUnfiltered.firstWhere((e) => e.id == eventId);
                          ref.read(appProvider.notifier).updateEvent(event.copyWith(venueStatus: 'rejected'));
                        } else {
                          ref.read(appProvider.notifier).declineServiceRequest(req.id);
                        }
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Request declined'),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Decline', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (req.id.startsWith('venue_')) {
                          final eventId = req.id.replaceFirst('venue_', '');
                          final event = ref.read(appProvider).allEventsUnfiltered.firstWhere((e) => e.id == eventId);
                          ref.read(appProvider.notifier).updateEvent(event.copyWith(venueStatus: 'confirmed'));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text('Venue booking confirmed!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ));
                        } else {
                          _showQuoteDialog(context, req);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(req.id.startsWith('venue_') ? 'Accept Booking' : 'Submit Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryForeground)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
