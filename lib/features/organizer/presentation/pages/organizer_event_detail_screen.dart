import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/data/venues_data.dart';
import '../../../../core/data/service_providers_data.dart';
import '../../../../core/models/app_models.dart';

class OrganizerEventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const OrganizerEventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<OrganizerEventDetailScreen> createState() => _OrganizerEventDetailScreenState();
}

class _OrganizerEventDetailScreenState extends ConsumerState<OrganizerEventDetailScreen> {
  String _tab = 'venue';

  List<Map<String, dynamic>> get _tabs => [
    {'id': 'venue', 'label': 'Venue', 'icon': LucideIcons.mapPin},
    {'id': 'services', 'label': 'Services', 'icon': LucideIcons.briefcase},
    {'id': 'info', 'label': 'Info', 'icon': LucideIcons.info},
    if (_visibility == 'private')
      {'id': 'invites', 'label': 'Invites', 'icon': LucideIcons.mail}
    else
      {'id': 'tickets', 'label': 'Tickets', 'icon': LucideIcons.ticket},
    {'id': 'overview', 'label': 'Overview', 'icon': LucideIcons.layoutGrid},
  ];

  late TextEditingController _titleCtrl;
  late TextEditingController _dateCtrl;
  late TextEditingController _timeCtrl;
  late TextEditingController _descCtrl;
  String _category = 'Music';
  String _visibility = 'public';
  
