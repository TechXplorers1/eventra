import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/data/services_marketplace_data.dart';

const List<String> eventTypes = ['Wedding', 'Concert', 'Corporate', 'Birthday', 'College Fest', 'Conference', 'Festival', 'Other'];

const List<Map<String, dynamic>> payMethods = [
  {'id': 'upi', 'label': 'UPI', 'icon': LucideIcons.smartphone, 'desc': 'GPay, PhonePe, Paytm'},
  {'id': 'card', 'label': 'Card', 'icon': LucideIcons.creditCard, 'desc': 'Credit / Debit'},
  {'id': 'netbanking', 'label': 'Net Banking', 'icon': LucideIcons.building2, 'desc': 'All major banks'},
  {'id': 'wallet', 'label': 'Wallet', 'icon': LucideIcons.wallet, 'desc': 'Paytm, Amazon Pay'},
];

class ServiceBookingScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String vendorId;
  const ServiceBookingScreen({super.key, required this.serviceId, required this.vendorId});

  @override
  ConsumerState<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends ConsumerState<ServiceBookingScreen> {
  String _step = 'form';
  String _pkgName = 'Standard';
  
  String _eventName = '';
  String _eventType = eventTypes[0];
  String _eventDate = '';
  String _startTime = '';
  String _endTime = '';
  String _venueName = '';
  String _city = '';
  String _guests = '';
  String _specialRequirements = '';
  
  String _payMethod = 'upi';
  ServiceBooking? _confirmed;

  @override
  Widget build(BuildContext context) {
    final service = findUserService(widget.serviceId);
    final vendor = service != null ? getVendor(service.id, widget.vendorId, service.startingPrice) : null;
    final pkg = vendor?.packages.firstWhere((p) => p.name == _pkgName, orElse: () => vendor.packages.length > 1 ? vendor.packages[1] : vendor.packages[0]);

    if (service == null || vendor == null || pkg == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Booking unavailable', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                child: Text('Go back', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final platformFee = pkg.price * 0.02;
    final taxes = pkg.price * 0.18;
    final total = pkg.price + platformFee + taxes;

    final canContinue = _eventName.isNotEmpty && _eventDate.isNotEmpty && _startTime.isNotEmpty && _endTime.isNotEmpty && _venueName.isNotEmpty && _city.isNotEmpty && _guests.isNotEmpty;

    Widget buildHeader(String title, String sub) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Row(
          children: [
            InkWell(
              onTap: () {
                if (_step == 'form') {
                  context.pop();
                } else if (_step == 'review') {
                  setState(() => _step = 'form');
                } else if (_step == 'payment') {
                  setState(() => _step = 'review');
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
                  Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_step == 'success' && _confirmed != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20)],
                  ),
                  child: Icon(LucideIcons.checkCircle2, size: 40, color: AppColors.primaryForeground),
                ),
                const SizedBox(height: 20),
                Text('Service Booked Successfully', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('Your booking with ${_confirmed!.vendorName} is confirmed.', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _buildRow('Order Number', _confirmed!.orderNumber),
                      _buildRow('Booking ID', 'BKG-${_confirmed!.id.substring(_confirmed!.id.length > 8 ? _confirmed!.id.length - 8 : 0).toUpperCase()}'),
                      _buildRow('Service', _confirmed!.serviceName),
                      _buildRow('Package', _confirmed!.packageName),
                      _buildRow('Event', _confirmed!.eventName),
                      const SizedBox(height: 8),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total Paid', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                          Text('₹${_confirmed!.total.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/tickets'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('View My Bookings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/home'),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Back to Home', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_step == 'form') {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        Container(
                          width: 56, height: 56,
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                          alignment: Alignment.center,
                          child: Text(vendor.name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(vendor.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              Text('${service.name} • ${vendor.city}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                              Text('Starting ₹${vendor.startingPrice}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Text('Select Package', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  const SizedBox(height: 8),
                  Row(
                    children: vendor.packages.map((p) {
                      final isSelected = _pkgName == p.name;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: InkWell(
                            onTap: () => setState(() => _pkgName = p.name),
                            borderRadius: BorderRadius.circular(12),
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
                                  Text(p.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  const SizedBox(height: 4),
                                  Text('₹${p.price}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: pkg.features.map((f) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Text('•', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(child: Text(f, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildField('Event Name', true, TextField(
                    onChanged: (v) => setState(() => _eventName = v),
                    style: TextStyle(color: AppColors.foreground, fontSize: 14),
                    decoration: _inputDecoration('e.g. Rohan & Priya Sangeet'),
                  )),
                  _buildField('Event Type', true, Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.secondary, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _eventType,
                        isExpanded: true,
                        dropdownColor: AppColors.secondary,
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        items: eventTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (v) => setState(() => _eventType = v!),
                      ),
                    ),
                  )),
                  Row(
                    children: [
                      Expanded(child: _buildField('Date', true, TextField(
                        onChanged: (v) => setState(() => _eventDate = v),
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        decoration: _inputDecoration('YYYY-MM-DD'),
                      ))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildField('Start', true, TextField(
                        onChanged: (v) => setState(() => _startTime = v),
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        decoration: _inputDecoration('HH:MM'),
                      ))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildField('End', true, TextField(
                        onChanged: (v) => setState(() => _endTime = v),
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        decoration: _inputDecoration('HH:MM'),
                      ))),
                    ],
                  ),
                  _buildField('Venue Name', true, TextField(
                    onChanged: (v) => setState(() => _venueName = v),
                    style: TextStyle(color: AppColors.foreground, fontSize: 14),
                    decoration: _inputDecoration('e.g. The Leela Ballroom'),
                  )),
                  Row(
                    children: [
                      Expanded(child: _buildField('City', true, TextField(
                        onChanged: (v) => setState(() => _city = v),
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        decoration: _inputDecoration('Mumbai'),
                      ))),
                      const SizedBox(width: 8),
                      Expanded(child: _buildField('Number of Guests', true, TextField(
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(() => _guests = v),
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        decoration: _inputDecoration('250'),
                      ))),
                    ],
                  ),
                  _buildField('Special Requirements', false, TextField(
                    maxLines: 3,
                    onChanged: (v) => setState(() => _specialRequirements = v),
                    style: TextStyle(color: AppColors.foreground, fontSize: 14),
                    decoration: _inputDecoration('Anything the vendor should know...'),
                  )),
                ],
              ),
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  color: AppColors.background,
                  child: buildHeader('Book Service', '${vendor.name} • ${service.name}'),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.background.withOpacity(0.95), border: Border(top: BorderSide(color: AppColors.border))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Total', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                          Text('₹${total.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: canContinue ? () => setState(() => _step = 'review') : null,
                        icon: Text('Continue'),
                        label: Icon(LucideIcons.chevronRight, size: 16),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.primaryForeground,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
    }

    if (_step == 'review') {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(16, 80, 16, 100),
                children: [
                  _buildCard('Service Provider', [
                    _buildRow('Provider', vendor.name),
                    _buildRow('Service', service.name),
                    _buildRow('Package', '${pkg.name} • ₹${pkg.price}'),
                    _buildRow('Duration', '$_startTime – $_endTime'),
                  ]),
                  const SizedBox(height: 16),
                  _buildCard('Event Details', [
                    _buildRow('Event', _eventName),
                    _buildRow('Type', _eventType),
                    _buildRow('Date', _eventDate),
                    _buildRow('Venue', '$_venueName, $_city'),
                    _buildRow('Guests', _guests),
                    if (_specialRequirements.isNotEmpty) _buildRow('Notes', _specialRequirements),
                  ]),
                  const SizedBox(height: 16),
                  _buildCard('Pricing Breakdown', [
                    _buildRow('Service Fee', '₹${pkg.price}'),
                    _buildRow('Platform Fee', '₹${platformFee.toInt()}'),
                    _buildRow('Taxes', '₹${taxes.toInt()}'),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('₹${total.toInt()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ],
                    ),
                  ]),
                ],
              ),
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  color: AppColors.background,
                  child: buildHeader('Review Booking', 'Confirm details before payment'),
                ),
              ),
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.background.withOpacity(0.95), border: Border(top: BorderSide(color: AppColors.border))),
                  child: ElevatedButton(
                    onPressed: () => setState(() => _step = 'payment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text('Proceed to Payment', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 80, 16, 100),
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Icon(LucideIcons.shieldCheck, size: 16, color: Colors.teal),
                      const SizedBox(width: 8),
                      Text('Secured by 256-bit encryption', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.teal)),
                    ],
                  ),
                ),
                Text('Select Payment Method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 12),
                ...payMethods.map((m) {
                  final isSelected = _payMethod == m['id'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => setState(() => _payMethod = m['id'] as String),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                          border: Border.all(color: isSelected ? AppColors.primary.withOpacity(0.3) : AppColors.border),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(
                                gradient: isSelected ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                                color: isSelected ? null : AppColors.muted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(m['icon'] as IconData, size: 18, color: isSelected ? AppColors.primaryForeground : AppColors.mutedForeground),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(m['label'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  Text(m['desc'] as String, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                            Container(
                              width: 20, height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: isSelected ? AppColors.primary : AppColors.mutedForeground, width: 2),
                                color: isSelected ? AppColors.primary : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: isSelected ? Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.primaryForeground, shape: BoxShape.circle)) : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(
                color: AppColors.background,
                child: buildHeader('Payment', '₹${total.toInt()} • ${vendor.name}'),
              ),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.background.withOpacity(0.95), border: Border(top: BorderSide(color: AppColors.border))),
                child: ElevatedButton(
                  onPressed: () {
                    final num = 'ORD-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase()}';
                    final booking = ServiceBooking(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      orderNumber: num,
                      serviceId: service.id,
                      serviceName: service.name,
                      vendorId: vendor.id,
                      vendorName: vendor.name,
                      packageName: pkg.name,
                      servicePrice: pkg.price.toDouble(),
                      platformFee: platformFee,
                      taxes: taxes,
                      total: total,
                      paymentMethod: _payMethod.toUpperCase(),
                      status: 'Confirmed',
                      bookedAt: DateTime.now().toIso8601String(),
                      eventName: _eventName,
                      eventType: _eventType,
                      eventDate: _eventDate,
                      startTime: _startTime,
                      endTime: _endTime,
                      venueName: _venueName,
                      city: _city,
                      guests: int.tryParse(_guests) ?? 0,
                      specialRequirements: _specialRequirements,
                      visibility: 'private',
                    );
                    ref.read(appProvider.notifier).addServiceBooking(booking);
                    setState(() {
                      _confirmed = booking;
                      _step = 'success';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Pay ₹${total.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, bool required, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.toUpperCase(),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground, letterSpacing: 1),
              children: [
                if (required) TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: AppColors.mutedForeground),
      filled: true,
      fillColor: AppColors.secondary,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      isDense: true,
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground, letterSpacing: 1)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
          Expanded(child: Text(val, textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.foreground))),
        ],
      ),
    );
  }
}
