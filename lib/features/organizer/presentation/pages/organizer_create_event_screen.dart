import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/data/venues_data.dart';
import '../../../../core/data/service_providers_data.dart';
import '../../../../core/models/app_models.dart';

class OrganizerCreateEventScreen extends ConsumerStatefulWidget {
  const OrganizerCreateEventScreen({super.key});

  @override
  ConsumerState<OrganizerCreateEventScreen> createState() => _OrganizerCreateEventScreenState();
}

class _OrganizerCreateEventScreenState extends ConsumerState<OrganizerCreateEventScreen> {
  int _step = 0;
  bool _published = false;

  // ── Step labels ──────────────────────────────────────────────────────────
  final _steps = ['Venue', 'Services', 'Info', 'Tickets', 'Review'];

  final _categories = ['Music', 'Sports', 'Comedy', 'Nightlife', 'Arts', 'Performances'];

  // ── Step 1: Info ─────────────────────────────────────────────────────────
  String _title = '';
  String _category = 'Music';
  String _visibility = 'public'; // 'public' | 'private'
  String _date = '';
  String _time = '';
  String _description = '';

  final _titleCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // ── Step 2: Venue ─────────────────────────────────────────────────────────
  VenueData? _selectedVenue;
  String _manualVenue = '';
  String _manualCity = '';
  bool _useManualVenue = false;
  final _manualVenueCtrl = TextEditingController();
  final _manualCityCtrl = TextEditingController();
  String _venueFilter = '';
  String _selectedCity = 'All';

  // ── Step 3: Services ──────────────────────────────────────────────────────
  final List<ServiceProviderProfile> _selectedProviders = [];
  final _serviceOptions = ['Photography', 'Catering', 'DJ / Sound', 'Decoration', 'Security', 'Videography', 'MC / Host', 'Stage & Lighting'];

  // ── Step 4: Tickets ───────────────────────────────────────────────────────
  String _entryType = 'paid'; // 'free' | 'paid'
  final List<Map<String, dynamic>> _tiers = [
    {'name': 'General Admission', 'price': TextEditingController(text: ''), 'quantity': TextEditingController(text: ''), 'saved': false},
  ];

  Map<String, String> _errors = {};