  bool _initialized = false;
  EventData? _currentEvent;
  SeatSection? _activeSeatSection;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _dateCtrl = TextEditingController();
    _timeCtrl = TextEditingController();
    _descCtrl = TextEditingController();
  }

  void _initData(EventData event) {
    if (_initialized) return;
    _currentEvent = event;
    _titleCtrl.text = event.title;
    _dateCtrl.text = event.date;
    _timeCtrl.text = event.time;
    _descCtrl.text = event.description;
    _category = event.category;
    _visibility = event.visibility;
    _initialized = true;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _saveInfoChanges() {
    if (_currentEvent == null) return;
    final updated = _currentEvent!.copyWith(
      title: _titleCtrl.text,
      description: _descCtrl.text,
      category: _category,
      visibility: _visibility,
    );
    ref.read(appProvider.notifier).updateEvent(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Event info updated successfully!'), backgroundColor: Colors.green),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'quote requested': return Colors.amber;
      case 'quotes received': return Colors.blue;
      case 'vendor selected': return Colors.purpleAccent;
      case 'confirmed': return Colors.greenAccent;
      case 'rejected':
      case 'cancelled': return Colors.redAccent;
      default: return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final event = appState.allEventsUnfiltered.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => appState.allEventsUnfiltered.isNotEmpty ? appState.allEventsUnfiltered[0] : mockEvents[0],
    );
    
    // Initialize form controllers on first build
    _initData(event);

    final serviceRequests = appState.serviceRequests
        .where((r) => r.eventId == widget.eventId || r.eventId.isEmpty)
        .toList();

    final totalSpend = serviceRequests.fold<double>(0, (sum, r) => sum + (r.vendorPrice ?? 0));
    final activeVendors = serviceRequests.where((r) => r.status == 'Confirmed').length;
    final pending = serviceRequests.where((r) => r.status == 'Quote Requested' || r.status == 'Quotes Received').length;

    final eventTickets = appState.bookedTickets.where((t) => t.eventId == widget.eventId).toList();
    final ticketRevenue = eventTickets.fold<double>(0.0, (sum, t) => sum + t.totalPrice);
    final ticketsSold = eventTickets.fold<int>(0, (sum, t) => sum + t.quantity);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(event),
            _buildTabs(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_tab == 'venue') _buildVenueTab(event),
                  if (_tab == 'services') _buildServicesTab(serviceRequests, totalSpend, pending),
                  if (_tab == 'info') _buildInfoTab(),
                  if (_tab == 'tickets') _buildTicketsTab(eventTickets, event),
                  if (_tab == 'invites') _buildInvitesTab(appState.invitations.where((i) => i.eventId == event.id).toList(), event),
                  if (_tab == 'overview') _buildOverviewTab(ticketsSold, ticketRevenue, activeVendors, pending, totalSpend),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildHeader(EventData event) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                Future.microtask(() => context.go('/'));
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('${event.date} • ${event.venue}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: _tabs.map((t) {
          final isActive = _tab == t['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => setState(() => _tab = t['id'] as String),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primary : AppColors.secondary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(t['icon'] as IconData, size: 12, color: isActive ? AppColors.primaryForeground : AppColors.foreground),
                    const SizedBox(width: 6),
                    Text(t['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? AppColors.primaryForeground : AppColors.foreground)),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVenueTab(EventData event) {
    final statusColor = _getStatusColor(event.venueStatus);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current Venue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(event.venue, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text(event.venueStatus.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(event.city, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildField('Date', _dateCtrl, 'e.g. Apr 20, 2026', readOnly: true, onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2050),
                      );
                      if (date != null) {
                        _dateCtrl.text = DateFormat('MMM d, yyyy').format(date);
                        final updated = event.copyWith(date: _dateCtrl.text);
                        ref.read(appProvider.notifier).updateEvent(updated);
                      }
                    }),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField('Time', _timeCtrl, 'e.g. 7:00 PM', readOnly: true, onTap: () async {
                      final startTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        helpText: 'Select Start Time',
                      );
                      if (startTime != null && mounted) {
                        final endTime = await showTimePicker(
                          context: context,
                          initialTime: startTime,
                          helpText: 'Select End Time',
                        );
                        if (endTime != null && mounted) {
                          _timeCtrl.text = '${startTime.format(context)} - ${endTime.format(context)}';
                          final updated = event.copyWith(time: _timeCtrl.text);
                          ref.read(appProvider.notifier).updateEvent(updated);
                        }
                      }
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showVenuePicker(event),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.foreground,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Change Venue', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVenuePicker(EventData event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Select New Venue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(LucideIcons.x, color: AppColors.foreground),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: mockVenues.length,
                    itemBuilder: (context, index) {
                      final venue = mockVenues[index];
                      return _buildVenueCard(venue, event, context);
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildVenueCard(VenueData venue, EventData event, BuildContext modalContext) {
    final selected = event.linkedVenueId == venue.id;
    return GestureDetector(
      onTap: () => _showVenuePortfolio(venue, event, modalContext),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            child: Image.network(venue.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(height: 120, color: AppColors.secondary, child: Icon(LucideIcons.building2, color: AppColors.mutedForeground, size: 36)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(venue.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground))),
                if (selected) Icon(LucideIcons.checkCircle2, size: 20, color: AppColors.primary),
              ]),
              const SizedBox(height: 3),
              Row(children: [Icon(LucideIcons.mapPin, size: 11, color: AppColors.mutedForeground), const SizedBox(width: 4), Text('${venue.address}, ${venue.city}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))]),
              const SizedBox(height: 8),
              Wrap(spacing: 6, runSpacing: 4, children: [
                _venueBadge(LucideIcons.users, '${venue.capacity} guests'),
                _venueBadge(LucideIcons.star, '${venue.rating}'),
                _venueBadge(LucideIcons.indianRupee, '₹${(venue.pricePerDay / 1000).toStringAsFixed(0)}K/day'),
              ]),
              if (venue.amenities.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(venue.amenities.take(3).join(' · '), style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _venueBadge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.foreground, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  void _showVenuePortfolio(VenueData venue, EventData event, BuildContext modalContext) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    child: Image.network(
                      venue.imageUrl, 
                      height: 250, 
                      width: double.infinity, 
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(height: 250, color: AppColors.secondary, child: Icon(LucideIcons.building2, color: AppColors.mutedForeground, size: 48)),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(LucideIcons.x, size: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(venue.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 14, color: AppColors.mutedForeground),
                        const SizedBox(width: 6),
                        Expanded(child: Text('${venue.address}, ${venue.city}', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground))),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _venueBadge(LucideIcons.users, '${venue.capacity} guests'),
                        _venueBadge(LucideIcons.star, '${venue.rating}'),
                        _venueBadge(LucideIcons.indianRupee, '₹${(venue.pricePerDay / 1000).toStringAsFixed(0)}K/day'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 10),
                    Text(venue.description, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
                    const SizedBox(height: 24),
                    Text('Amenities', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: venue.amenities.map((a) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                        child: Text(a, style: TextStyle(fontSize: 12, color: AppColors.foreground, fontWeight: FontWeight.w500)),
                      )).toList(),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final updatedEvent = event.copyWith(
                      venue: venue.name,
                      city: venue.city,
                      linkedVenueId: venue.id,
                      venueStatus: 'Pending',
                    );
                    ref.read(appProvider.notifier).updateEvent(updatedEvent);
                    Navigator.pop(context); // close portfolio
                    Navigator.pop(modalContext); // close picker list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Venue change requested successfully!'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Confirm Venue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showServiceOptionsPicker() {
    final _serviceOptions = ['Photography', 'Catering', 'DJ / Sound', 'Decoration', 'Security', 'Videography', 'MC / Host', 'Stage & Lighting'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Request New Service', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              const SizedBox(height: 16),
              Wrap(spacing: 10, runSpacing: 10, children: _serviceOptions.map((s) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _showProvidersModal(s);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border, width: 1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                  ),
                );
              }).toList()),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showProvidersModal(String category) {
    final providers = mockServiceProviders.where((p) => p.serviceCategory == category).toList();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$category Providers', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    GestureDetector(onTap: () => Navigator.pop(context), child: Icon(LucideIcons.x, color: AppColors.mutedForeground)),
                  ],
                ),
              ),
              Divider(color: AppColors.border, height: 1),
              Expanded(
                child: providers.isEmpty 
                  ? Center(child: Text('No providers found in this category.', style: TextStyle(color: AppColors.mutedForeground)))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: providers.length,
                      itemBuilder: (context, index) {
                        final p = providers[index];
                        return GestureDetector(
                          onTap: () => _showProviderPortfolio(p, context),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 26,
                                  backgroundColor: AppColors.secondary,
                                  child: Icon(LucideIcons.user, color: AppColors.mutedForeground),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.businessName, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                      const SizedBox(height: 4),
                                      Text('${p.fullName} • ⭐ ${p.rating}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                      const SizedBox(height: 6),
                                      Text('From ₹${p.startingPrice}', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                                Icon(LucideIcons.chevronRight, size: 20, color: AppColors.mutedForeground),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProviderPortfolio(ServiceProviderProfile provider, BuildContext modalContext) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Stack(
                  children: [
                    Center(child: Icon(LucideIcons.image, size: 48, color: AppColors.mutedForeground)),
                    Positioned(
                      top: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(LucideIcons.x, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Text(provider.fullName[0], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(provider.businessName, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              const SizedBox(height: 4),
                              Text('${provider.serviceCategory} • ${provider.experienceYears} exp', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 10),
                    Text(provider.bio, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Starting from', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                              const SizedBox(height: 4),
                              Text('₹${provider.startingPrice}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(LucideIcons.star, size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${provider.rating}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              Text(' (${provider.totalGigs} jobs)', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border(top: BorderSide(color: AppColors.border)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final req = ServiceRequest(
                      id: 'SR${DateTime.now().millisecondsSinceEpoch}',
                      eventId: widget.eventId,
                      eventName: widget.eventId, // Mock data
                      eventDate: '',
                      eventVenue: '',
                      categoryId: provider.serviceCategory, // Mock ID
                      vendorId: provider.vendorId,
                      categoryName: provider.serviceCategory,
                      vendorName: provider.businessName,
                      vendorPrice: provider.startingPrice.toDouble(),
                      status: 'Quote Requested',
                      budget: provider.startingPrice.toDouble(),
                      professionals: 1,
                      duration: '1 Day',
                      notes: '',
                      quotes: 1,
                      createdAt: DateTime.now(),
                    );
                    ref.read(appProvider.notifier).addServiceRequest(req);
                    Navigator.pop(context); // close portfolio
                    Navigator.pop(modalContext); // close picker list
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service requested successfully!'), backgroundColor: Colors.green),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Request Quote', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServicesTab(List<ServiceRequest> serviceRequests, double totalSpend, int pending) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildMini('Services', serviceRequests.length.toString())),
            const SizedBox(width: 8),
            Expanded(child: _buildMini('Spend', '₹${totalSpend.toStringAsFixed(0)}')),
            const SizedBox(width: 8),
            Expanded(child: _buildMini('Pending', pending.toString())),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => _showServiceOptionsPicker(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryForeground,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('+ Request New Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        if (serviceRequests.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No services added yet.', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
          )
        else
          ...serviceRequests.map((r) {
            final statusColor = _getStatusColor(r.status);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.briefcase, size: 14, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(r.categoryName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                        child: Text(r.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                      ),
                    ],
                  ),
                  if (r.vendorName != null) ...[
                    const SizedBox(height: 12),
                    Text(r.vendorName!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    Text('₹${r.vendorPrice?.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Request functionality coming soon!')));
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.foreground, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.edit2, size: 11), const SizedBox(width: 4), const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => ref.read(appProvider.notifier).removeServiceRequest(r.id),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.x, size: 11), const SizedBox(width: 4), const Text('Cancel Request', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildInfoTab() {
    final categories = ['Music', 'Sports', 'Comedy', 'Nightlife', 'Arts', 'Performances'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildField('Event Title', _titleCtrl, 'e.g. Coldplay After-Party'),
        const SizedBox(height: 16),
        Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: categories.map((cat) {
            final isSelected = _category == cat;
            return InkWell(
              onTap: () => setState(() => _category = cat),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.card,
                  border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(cat, style: TextStyle(fontSize: 12, color: isSelected ? AppColors.primaryForeground : AppColors.foreground, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _buildField('Description', _descCtrl, 'Tell attendees about the event...', maxLines: 4),
        const SizedBox(height: 16),
        Text('Visibility', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _buildToggleBtn('Public', _visibility == 'public', () => setState(() => _visibility = 'public'))),
            const SizedBox(width: 10),
            Expanded(child: _buildToggleBtn('Private', _visibility == 'private', () => setState(() => _visibility = 'private'))),
          ],
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _saveInfoChanges,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildTicketsTab(List<BookedTicket> eventTickets, EventData event) {
    if (event.seatingLayouts.isNotEmpty) {
      if (_activeSeatSection == null) {
        // Initialize with first section
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _activeSeatSection = event.seatingLayouts.first);
        });
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: event.seatingLayouts.map((sec) {
                final isSelected = _activeSeatSection?.id == sec.id;
                return GestureDetector(
                  onTap: () => setState(() => _activeSeatSection = sec),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Color(sec.colorHex).withOpacity(0.2) : AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? Color(sec.colorHex) : AppColors.border),
                    ),
                    child: Text(sec.name, style: TextStyle(color: isSelected ? Color(sec.colorHex) : AppColors.mutedForeground, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          if (_activeSeatSection != null)
            _buildOrganizerSeatMap(_activeSeatSection!, eventTickets, event),
          const SizedBox(height: 32),
          Text('Booked Tickets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 16),
        ],
      );
    }

    if (eventTickets.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text(
          'No tickets booked yet for this event.',
          style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
        )),
      );
    }
    return Column(
      children: eventTickets.map((t) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(LucideIcons.ticket, size: 16, color: AppColors.primary)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.ticketType, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  Text('Qty: ${t.quantity} • ₹${t.totalPrice.toInt()}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                  if (t.seats.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('Seats: ${t.seats.join(", ")}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
                    ),
                  const SizedBox(height: 4),
                  Text('QR: ${t.qrCode}', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground.withOpacity(0.6))),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('Paid', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
            ),
          ],
        ),
      )).toList(),
    );
  }

  void _toggleBlockSeat(SeatSection sec, String seatId, EventData event) {
    // Modify the disabledSeats list in the section
    final newDisabledSeats = List<String>.from(sec.disabledSeats);
    if (newDisabledSeats.contains(seatId)) {
      newDisabledSeats.remove(seatId);
    } else {
      newDisabledSeats.add(seatId);
    }

    final newSection = SeatSection(
      id: sec.id,
      name: sec.name,
      rows: sec.rows,
      seatsPerRow: sec.seatsPerRow,
      price: sec.price,
      colorHex: sec.colorHex,
      disabledSeats: newDisabledSeats,
      available: sec.available,
    );

    final newLayouts = event.seatingLayouts.map((s) => s.id == sec.id ? newSection : s).toList();
    final updatedEvent = event.copyWith(seatingLayouts: newLayouts);

    ref.read(appProvider.notifier).updateEvent(updatedEvent);
    
    // Update local state to reflect UI changes immediately
    setState(() {
      _activeSeatSection = newSection;
    });
  }

  Widget _buildOrganizerSeatMap(SeatSection sec, List<BookedTicket> eventTickets, EventData event) {
    final sectionColor = Color(sec.colorHex);
    final bookedSeats = <String>{};
    for (var t in eventTickets) {
      if (t.ticketType == sec.name) {
        bookedSeats.addAll(t.seats);
      }
    }

    return Column(
      children: [
        // Legend
        Container(
          color: AppColors.card,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildLegendItem('Available', AppColors.border, Colors.white54),
              _buildLegendItem('Booked', sectionColor, Colors.white),
              _buildLegendItem('Blocked (Tap)', const Color(0xFF27272A), const Color(0xFF3F3F46)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Seat Grid
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(sec.rows, (r) {
              final rowLetter = String.fromCharCode(65 + r);
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(rowLetter, style: const TextStyle(fontSize: 10, color: Colors.white38)),
                    ),
                    const SizedBox(width: 8),
                    ...List.generate(sec.seatsPerRow, (c) {
                      final seatId = '$rowLetter${c + 1}';
                      final isBooked = bookedSeats.contains(seatId);
                      final isBlocked = sec.disabledSeats.contains(seatId);

                      Color bg, border, textColor;
                      if (isBooked) {
                        bg = sectionColor;
                        border = sectionColor;
                        textColor = Colors.white;
                      } else if (isBlocked) {
                        bg = const Color(0xFF27272A);
                        border = Colors.transparent;
                        textColor = const Color(0xFF3F3F46);
                      } else {
                        bg = AppColors.border;
                        border = const Color(0xFF27272A);
                        textColor = Colors.white54;
                      }

                      return GestureDetector(
                        onTap: () {
                          if (isBooked) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot block a seat that is already booked!')));
                            return;
                          }
                          _toggleBlockSeat(sec, seatId, event);
                        },
                        child: Container(
                          width: 28, height: 28,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: bg,
                            border: Border.all(color: border, width: 1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          alignment: Alignment.center,
                          child: isBlocked
                              ? const Icon(Icons.close, size: 14, color: Colors.white24)
                              : Text('${c + 1}', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textColor)),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color bg, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14, decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }

  Widget _buildInvitesTab(List<EventInvite> invites, EventData event) {
    int accepted = invites.where((i) => i.status == 'accepted').length;
    int pending = invites.where((i) => i.status == 'pending').length;
    int declined = invites.where((i) => i.status == 'declined').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (Simplified)
        Text('Guest List', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _showInviteModal(context, event),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text('+ Invite New Guest', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold, fontSize: 14)),
        ),
        const SizedBox(height: 32),

        // Stats (Using Wrap to avoid Row/Expanded Flex issues)
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSimpleStat('Accepted', accepted, Colors.green),
            _buildSimpleStat('Pending', pending, Colors.amber),
            _buildSimpleStat('Declined', declined, Colors.red),
          ],
        ),
        const SizedBox(height: 32),

        // List
        if (invites.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Text('No guests invited yet. Tap the button above to start!', textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedForeground)),
          )
        else
          ...invites.map((invite) {
            Color statusColor;
            switch (invite.status) {
              case 'accepted': statusColor = Colors.green; break;
              case 'declined': statusColor = Colors.red; break;
              default: statusColor = Colors.amber;
            }
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    child: Icon(LucideIcons.user, size: 20, color: AppColors.foreground),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(invite.contact, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('Sent: ${invite.sentAt}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Text(invite.status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildSimpleStat(String label, int count, Color color) {
    return Container(
      width: 100, // Fixed width instead of Expanded
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(count.toString(), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color)),
        ],
      ),
    );
  }

  void _showInviteModal(BuildContext context, EventData event) {
    final contactCtrl = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Invite Guest', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(LucideIcons.x, size: 20, color: AppColors.foreground)),
                  ],
                ),
                const SizedBox(height: 16),
                Text('Email or Phone Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                const SizedBox(height: 8),
                TextField(
                  controller: contactCtrl,
                  style: TextStyle(color: AppColors.foreground, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'e.g. john@example.com or +919876543210',
                    hintStyle: TextStyle(color: AppColors.mutedForeground),
                    filled: true,
                    fillColor: AppColors.card,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (contactCtrl.text.trim().isEmpty) return;
                      
                      final newInvite = EventInvite(
                        id: 'invite-${DateTime.now().millisecondsSinceEpoch}',
                        eventId: event.id,
                        eventTitle: event.title,
                        eventDate: event.date,
                        eventVenue: event.venue,
                        organizerName: ref.read(appProvider).organizer.orgName,
                        contact: contactCtrl.text.trim(),
                        status: 'pending',
                        sentAt: DateFormat('MMM d, h:mm a').format(DateTime.now()),
                        eventImageKey: event.imageKey,
                      );
                      
                      ref.read(appProvider.notifier).sendInvite(newInvite);
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Invitation sent to ${contactCtrl.text.trim()}!'), backgroundColor: Colors.green),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Send Invite', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewTab(int ticketsSold, double ticketRevenue, int activeVendors, int pending, double totalSpend) {
    return Column(
      children: [
        _buildStat('Tickets Sold', '$ticketsSold'),
        const SizedBox(height: 12),
        _buildStat('Revenue', '₹${ticketRevenue.toInt()}'),
        const SizedBox(height: 12),
        _buildStat('Active Services', activeVendors.toString()),
        const SizedBox(height: 12),
        _buildStat('Pending Quotes', pending.toString()),
        const SizedBox(height: 12),
        _buildStat('Vendor Spend', '₹${totalSpend.toInt()}'),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Revenue Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              const SizedBox(height: 16),
              _buildAnalyticsRow('Ticket Revenue', '₹${ticketRevenue.toInt()}', Colors.green),
              _buildAnalyticsRow('Vendor Spend', '₹${totalSpend.toInt()}', Colors.red),
              _buildAnalyticsRow('Net Revenue', '₹${(ticketRevenue - totalSpend).toInt()}', AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, String hint, {int maxLines = 1, bool readOnly = false, VoidCallback? onTap}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
      const SizedBox(height: 6),
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        style: TextStyle(color: AppColors.foreground, fontSize: 13),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
        ),
      ),
    ]);
  }

  Widget _buildToggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.card,
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.foreground)),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        ],
      ),
    );
  }

  Widget _buildMini(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 9, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        ],
      ),
    );
  }

  Widget _buildAnalyticsRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
