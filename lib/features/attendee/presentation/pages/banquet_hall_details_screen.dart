import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/data/banquet_halls_data.dart';

class BanquetHallDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  const BanquetHallDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<BanquetHallDetailsScreen> createState() => _BanquetHallDetailsScreenState();
}

class _BanquetHallDetailsScreenState extends ConsumerState<BanquetHallDetailsScreen> {
  String _step = 'details';
  int _galleryIdx = 0;
  String _date = '';
  String _slot = 'evening';
  String _cateringId = '';
  String _decorId = '';
  double _guests = 200;
  String _visibility = 'private';
  String _payMethod = 'upi';
  String _orderNumber = '';

  @override
  void initState() {
    super.initState();
    // Clamp the initial _guests value to not exceed the hall's capacity
    final hall = banquetHalls.firstWhere((h) => h.id == widget.id, orElse: () => banquetHalls.first);
    if (_guests > hall.capacity.toDouble()) {
      _guests = hall.capacity.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final hall = banquetHalls.firstWhere((h) => h.id == widget.id, orElse: () => throw Exception('Not found'));
    final savedKey = 'banquet:${hall.id}';
    final saved = ref.watch(appProvider).savedVendors.contains(savedKey);

    final venuePrice = computeHallSlotPrice(hall.startingPrice, _slot);
    final cateringPkg = hall.cateringPackages.cast<Map<String, dynamic>?>().firstWhere((p) => p!['name'] == _cateringId, orElse: () => null);
    final decorPkg = hall.decorationPackages.cast<Map<String, dynamic>?>().firstWhere((p) => p!['name'] == _decorId, orElse: () => null);
    final cateringCost = cateringPkg != null ? (cateringPkg['pricePerPlate'] as int) * _guests : 0.0;
    final decorCost = decorPkg != null ? (decorPkg['price'] as int).toDouble() : 0.0;
    final baseTotal = venuePrice + cateringCost + decorCost;
    
    // Pricing logic
    final platformFee = baseTotal * 0.02;
    final taxes = baseTotal * 0.18;
    final total = baseTotal + platformFee + taxes;
    
    final canContinue = _date.isNotEmpty && _slot.isNotEmpty;

    if (_step != 'details') {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        if (_step == 'success') {
                          context.go('/tickets');
                        } else {
                          setState(() => _step = _step == 'payment' ? 'review' : 'details');
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
                          Text(_step == 'review' ? 'Review Booking' : _step == 'payment' ? 'Payment' : 'Booking Confirmed', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          Text(hall.name, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (_step == 'review') ...[
                      _buildSummaryCard(hall, venuePrice, cateringCost, decorCost, platformFee, taxes, total, cateringPkg, decorPkg, false),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => setState(() => _step = 'payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Proceed to Payment · ₹${total.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                      ),
                    ],
                    if (_step == 'payment') ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withOpacity(0.6),
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('PAYMENT METHOD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                            const SizedBox(height: 12),
                            ...[
                              {'id': 'upi', 'label': 'UPI / GPay / PhonePe'},
                              {'id': 'card', 'label': 'Credit / Debit Card'},
                              {'id': 'netbanking', 'label': 'Net Banking'},
                            ].map((m) {
                              final isSelected = _payMethod == m['id'];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: InkWell(
                                  onTap: () => setState(() => _payMethod = m['id']!),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.background,
                                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.creditCard, size: 14, color: AppColors.foreground),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(m['label']!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground))),
                                        if (isSelected) Icon(LucideIcons.check, size: 16, color: AppColors.primary),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      _buildSummaryCard(hall, venuePrice, cateringCost, decorCost, platformFee, taxes, total, cateringPkg, decorPkg, true),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          final num = 'ORD-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
                          setState(() => _orderNumber = num);
                          
                          final booking = ServiceBooking(
                            id: num,
                            orderNumber: num,
                            serviceId: 'banquet-hall',
                            serviceName: 'Banquet Hall · ${hall.name}',
                            vendorId: hall.id,
                            vendorName: hall.name,
                            packageName: 'Premium',
                            servicePrice: baseTotal,
                            platformFee: platformFee,
                            taxes: taxes,
                            total: total,
                            paymentMethod: _payMethod.toUpperCase(),
                            status: 'Confirmed',
                            bookedAt: DateTime.now().toIso8601String(),
                            eventName: 'Banquet Hall Booking',
                            eventType: hall.venueType,
                            eventDate: _date,
                            startTime: (timeSlots.firstWhere((s) => s['id'] == _slot)['range'] as String).split('–')[0].trim(),
                            endTime: (timeSlots.firstWhere((s) => s['id'] == _slot)['range'] as String).split('–')[1].trim(),
                            venueName: hall.name,
                            city: hall.city,
                            guests: _guests.toInt(),
                            specialRequirements: 'Slot: ${timeSlots.firstWhere((s) => s['id'] == _slot)['label']} | Catering: ${cateringPkg?['name'] ?? 'None'} | Decor: ${decorPkg?['name'] ?? 'None'}',
                            visibility: _visibility,
                          );
                          ref.read(appProvider.notifier).addServiceBooking(booking);
                          setState(() => _step = 'success');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Pay ₹${total.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                      ),
                    ],
                    if (_step == 'success') ...[
                      const SizedBox(height: 40),
                      Container(
                        width: 80, height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20)],
                        ),
                        child: Icon(LucideIcons.check, size: 42, color: AppColors.primaryForeground),
                      ),
                      const SizedBox(height: 20),
                      Text('Booking Confirmed!', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      const SizedBox(height: 4),
                      Text('Booking ID: $_orderNumber', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                      const SizedBox(height: 24),
                      Text('A confirmation has been sent to your registered number.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => context.go('/tickets'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('View My Bookings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => context.go('/home'),
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Back to Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      ),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // DETAILS SCREEN
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.only(bottom: 160),
            children: [
              // Hero
              Container(
                height: 288,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(hall.gallery[_galleryIdx]['colors'][0]),
                      Color(hall.gallery[_galleryIdx]['colors'][1]),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.background.withOpacity(0.8), Colors.transparent],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Center(child: Icon(LucideIcons.building2, size: 88, color: Colors.white.withOpacity(0.3))),
                      Positioned(
                        top: 16, left: 16, right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: AppColors.background.withOpacity(0.6), shape: BoxShape.circle),
                                child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: AppColors.background.withOpacity(0.6), shape: BoxShape.circle),
                                    child: Icon(LucideIcons.share2, size: 18, color: AppColors.foreground),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => ref.read(appProvider.notifier).toggleSaveVendor(savedKey),
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: AppColors.background.withOpacity(0.6), shape: BoxShape.circle),
                                    child: Icon(LucideIcons.heart, size: 18, color: saved ? AppColors.primary : AppColors.foreground),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16, left: 0, right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(hall.gallery.length, (i) => Container(
                            width: i == _galleryIdx ? 24 : 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                              color: i == _galleryIdx ? AppColors.primary : AppColors.foreground.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Info card
              Transform.translate(
                offset: const Offset(0, -24),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.8),
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(hall.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(LucideIcons.mapPin, size: 11, color: AppColors.mutedForeground),
                                      const SizedBox(width: 4),
                                      Text('${hall.area}, ${hall.city}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
                              child: Row(
                                children: [
                                  Icon(LucideIcons.star, size: 12, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(hall.rating.toString(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  const SizedBox(width: 4),
                                  Text('(${hall.reviewCount})', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickStat(LucideIcons.users, 'Capacity', '${hall.capacity}'),
                            _buildQuickStat(LucideIcons.building2, 'Halls', '${hall.halls}'),
                            _buildQuickStat(LucideIcons.clock, 'Hours', '9–12'),
                            _buildQuickStat(LucideIcons.sparkles, 'Type', hall.venueType.split(' ')[0]),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Sections
              _buildSection('Gallery', LucideIcons.camera, Column(
                children: [
                  SizedBox(
                    height: 96,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: hall.gallery.length,
                      itemBuilder: (context, i) {
                        final g = hall.gallery[i];
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () => setState(() => _galleryIdx = i),
                            child: Container(
                              width: 128,
                              decoration: BoxDecoration(
                                border: Border.all(color: i == _galleryIdx ? AppColors.primary : AppColors.border),
                                borderRadius: BorderRadius.circular(12),
                                gradient: LinearGradient(
                                  colors: [Color(g['colors'][0]), Color(g['colors'][1])],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              alignment: Alignment.bottomLeft,
                              padding: const EdgeInsets.all(8),
                              child: Text(g['category'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (hall.hasVirtualTour)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(LucideIcons.compass, size: 14, color: AppColors.primary),
                        label: Text('Launch 360° Virtual Tour', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size.fromHeight(48),
                        ),
                      ),
                    ),
                ],
              )),

              _buildSection('About Venue', LucideIcons.fileText, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(hall.description, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: hall.highlights.map((h) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.secondary, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        child: Text(h, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.foreground)),
                      )).toList(),
                    ),
                  ],
                ),
              )),

              _buildSection('Select Date & Time', LucideIcons.calendar, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.secondary, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                      child: TextField(
                        onChanged: (v) => setState(() => _date = v), // Ideally use a DatePicker
                        style: TextStyle(color: AppColors.foreground),
                        decoration: InputDecoration(
                          hintText: 'YYYY-MM-DD',
                          hintStyle: TextStyle(color: AppColors.mutedForeground),
                          border: InputBorder.none,
                          icon: Icon(LucideIcons.calendar, size: 16, color: AppColors.mutedForeground),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 2.5,
                      children: timeSlots.map((s) {
                        final isSelected = _slot == s['id'];
                        return InkWell(
                          onTap: () => setState(() => _slot = s['id'] as String),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                              border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(s['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                Text(s['range'] as String, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text('Guest Count: ${_guests.toInt()}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                    Slider(
                      value: _guests, min: hall.capacity < 50 ? hall.capacity.toDouble() : 50.0, max: hall.capacity.toDouble(), divisions: 20,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _guests = v),
                    ),
                  ],
                ),
              )),

              _buildSection('Recommended Catering', LucideIcons.utensilsCrossed, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: hall.cateringPackages.map((p) {
                    final isSelected = _cateringId == p['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _cateringId = isSelected ? '' : p['name']),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p['name'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                      Text('Capacity: ${p['capacity']}', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                  Text('₹${p['pricePerPlate']}/plate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text((p['menu'] as List).join(' · '), style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),

              _buildSection('Recommended Decoration', LucideIcons.palette, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: hall.decorationPackages.map((p) {
                    final isSelected = _decorId == p['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => setState(() => _decorId = isSelected ? '' : p['name']),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(p['name'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  Text('₹${p['price']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text('${p['theme']} · ${(p['includes'] as List).join(', ')}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              )),
              _buildSection('Event Visibility', LucideIcons.sparkles, Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ...[
                      {'id': 'public', 'label': 'Public Event', 'desc': 'Visible to all Eventra users. Tickets can be sold publicly. Requires Eventra review before listing.', 'icon': LucideIcons.globe},
                      {'id': 'private', 'label': 'Private Event', 'desc': 'Invitation-only. Will not appear in Eventra listings, search, or recommendations.', 'icon': LucideIcons.lock},
                    ].map((opt) {
                      final active = _visibility == opt['id'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () => setState(() => _visibility = opt['id'] as String),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: active ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: active ? AppColors.primary : AppColors.border),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(color: active ? AppColors.primary : AppColors.background, borderRadius: BorderRadius.circular(8)),
                                  child: Icon(opt['icon'] as IconData, size: 16, color: active ? AppColors.primaryForeground : AppColors.mutedForeground),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(opt['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                      const SizedBox(height: 2),
                                      Text(opt['desc'] as String, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 16, height: 16,
                                  margin: const EdgeInsets.only(top: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: active ? AppColors.primary : AppColors.mutedForeground, width: 2),
                                    color: active ? AppColors.primary : Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    if (_visibility == 'public')
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text("You'll be guided through Event Creation after booking so Eventra can review and list your public event.", style: TextStyle(fontSize: 11, color: AppColors.mutedForeground, height: 1.4)),
                      ),
                  ],
                ),
              )),
              
              const SizedBox(height: 32),
            ],
          ),

          // Sticky bottom bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.95),
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_date.isNotEmpty ? '$_date · ${timeSlots.firstWhere((s) => s['id'] == _slot)['label']}' : 'Select date', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                          Text('₹${total.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          Text('Venue ₹${venuePrice.toInt()}${cateringCost > 0 ? ' + Catering ₹${cateringCost.toInt()}' : ''}${decorCost > 0 ? ' + Decor ₹${decorCost.toInt()}' : ''}', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: canContinue ? () => setState(() => _step = 'review') : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Book Now', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget content) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(icon, size: 14, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(title.toUpperCase(), style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground, letterSpacing: 1)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  Widget _buildQuickStat(IconData icon, String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BanquetHall hall, double venuePrice, double cateringCost, double decorCost, double platformFee, double taxes, double total, Map<String, dynamic>? cateringPkg, Map<String, dynamic>? decorPkg, bool compact) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.6),
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('BOOKING SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
          const SizedBox(height: 12),
          _buildSummaryRow('Venue', hall.name),
          _buildSummaryRow('Date', _date.isEmpty ? '—' : _date),
          _buildSummaryRow('Time', timeSlots.firstWhere((s) => s['id'] == _slot)['range'] as String),
          _buildSummaryRow('Guests', '${_guests.toInt()}'),
          if (cateringPkg != null) _buildSummaryRow('Catering', cateringPkg['name']),
          if (decorPkg != null) _buildSummaryRow('Decoration', decorPkg['name']),
          
          if (!compact) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: AppColors.border),
            ),
            _buildSummaryRow('Venue charge', '₹${venuePrice.toInt()}'),
            if (cateringCost > 0) _buildSummaryRow('Catering', '₹${cateringCost.toInt()}'),
            if (decorCost > 0) _buildSummaryRow('Decoration', '₹${decorCost.toInt()}'),
            _buildSummaryRow('Platform fee', '₹${platformFee.toInt()}'),
            _buildSummaryRow('Taxes', '₹${taxes.toInt()}'),
          ],

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              Text('₹${total.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          Expanded(child: Text(val, textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground))),
        ],
      ),
    );
  }
}