  // ── Validation ────────────────────────────────────────────────────────────
  bool _validateInfo() {
    final errors = <String, String>{};
    if (_titleCtrl.text.trim().isEmpty) errors['title'] = 'Event title is required';
    if (_descCtrl.text.trim().isEmpty) errors['description'] = 'Description is required';
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  bool _validateVenue() {
    final errors = <String, String>{};
    if (_dateCtrl.text.isEmpty) errors['date'] = 'Date is required';
    if (_timeCtrl.text.isEmpty) errors['time'] = 'Time is required';
    if (_useManualVenue) {
      if (_manualVenueCtrl.text.trim().isEmpty) errors['venue'] = 'Venue name is required';
      if (_manualCityCtrl.text.trim().isEmpty) errors['city'] = 'City is required';
    } else if (_selectedVenue == null) {
      errors['venue'] = 'Please select a venue or enter one manually';
    }
    setState(() => _errors = errors);
    return errors.isEmpty;
  }

  void _nextStep() {
    if (_step == 0 && !_validateVenue()) return;
    if (_step == 2 && !_validateInfo()) return;
    setState(() => _step++);
  }

  void _submit() {
    final imageKey = _category.toLowerCase() == 'music' ? 'concert'
        : _category.toLowerCase() == 'sports' ? 'sports'
        : _category.toLowerCase() == 'comedy' ? 'comedy'
        : _category.toLowerCase() == 'nightlife' ? 'nightlife'
        : _category.toLowerCase() == 'arts' ? 'arts'
        : 'performance';

    final venueName = _useManualVenue
        ? _manualVenueCtrl.text.trim()
        : (_selectedVenue?.name ?? 'TBD');
    final city = _useManualVenue
        ? _manualCityCtrl.text.trim()
        : (_selectedVenue?.city ?? 'TBD');

    // Build ticket tiers
    final tiers = _entryType == 'free'
        ? <TicketTier>[const TicketTier(id: 'free', name: 'Free Entry', price: 0, quantity: 999)]
        : _tiers.where((t) {
            final name = (t['name'] as String).trim();
            final price = double.tryParse((t['price'] as TextEditingController).text) ?? 0;
            final qty = int.tryParse((t['quantity'] as TextEditingController).text) ?? 0;
            return name.isNotEmpty && qty > 0;
          }).map((t) => TicketTier(
            id: 'tier_${DateTime.now().millisecondsSinceEpoch}_${_tiers.indexOf(t)}',
            name: (t['name'] as String).trim(),
            price: double.tryParse((t['price'] as TextEditingController).text) ?? 0,
            quantity: int.tryParse((t['quantity'] as TextEditingController).text) ?? 0,
          )).toList();

    final firstTierPrice = tiers.isNotEmpty ? tiers.first.price : 0.0;

    List<SeatSection> eventSeatingLayouts = [];
    if (_selectedVenue != null && _selectedVenue!.seatingLayouts.isNotEmpty && _entryType != 'free') {
      for (final section in _selectedVenue!.seatingLayouts) {
        // Find matching tier
        final tierInfo = _tiers.firstWhere(
          (t) => t['name'] == section.name, 
          orElse: () => {'price': TextEditingController(text: '0')}
        );
        final price = double.tryParse((tierInfo['price'] as TextEditingController).text) ?? 0.0;
        
        eventSeatingLayouts.add(SeatSection(
          id: section.id,
          name: section.name,
          rows: section.rows,
          seatsPerRow: section.seatsPerRow,
          colorHex: section.colorHex,
          price: price,
          available: section.available,
        ));
      }
    }

    final event = EventData(
      id: 'E${DateTime.now().millisecondsSinceEpoch}',
      title: _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'Untitled Event',
      date: _dateCtrl.text.isNotEmpty ? _dateCtrl.text : 'TBD',
      time: _timeCtrl.text.isNotEmpty ? _timeCtrl.text : 'TBD',
      venue: venueName,
      city: city,
      category: _category,
      price: firstTierPrice,
      description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : 'No description provided.',
      imageKey: imageKey,
      featured: false,
      spotlight: false,
      visibility: _visibility,
      ticketTiers: tiers,
      linkedVenueId: _selectedVenue?.id ?? '',
      seatingLayouts: eventSeatingLayouts,
      venueStatus: _selectedVenue != null ? 'pending' : 'confirmed',
    );

    ref.read(appProvider.notifier).publishEvent(event);
    setState(() => _published = true);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _descCtrl.dispose();
    _manualVenueCtrl.dispose();
    _manualCityCtrl.dispose();
    for (final t in _tiers) {
      (t['price'] as TextEditingController).dispose();
      (t['quantity'] as TextEditingController).dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_published) return _buildSuccessScreen();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildProgressBar(),
            Expanded(child: _buildCurrentStep()),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessScreen() {
    final isPrivate = _visibility == 'private';
    final eventTitle = _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : 'Your Event';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88, height: 88,
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 30)]),
                child: Icon(LucideIcons.checkCircle2, size: 44, color: AppColors.primaryForeground),
              ),
              const SizedBox(height: 24),
              Text(isPrivate ? '🔒 Private Event Created!' : '🎉 Event Published!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground), textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                isPrivate
                    ? '"$eventTitle" is saved as a private event. Go to the event detail to invite your attendees.'
                    : '"$eventTitle" has been submitted and will appear publicly once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
              ),
              const SizedBox(height: 36),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/organizer'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.primaryForeground, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  child: Text(isPrivate ? 'Go to Dashboard →' : 'Go to Dashboard →', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ),
              ),
              if (isPrivate) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/organizer'),
                  child: Text('Invite attendees from the event page', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          InkWell(
            onTap: () => _step == 0 ? context.pop() : setState(() => _step--),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
              child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Create Event', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              Text('Step ${_step + 1} of ${_steps.length}: ${_steps[_step]}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isDone = i < _step;
          final isActive = i == _step;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Column(children: [
                Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDone ? Colors.green : isActive ? AppColors.primary : AppColors.secondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 5),
                Text(_steps[i], style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isDone ? Colors.green : isActive ? AppColors.primary : AppColors.mutedForeground)),
              ]),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_step) {
      case 0: return _buildVenueStep();
      case 1: return _buildServicesStep();
      case 2: return _buildInfoStep();
      case 3: return _buildTicketsStep();
      case 4: return _buildReviewStep();
      default: return const SizedBox();
    }
  }

  Widget _buildBottomButtons() {
    final isLast = _step == _steps.length - 1;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(color: AppColors.background, border: Border(top: BorderSide(color: AppColors.border))),
      child: Row(children: [
        if (_step > 0)
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => setState(() => _step--),
              style: OutlinedButton.styleFrom(foregroundColor: AppColors.foreground, side: BorderSide(color: AppColors.border), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: Text('Back', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
            ),
          ),
        if (_step > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLast ? _submit : _nextStep,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.primaryForeground, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
            child: Text(isLast ? 'Publish Event' : 'Continue →', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Step 1 — Info
  // ════════════════════════════════════════════════════════════════════
  Widget _buildInfoStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        _buildField('Event Title', _titleCtrl, 'e.g. Tech Summit 2026', error: _errors['title']),
        const SizedBox(height: 16),

        // Category chips
        Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: _categories.map((c) {
          final selected = _category == c;
          return GestureDetector(
            onTap: () => setState(() => _category = c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: selected ? AppColors.primary : AppColors.secondary, borderRadius: BorderRadius.circular(20), border: Border.all(color: selected ? AppColors.primary : AppColors.border)),
              child: Text(c, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selected ? AppColors.primaryForeground : AppColors.mutedForeground)),
            ),
          );
        }).toList()),

        const SizedBox(height: 16),
        _buildField('Description', _descCtrl, 'Tell attendees about the event...', maxLines: 4, error: _errors['description']),

        const SizedBox(height: 20),
        // Visibility toggle
        Text('Visibility', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _buildVisibilityOption('public', LucideIcons.globe2, 'Public', 'Listed for everyone')),
          const SizedBox(width: 12),
          Expanded(child: _buildVisibilityOption('private', LucideIcons.lock, 'Private', 'Invite-only access')),
        ]),

        if (_visibility == 'private') ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.08), border: Border.all(color: Colors.orange.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(LucideIcons.info, size: 14, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(child: Text('This event will not appear in public listings. You can invite attendees from the event detail page after creating it.', style: TextStyle(fontSize: 11, color: AppColors.foreground, height: 1.4))),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _buildVisibilityOption(String value, IconData icon, String label, String sub) {
    final selected = _visibility == value;
    return GestureDetector(
      onTap: () => setState(() => _visibility = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.08) : AppColors.card,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: selected ? AppColors.primary : AppColors.mutedForeground),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: selected ? AppColors.primary : AppColors.foreground)),
          const SizedBox(height: 2),
          Text(sub, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
        ]),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Step 2 — Venue Browser
  // ════════════════════════════════════════════════════════════════════
  Widget _buildVenueStep() {
    final cities = ['All', ...mockVenues.map((v) => v.city).toSet().toList()..sort()];

    final filtered = mockVenues.where((v) {
      if (_selectedCity != 'All' && v.city != _selectedCity) return false;
      if (_venueFilter.isNotEmpty) {
        final q = _venueFilter.toLowerCase();
        if (!v.name.toLowerCase().contains(q) && !v.city.toLowerCase().contains(q)) return false;
      }
      if (_dateCtrl.text.isNotEmpty) {
        // Simulating venue availability filtering based on date
        if ((v.name.length + _dateCtrl.text.length) % 5 == 0) return false;
      }
      return true;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        // Date and Time selection
        Row(children: [
          Expanded(child: _buildField('Date', _dateCtrl, 'e.g. Apr 20, 2026', error: _errors['date'], readOnly: true, onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2050),
            );
            if (date != null) {
              _dateCtrl.text = DateFormat('MMM d, yyyy').format(date);
              setState(() {});
            }
          })),
          Expanded(child: _buildField('Time', _timeCtrl, 'e.g. 7:00 PM - 11:00 PM', error: _errors['time'], readOnly: true, onTap: () async {
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
                setState(() {});
              }
            }
          })),
        ]),
        const SizedBox(height: 24),

        // Toggle: Browse vs Manual
        Row(children: [
          Expanded(child: _buildToggleBtn('Browse Venues', !_useManualVenue, () => setState(() => _useManualVenue = false))),
          const SizedBox(width: 10),
          Expanded(child: _buildToggleBtn('Enter Manually', _useManualVenue, () => setState(() => _useManualVenue = true))),
        ]),
        const SizedBox(height: 20),

        if (_useManualVenue) ...[
          _buildField('Venue Name', _manualVenueCtrl, 'e.g. My Private Farmhouse', error: _errors['venue']),
          const SizedBox(height: 14),
          _buildField('City', _manualCityCtrl, 'e.g. Pune', error: _errors['city']),
        ] else ...[
          // City filter
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final city = cities[index];
                final selected = _selectedCity == city;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCity = city),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? AppColors.primary : AppColors.card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                    ),
                    child: Text(city, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: selected ? AppColors.primaryForeground : AppColors.foreground)),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Search
          TextFormField(
            onChanged: (v) => setState(() => _venueFilter = v),
            style: TextStyle(color: AppColors.foreground, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Search by name or city...',
              hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
              prefixIcon: Icon(LucideIcons.search, size: 16, color: AppColors.mutedForeground),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),

          if (_errors['venue'] != null) ...[
            const SizedBox(height: 6),
            Text(_errors['venue']!, style: const TextStyle(fontSize: 11, color: Colors.red)),
          ],

          const SizedBox(height: 16),
          ...filtered.map((venue) => _buildVenueCard(venue)).toList(),
        ],
      ],
    );
  }

  Widget _buildToggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.secondary, borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? AppColors.primaryForeground : AppColors.mutedForeground))),
      ),
    );
  }

  void _showVenuePortfolio(VenueData venue) {
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
                    setState(() {
                      _selectedVenue = venue;
                      if (venue.seatingLayouts.isNotEmpty) {
                        _tiers.clear();
                        for (final section in venue.seatingLayouts) {
                          _tiers.add({
                            'name': section.name,
                            'price': TextEditingController(text: section.price.toString()),
                            'quantity': TextEditingController(text: (section.rows * section.seatsPerRow).toString()),
                            'saved': true,
                            'isLocked': true,
                          });
                        }
                      } else {
                        _tiers.clear();
                        _tiers.add({
                          'name': 'General Admission', 
                          'price': TextEditingController(text: ''), 
                          'quantity': TextEditingController(text: venue.capacity.toString()), 
                          'saved': false,
                          'isLocked': false,
                        });
                      }
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Select Venue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVenueCard(VenueData venue) {
    final selected = _selectedVenue?.id == venue.id;
    return GestureDetector(
      onTap: () => _showVenuePortfolio(venue),
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

  // ════════════════════════════════════════════════════════════════════
  // Step 3 — Services
  // ════════════════════════════════════════════════════════════════════
  Widget _buildServicesStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Text('Add service providers for your event (optional)', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, height: 1.4)),
        const SizedBox(height: 16),
        
        // Selected Providers List
        if (_selectedProviders.isNotEmpty) ...[
          Text('Selected Providers', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 10),
          ..._selectedProviders.map((p) => _buildSelectedProviderCard(p)).toList(),
          const SizedBox(height: 16),
          Text('Add Another Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 10),
        ],

        Wrap(spacing: 10, runSpacing: 10, children: _serviceOptions.map((s) {
          final isSelected = _selectedProviders.any((p) => p.serviceCategory == s);
          return GestureDetector(
            onTap: () => _showProvidersModal(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (isSelected) ...[Icon(LucideIcons.checkCircle2, size: 13, color: AppColors.primary), const SizedBox(width: 6)],
                Text(s, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
              ]),
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildSelectedProviderCard(ServiceProviderProfile provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(LucideIcons.briefcase, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(provider.businessName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 2),
                Text(provider.serviceCategory, style: TextStyle(fontSize: 12, color: AppColors.primary)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(LucideIcons.trash2, size: 18, color: Colors.red.withOpacity(0.8)),
            onPressed: () => setState(() => _selectedProviders.remove(provider)),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
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
                          onTap: () => _showProviderPortfolio(p),
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

  void _showProviderPortfolio(ServiceProviderProfile provider) {
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
                    Text(provider.businessName, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(LucideIcons.mapPin, size: 14, color: AppColors.mutedForeground),
                        const SizedBox(width: 6),
                        Text(provider.city, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                        const SizedBox(width: 12),
                        Icon(LucideIcons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(provider.rating, style: TextStyle(fontSize: 14, color: AppColors.foreground, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _venueBadge(LucideIcons.indianRupee, 'Starting ₹${provider.startingPrice}'),
                        _venueBadge(LucideIcons.briefcase, '${provider.experienceYears} Years Exp'),
                        _venueBadge(LucideIcons.checkCircle2, '${provider.totalGigs} Events Completed'),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text('About', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 10),
                    Text(provider.bio, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
                    
                    if (provider.servicesOffered.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Text('Services Offered', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: provider.servicesOffered.map((s) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
                          child: Text(s, style: TextStyle(fontSize: 12, color: AppColors.foreground, fontWeight: FontWeight.w500)),
                        )).toList(),
                      ),
                    ],
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
                    // Check if already added
                    if (!_selectedProviders.any((p) => p.vendorId == provider.vendorId)) {
                      setState(() => _selectedProviders.add(provider));
                    }
                    Navigator.pop(context); // Close portfolio
                    Navigator.pop(context); // Close browse modal
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    minimumSize: const Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Add Provider', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Step 4 — Tickets
  // ════════════════════════════════════════════════════════════════════
  Widget _buildTicketsStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [

        // Entry type toggle
        Text('Entry Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _buildToggleBtn('Free', _entryType == 'free', () => setState(() => _entryType = 'free'))),
          const SizedBox(width: 10),
          Expanded(child: _buildToggleBtn('Paid', _entryType == 'paid', () => setState(() => _entryType = 'paid'))),
        ]),
        const SizedBox(height: 20),

        if (_selectedVenue != null) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text('Selected Venue: ${_selectedVenue!.name}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.foreground)),
                  ],
                ),
                const SizedBox(height: 8),
                if (_selectedVenue!.seatingLayouts.isNotEmpty) ...[
                  Text('Venue Layout Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary)),
                  const SizedBox(height: 4),
                  Text('Your tickets are locked to the venue\'s physical seating sections. Define the price for each section below.', style: TextStyle(fontSize: 11, color: AppColors.foreground, height: 1.4)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showVenueLayoutPreview,
                      icon: const Icon(LucideIcons.layoutGrid, size: 14),
                      label: const Text('View Venue Layout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  )
                ] else ...[
                  Text('Capacity Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.orange)),
                  const SizedBox(height: 4),
                  Text('This venue does not have defined seating layouts. You are selling unassigned tickets up to the venue\'s capacity of ${_selectedVenue!.capacity} guests.', style: TextStyle(fontSize: 11, color: AppColors.foreground, height: 1.4)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        if (_entryType == 'paid') ...[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Ticket Tiers', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
            if (_tiers.length < 5 && (_selectedVenue?.seatingLayouts.isEmpty ?? true))
              GestureDetector(
                onTap: () => setState(() => _tiers.add({'name': '', 'price': TextEditingController(), 'quantity': TextEditingController(), 'saved': false})),
                child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(LucideIcons.plus, size: 12, color: AppColors.primary), const SizedBox(width: 4), Text('Add Tier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary))])),
              ),
          ]),
          const SizedBox(height: 12),

          ..._tiers.asMap().entries.map((entry) {
            final i = entry.key;
            final tier = entry.value;
            final isSaved = tier['saved'] == true;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Tier ${i + 1}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  Row(
                    children: [
                      if (isSaved)
                        GestureDetector(
                          onTap: () => setState(() => tier['saved'] = false),
                          child: Icon(LucideIcons.edit2, size: 16, color: AppColors.mutedForeground),
                        ),
                      if (isSaved && _tiers.length > 1) const SizedBox(width: 12),
                      if (_tiers.length > 1 && tier['isLocked'] != true)
                        GestureDetector(onTap: () => setState(() { (tier['price'] as TextEditingController).dispose(); (tier['quantity'] as TextEditingController).dispose(); _tiers.removeAt(i); }), child: Icon(LucideIcons.x, size: 16, color: Colors.red)),
                    ],
                  ),
                ]),
                const SizedBox(height: 10),
                
                if (isSaved) ...[
                  Text(tier['name'].toString().isNotEmpty ? tier['name'] : 'Unnamed Tier', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Icon(LucideIcons.indianRupee, size: 12, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text('${(tier['price'] as TextEditingController).text}', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                    const SizedBox(width: 12),
                    Icon(LucideIcons.hash, size: 12, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text('${(tier['quantity'] as TextEditingController).text} tickets', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                  ]),
                ] else ...[
                  if (tier['isLocked'] == true) ...[
                    Text(tier['name'].toString().isNotEmpty ? tier['name'] : 'Unnamed Tier', style: TextStyle(color: AppColors.foreground, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextFormField(
                        controller: tier['price'] as TextEditingController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppColors.foreground, fontSize: 13),
                        decoration: _inputDeco('Price (₹)'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: Center(child: Text('${(tier['quantity'] as TextEditingController).text} tickets\\n(Fixed by Venue)', style: TextStyle(color: AppColors.mutedForeground, fontSize: 11), textAlign: TextAlign.center))),
                    ]),
                  ] else ...[
                    TextFormField(
                      initialValue: tier['name'] as String,
                      onChanged: (v) => setState(() => tier['name'] = v),
                      style: TextStyle(color: AppColors.foreground, fontSize: 13),
                      decoration: _inputDeco('Tier Name (e.g. VIP, General)'),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: TextFormField(
                        controller: tier['price'] as TextEditingController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppColors.foreground, fontSize: 13),
                        decoration: _inputDeco('Price (₹)'),
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: TextFormField(
                        controller: tier['quantity'] as TextEditingController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppColors.foreground, fontSize: 13),
                        decoration: _inputDeco('Quantity'),
                      )),
                    ]),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => setState(() => tier['saved'] = true),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Save Tier', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ]),
            );
          }).toList(),
        ],

        if (_entryType == 'free')
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.08), border: Border.all(color: Colors.green.withOpacity(0.3)), borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(LucideIcons.gift, size: 16, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(child: Text('Free event — attendees can register without payment. Unlimited capacity by default.', style: TextStyle(fontSize: 12, color: AppColors.foreground, height: 1.4))),
            ]),
          ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════
  // Step 5 — Review
  // ════════════════════════════════════════════════════════════════════
  Widget _buildReviewStep() {
    final venueName = _useManualVenue ? _manualVenueCtrl.text.trim() : (_selectedVenue?.name ?? 'No venue selected');
    final city = _useManualVenue ? _manualCityCtrl.text.trim() : (_selectedVenue?.city ?? '');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [Icon(LucideIcons.clipboardList, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text('Event Summary', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.foreground))]),
            const SizedBox(height: 12),
            _summaryRow(LucideIcons.tag, _titleCtrl.text.trim().isNotEmpty ? _titleCtrl.text.trim() : '(Untitled)'),
            _summaryRow(LucideIcons.calendar, '${_dateCtrl.text} at ${_timeCtrl.text}'),
            _summaryRow(LucideIcons.mapPin, '$venueName${city.isNotEmpty ? ', $city' : ''}'),
            _summaryRow(_visibility == 'private' ? LucideIcons.lock : LucideIcons.globe2, _visibility == 'private' ? 'Private event' : 'Public event'),
            if (_selectedProviders.isNotEmpty) _summaryRow(LucideIcons.briefcase, _selectedProviders.map((p) => p.businessName).join(', ')),
            
            const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider()),
            
            Row(children: [Icon(LucideIcons.ticket, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text('Tickets', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.foreground))]),
            const SizedBox(height: 12),
            if (_entryType == 'free')
              _summaryRow(LucideIcons.gift, 'Free Event')
            else
              ..._tiers.where((t) => t['saved'] == true || (t['name'].toString().trim().isNotEmpty)).map((t) => 
                _summaryRow(LucideIcons.indianRupee, '${t['name']} - ₹${(t['price'] as TextEditingController).text} (${(t['quantity'] as TextEditingController).text} qty)')
              ),
          ]),
        ),
        const SizedBox(height: 20),
        Text('Ready to publish?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        const SizedBox(height: 8),
        Text('Review your details above. Once published, your event will be live and you can start inviting attendees.', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.4)),
      ],
    );
  }

  Widget _summaryRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, size: 13, color: AppColors.mutedForeground),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: AppColors.foreground), maxLines: 2, overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 11),
    filled: true,
    fillColor: AppColors.background,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primary)),
    isDense: true,
  );

  Widget _buildField(String label, TextEditingController ctrl, String hint, {int maxLines = 1, String? error, bool readOnly = false, VoidCallback? onTap}) {
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error != null ? Colors.red : AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error != null ? Colors.red : AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
          errorText: error,
          errorStyle: const TextStyle(fontSize: 11, color: Colors.red),
        ),
      ),
    ]);
  }

  void _showVenueLayoutPreview() {
    final venue = _selectedVenue;
    if (venue == null || venue.seatingLayouts.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: AppColors.background,
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(LucideIcons.x, color: AppColors.foreground),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('${venue.name} Layouts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: venue.seatingLayouts.length,
            itemBuilder: (context, index) {
              final sec = venue.seatingLayouts[index];
              final col = Color(sec.colorHex);

              return Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 14, height: 14,
                          decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(3)),
                        ),
                        const SizedBox(width: 8),
                        Text(sec.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('${sec.available} available seats (${sec.rows} rows × ${sec.seatsPerRow} seats)', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Builder(builder: (context) {
                        int activeRowCounter = 0;
                        final Map<int, String> rowLetterMap = {};
                        for (int r = 0; r < sec.rows; r++) {
                          final physLetter = String.fromCharCode(65 + r);
                          bool isRowActive = false;
                          for (int c = 0; c < sec.seatsPerRow; c++) {
                            if (!sec.disabledSeats.contains('$physLetter${c + 1}')) {
                              isRowActive = true;
                              break;
                            }
                          }
                          if (isRowActive) {
                            rowLetterMap[r] = String.fromCharCode(65 + activeRowCounter);
                            activeRowCounter++;
                          } else {
                            rowLetterMap[r] = '';
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(sec.rows, (r) {
                            final physicalRowLetter = String.fromCharCode(65 + r);
                            final displayRowLetter = rowLetterMap[r] ?? '';
                            int activeSeatNum = 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                children: [
                                  SizedBox(width: 20,
                                    child: Text(displayRowLetter,
                                      style: TextStyle(fontSize: 9, color: AppColors.mutedForeground))),
                                  const SizedBox(width: 6),
                                  ...List.generate(sec.seatsPerRow, (c) {
                                    final seatId = '$physicalRowLetter${c + 1}';
                                    if (sec.disabledSeats.contains(seatId)) {
                                      return Container(
                                        width: 22, height: 22,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                      );
                                    }
                                    activeSeatNum++;
                                    return Container(
                                      width: 22, height: 22,
                                      margin: const EdgeInsets.symmetric(horizontal: 2),
                                      decoration: BoxDecoration(
                                        color: col.withOpacity(0.15),
                                        border: Border.all(color: col, width: 1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text('$activeSeatNum',
                                        style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                    );
                                  }),
                                ],
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
