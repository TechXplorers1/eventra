import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/data/services_marketplace_data.dart';

const List<String> eventTypes = [
  'Wedding', 'Concert', 'Corporate', 'Birthday', 'College Fest', 'Conference', 'Festival', 'Other'
];

const List<Map<String, dynamic>> payMethods = [
  {'id': 'upi', 'label': 'UPI', 'icon': LucideIcons.smartphone, 'desc': 'GPay, PhonePe, Paytm'},
  {'id': 'card', 'label': 'Card', 'icon': LucideIcons.creditCard, 'desc': 'Credit / Debit'},
  {'id': 'netbanking', 'label': 'Net Banking', 'icon': LucideIcons.building2, 'desc': 'All major banks'},
  {'id': 'wallet', 'label': 'Wallet', 'icon': LucideIcons.wallet, 'desc': 'Paytm, Amazon Pay'},
];

class ServiceBookingScreen extends ConsumerStatefulWidget {
  final String serviceId;
  final String vendorId;
  const ServiceBookingScreen({
    super.key,
    required this.serviceId,
    required this.vendorId,
  });

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

  // Track scroll controllers if needed, but not strictly necessary for simple list
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    UserService? tryGetService() {
      try {
        return findUserService(widget.serviceId);
      } catch (_) {
        return null;
      }
    }
    final service = tryGetService();

    Vendor? tryGetVendor() {
      try {
        if (service != null) return getVendor(service.id, widget.vendorId, service.startingPrice);
      } catch (_) {}
      return null;
    }
    final vendor = tryGetVendor();

    final pkgs = vendor?.packages ?? [];
    
    // Auto-select package if not found
    if (pkgs.isNotEmpty && !pkgs.any((p) => p.name == _pkgName)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _pkgName = pkgs.first.name);
      });
    }

    final pkg = pkgs.isEmpty
        ? null
        : pkgs.firstWhere(
            (p) => p.name == _pkgName,
            orElse: () => pkgs.first,
          );

    if (service == null || vendor == null || pkg == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/');
              }
            },
          ),
        ),
        body: Center(
          child: Text(
            'Booking unavailable',
            style: TextStyle(fontSize: 18, color: AppColors.mutedForeground),
          ),
        ),
      );
    }

    final platformFee = pkg.price * 0.02;
    final taxes = pkg.price * 0.18;
    final total = pkg.price + platformFee + taxes;

    switch (_step) {
      case 'form':
        return _buildFormStep(context, service, vendor, pkgs, pkg);
      case 'review':
        return _buildReviewStep(context, service, vendor, pkg, platformFee, taxes, total);
      case 'payment':
        return _buildPaymentStep(context, vendor, total, service, pkg, platformFee, taxes);
      case 'success':
        return _buildSuccessStep(context);
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // STEP 1: FORM
  // ==========================================
  Widget _buildFormStep(
    BuildContext context,
    UserService service,
    Vendor vendor,
    List<VendorPackage> pkgs,
    VendorPackage currentPkg,
  ) {
    final canContinue = _eventName.isNotEmpty &&
        _eventDate.isNotEmpty &&
        _startTime.isNotEmpty &&
        _endTime.isNotEmpty &&
        _venueName.isNotEmpty &&
        _city.isNotEmpty &&
        _guests.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar('Book Service', '${vendor.name} • ${service.name}'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          children: [
            // Vendor Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      vendor.name.substring(0, 2).toUpperCase(),
                      style: TextStyle(color: AppColors.primaryForeground, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(vendor.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(LucideIcons.star, size: 14, color: Colors.orangeAccent),
                            const SizedBox(width: 4),
                            Text('${vendor.rating} (${vendor.reviews})', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Package Selection
            Text('Select Package', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: pkgs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = pkgs[index];
                  final isSelected = _pkgName == p.name;
                  return GestureDetector(
                    onTap: () => setState(() => _pkgName = p.name),
                    child: Container(
                      width: 140,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 2 : 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(p.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          const SizedBox(height: 8),
                          Text('₹${p.price}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primary : AppColors.foreground)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Current Package Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: currentPkg.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(LucideIcons.checkCircle2, size: 16, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text(f, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground))),
                    ],
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 32),

            // Event Details Form
            Text('Event Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 16),

            _buildTextField(label: 'EVENT NAME *', hint: 'e.g. Rohan & Priya Sangeet', initialValue: _eventName, onChanged: (v) => setState(() => _eventName = v)),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
              child: Text('EVENT TYPE *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _eventType,
                  isExpanded: true,
                  dropdownColor: AppColors.card,
                  icon: Icon(LucideIcons.chevronDown, color: AppColors.mutedForeground),
                  style: TextStyle(color: AppColors.foreground, fontSize: 14),
                  onChanged: (v) => setState(() => _eventType = v!),
                  items: eventTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                ),
              ),
            ),

            Row(
              children: [
                Expanded(child: _buildTextField(
                  label: 'DATE *', 
                  hint: 'YYYY-MM-DD', 
                  initialValue: _eventDate, 
                  onChanged: (v) {},
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2030),
                    );
                    if (date != null) {
                      setState(() => _eventDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
                    }
                  }
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(
                  label: 'START *', 
                  hint: 'HH:MM', 
                  initialValue: _startTime, 
                  onChanged: (v) {},
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null && context.mounted) {
                      setState(() => _startTime = time.format(context));
                    }
                  }
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildTextField(
                  label: 'END *', 
                  hint: 'HH:MM', 
                  initialValue: _endTime, 
                  onChanged: (v) {},
                  readOnly: true,
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                    if (time != null && context.mounted) {
                      setState(() => _endTime = time.format(context));
                    }
                  }
                )),
              ],
            ),

            Row(
              children: [
                Expanded(flex: 2, child: _buildTextField(label: 'VENUE NAME *', hint: 'e.g. Taj Palace', initialValue: _venueName, onChanged: (v) => setState(() => _venueName = v))),
                const SizedBox(width: 12),
                Expanded(flex: 1, child: _buildTextField(label: 'CITY *', hint: 'e.g. Mumbai', initialValue: _city, onChanged: (v) => setState(() => _city = v))),
              ],
            ),

            _buildTextField(label: 'GUESTS *', hint: 'Number of guests', initialValue: _guests, keyboardType: TextInputType.number, onChanged: (v) => setState(() => _guests = v)),
            _buildTextField(label: 'SPECIAL REQUIREMENTS', hint: 'Any additional notes for the vendor...', initialValue: _specialRequirements, maxLines: 3, onChanged: (v) => setState(() => _specialRequirements = v)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(
        buttonText: 'Review Booking',
        isEnabled: true,
        onPressed: () {
          if (!canContinue) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Please fill all required fields (*) to continue'),
                backgroundColor: AppColors.destructive,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          // Unfocus keyboard before navigating to next step
          FocusScope.of(context).unfocus();
          setState(() => _step = 'review');
        },
      ),
    );
  }

  // ==========================================
  // STEP 2: REVIEW
  // ==========================================
  Widget _buildReviewStep(
    BuildContext context,
    UserService service,
    Vendor vendor,
    VendorPackage pkg,
    double platformFee,
    double taxes,
    double total,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar('Review Booking', 'Confirm details before payment', onBack: () => setState(() => _step = 'form')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          _buildSummaryCard('Service Info', [
            _buildSummaryRow('Provider', vendor.name),
            _buildSummaryRow('Service', service.name),
            _buildSummaryRow('Package', '${pkg.name} • ₹${pkg.price}'),
            _buildSummaryRow('Duration', '$_startTime – $_endTime'),
          ]),
          const SizedBox(height: 16),
          _buildSummaryCard('Event Details', [
            _buildSummaryRow('Event', _eventName),
            _buildSummaryRow('Type', _eventType),
            _buildSummaryRow('Date', _eventDate),
            _buildSummaryRow('Venue', '$_venueName, $_city'),
            _buildSummaryRow('Guests', _guests),
            if (_specialRequirements.isNotEmpty) _buildSummaryRow('Notes', _specialRequirements),
          ]),
          const SizedBox(height: 16),
          _buildSummaryCard('Pricing Breakdown', [
            _buildSummaryRow('Service Fee', '₹${pkg.price}'),
            _buildSummaryRow('Platform Fee', '₹${platformFee.toInt()}'),
            _buildSummaryRow('Taxes', '₹${taxes.toInt()}'),
            Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Divider(color: AppColors.border)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Amount', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                Text('₹${total.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ]),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(
        buttonText: 'Proceed to Payment',
        isEnabled: true,
        onPressed: () => setState(() => _step = 'payment'),
      ),
    );
  }

  // ==========================================
  // STEP 3: PAYMENT
  // ==========================================
  Widget _buildPaymentStep(
    BuildContext context,
    Vendor vendor,
    double total,
    UserService service,
    VendorPackage pkg,
    double platformFee,
    double taxes,
  ) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar('Payment', '₹${total.toInt()} • ${vendor.name}', onBack: () => setState(() => _step = 'review')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                Icon(LucideIcons.shieldCheck, size: 20, color: Colors.teal),
                const SizedBox(width: 12),
                Expanded(child: Text('Secured by 256-bit encryption. Your payment is safe.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.teal))),
              ],
            ),
          ),
          Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 16),
          ...payMethods.map((m) {
            final isSelected = _payMethod == m['id'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => setState(() => _payMethod = m['id'] as String),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                    border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                          color: isSelected ? null : AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(m['icon'] as IconData, size: 24, color: isSelected ? AppColors.primaryForeground : AppColors.mutedForeground),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(m['label'] as String, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                            Text(m['desc'] as String, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isSelected ? AppColors.primary : AppColors.mutedForeground, width: 2),
                          color: isSelected ? AppColors.primary : Colors.transparent,
                        ),
                        alignment: Alignment.center,
                        child: isSelected ? Container(width: 10, height: 10, decoration: BoxDecoration(color: AppColors.primaryForeground, shape: BoxShape.circle)) : null,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(
        buttonText: 'Pay ₹${total.toInt()} Securely',
        isEnabled: true,
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
      ),
    );
  }

  // ==========================================
  // STEP 4: SUCCESS
  // ==========================================
  Widget _buildSuccessStep(BuildContext context) {
    if (_confirmed == null) return const SizedBox.shrink();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30, spreadRadius: 10)],
                  ),
                  child: Icon(LucideIcons.checkCircle2, size: 48, color: AppColors.primaryForeground),
                ),
                const SizedBox(height: 32),
                Text('Booking Confirmed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.foreground), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                Text('Your booking with ${_confirmed!.vendorName} was successful. Details have been saved to your account.', 
                  style: TextStyle(fontSize: 15, color: AppColors.mutedForeground, height: 1.5), textAlign: TextAlign.center),
                const SizedBox(height: 40),
                
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.card, 
                    border: Border.all(color: AppColors.border), 
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: Column(
                    children: [
                      _buildSummaryRow('Order Number', _confirmed!.orderNumber),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Booking ID', 'BKG-${_confirmed!.id.substring(_confirmed!.id.length > 8 ? _confirmed!.id.length - 8 : 0).toUpperCase()}'),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Service', _confirmed!.serviceName),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Package', _confirmed!.packageName),
                      const SizedBox(height: 12),
                      _buildSummaryRow('Event', _confirmed!.eventName),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => context.go('/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Back to Home', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================

  AppBar _buildAppBar(String title, String subtitle, {VoidCallback? onBack}) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(LucideIcons.arrowLeft, color: AppColors.foreground),
        onPressed: onBack ?? () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/');
          }
        },
      ),
      title: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }

  Widget _buildBottomBar({required String buttonText, required bool isEnabled, required VoidCallback onPressed}) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.3),
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isEnabled ? AppColors.primaryForeground : AppColors.primaryForeground.withOpacity(0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required String initialValue,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4),
            child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
          ),
          TextFormField(
            key: readOnly ? ValueKey(initialValue) : null,
            initialValue: initialValue,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            onChanged: onChanged,
            style: TextStyle(color: AppColors.foreground, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.mutedForeground),
              filled: true,
              fillColor: AppColors.secondary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground))),
          Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.foreground), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
