import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class _ProviderPackage {
  final String id;
  final String name;
  final double price;
  final String type; // Basic, Standard, Premium
  final String description;
  final List<String> features;
  final bool active;
  final int bookings;

  _ProviderPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.type,
    required this.description,
    required this.features,
    required this.active,
    required this.bookings,
  });

  _ProviderPackage copyWith({
    String? id,
    String? name,
    double? price,
    String? type,
    String? description,
    List<String>? features,
    bool? active,
    int? bookings,
  }) {
    return _ProviderPackage(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      type: type ?? this.type,
      description: description ?? this.description,
      features: features ?? this.features,
      active: active ?? this.active,
      bookings: bookings ?? this.bookings,
    );
  }
}

class ServiceProviderPackagesScreen extends ConsumerStatefulWidget {
  const ServiceProviderPackagesScreen({super.key});

  @override
  ConsumerState<ServiceProviderPackagesScreen> createState() => _ServiceProviderPackagesScreenState();
}

class _ServiceProviderPackagesScreenState extends ConsumerState<ServiceProviderPackagesScreen> {
  bool _editMode = false;
  List<_ProviderPackage> _items = [
    _ProviderPackage(
      id: 'pkg-1',
      name: 'Essential Coverage',
      price: 15000,
      type: 'Basic',
      description: '4 hours of event coverage with 1 photographer.',
      features: ['1 Photographer', '4 Hours Coverage', '100 Edited Photos'],
      active: true,
      bookings: 12,
    ),
    _ProviderPackage(
      id: 'pkg-2',
      name: 'Standard Package',
      price: 25000,
      type: 'Standard',
      description: 'Full day coverage with traditional and candid photography.',
      features: ['2 Photographers', '8 Hours Coverage', '250 Edited Photos', 'Teaser Video'],
      active: true,
      bookings: 28,
    ),
  ];

  void _remove(String id) {
    setState(() => _items.removeWhere((p) => p.id == id));
  }

  void _duplicate(_ProviderPackage p) {
    setState(() {
      _items.add(p.copyWith(
        id: '${p.id}-${DateTime.now().millisecondsSinceEpoch}',
        name: '${p.name} (Copy)',
        bookings: 0,
      ));
    });
  }

  void _toggleActive(String id) {
    setState(() {
      final idx = _items.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _items[idx] = _items[idx].copyWith(active: !_items[idx].active);
      }
    });
  }

  void _showModal({_ProviderPackage? pkg}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PackageModal(
        pkg: pkg,
        onSave: (data) {
          setState(() {
            if (pkg != null) {
              final idx = _items.indexWhere((p) => p.id == pkg.id);
              if (idx != -1) {
                _items[idx] = _items[idx].copyWith(
                  name: data['name'],
                  price: data['price'],
                  type: data['type'],
                  description: data['description'],
                  features: data['features'],
                );
              }
            } else {
              _items.add(_ProviderPackage(
                id: 'pkg-${DateTime.now().millisecondsSinceEpoch}',
                name: data['name'],
                price: data['price'],
                type: data['type'],
                description: data['description'],
                features: data['features'],
                active: true,
                bookings: 0,
              ));
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalBookings = _items.fold(0, (s, p) => s + p.bookings);
    double revenue = _items.fold(0.0, (s, p) => s + (p.price * p.bookings));
    _ProviderPackage? mostBooked;
    if (_items.isNotEmpty) {
      mostBooked = _items.reduce((a, b) => a.bookings > b.bookings ? a : b);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
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
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            child: Icon(LucideIcons.arrowLeft, size: 18, color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SERVICE MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5)),
                              Text('Packages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => setState(() => _editMode = !_editMode),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              gradient: _editMode ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                              color: _editMode ? null : AppColors.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_editMode ? LucideIcons.check : LucideIcons.pencil, size: 16, color: _editMode ? AppColors.primaryForeground : AppColors.foreground),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Analytics
                  if (_items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(child: _buildStat(LucideIcons.package, 'Total Packages', '${_items.length}')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStat(LucideIcons.trendingUp, 'Total Bookings', '$totalBookings')),
                        ],
                      ),
                    ),
                  if (_items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          Expanded(child: _buildStat(LucideIcons.star, 'Most Booked', mostBooked?.name.split(' ')[0] ?? '—')),
                          const SizedBox(width: 12),
                          Expanded(child: _buildStat(LucideIcons.trendingUp, 'Revenue', '₹${(revenue / 1000).toStringAsFixed(0)}K')),
                        ],
                      ),
                    ),

                  // Packages List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _items.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border, style: BorderStyle.solid)), // Using solid since dashed isn't native without package
                            child: Column(
                              children: [
                                Icon(LucideIcons.package, size: 28, color: AppColors.mutedForeground),
                                const SizedBox(height: 8),
                                Text('No packages created yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                const SizedBox(height: 4),
                                Text('Create your first package to start receiving bookings.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () => _showModal(),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                                  child: const Text('Create Package', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              ..._items.map((p) {
                                final badgeColor = p.type == 'Basic' ? Colors.blue : p.type == 'Premium' ? Colors.orange : AppColors.primary;
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: p.active ? AppColors.border : AppColors.border.withOpacity(0.4)),
                                  ),
                                  child: Opacity(
                                    opacity: p.active ? 1.0 : 0.6,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(color: badgeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                                        child: Text(p.type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor)),
                                                      ),
                                                      if (!p.active) ...[
                                                        const SizedBox(width: 4),
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                          decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                                                          child: Text('Inactive', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(p.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                                  const SizedBox(height: 2),
                                                  Text(p.description, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                ],
                                              ),
                                            ),
                                            Text('₹${p.price.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        ...p.features.map((f) => Padding(
                                          padding: const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              Icon(LucideIcons.check, size: 12, color: Colors.greenAccent),
                                              const SizedBox(width: 6),
                                              Expanded(child: Text(f, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                                            ],
                                          ),
                                        )),
                                        const SizedBox(height: 8),
                                        Divider(color: AppColors.border),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('${p.bookings} bookings', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                            _editMode
                                                ? Row(
                                                    children: [
                                                      _buildIconBtn(LucideIcons.pencil, () => _showModal(pkg: p)),
                                                      const SizedBox(width: 4),
                                                      _buildIconBtn(LucideIcons.copy, () => _duplicate(p)),
                                                      const SizedBox(width: 4),
                                                      _buildIconBtn(p.active ? LucideIcons.x : LucideIcons.check, () => _toggleActive(p.id)),
                                                      const SizedBox(width: 4),
                                                      _buildIconBtn(LucideIcons.trash2, () => _remove(p.id), danger: true),
                                                    ],
                                                  )
                                                : InkWell(
                                                    onTap: () => _showModal(pkg: p),
                                                    child: Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                              if (_items.isNotEmpty)
                                InkWell(
                                  onTap: () => _showModal(),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(border: Border.all(color: AppColors.primary.withOpacity(0.4)), borderRadius: BorderRadius.circular(16)),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Text('Add Package', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.secondary, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }

  Widget _buildIconBtn(IconData icon, VoidCallback onTap, {bool danger = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28, height: 28,
        decoration: BoxDecoration(color: danger ? AppColors.destructive.withOpacity(0.1) : AppColors.muted, shape: BoxShape.circle),
        child: Icon(icon, size: 12, color: danger ? AppColors.destructive : AppColors.foreground),
      ),
    );
  }
}

class _PackageModal extends StatefulWidget {
  final _ProviderPackage? pkg;
  final Function(Map<String, dynamic>) onSave;

  const _PackageModal({this.pkg, required this.onSave});

  @override
  State<_PackageModal> createState() => _PackageModalState();
}

class _PackageModalState extends State<_PackageModal> {
  late String name;
  late String price;
  late String type;
  late String description;
  late List<String> features;

  @override
  void initState() {
    super.initState();
    name = widget.pkg?.name ?? '';
    price = widget.pkg?.price.toString() ?? '';
    type = widget.pkg?.type ?? 'Standard';
    description = widget.pkg?.description ?? '';
    features = widget.pkg != null ? List.from(widget.pkg!.features) : [''];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.pkg == null ? 'Add Package' : 'Edit Package', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                    child: Icon(LucideIcons.x, size: 16, color: AppColors.foreground),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildField('Package Name', TextField(
                    controller: TextEditingController(text: name)..selection = TextSelection.collapsed(offset: name.length),
                    onChanged: (v) => name = v,
                    style: TextStyle(color: AppColors.foreground, fontSize: 13),
                    decoration: _inputDeco(),
                  )),
                  _buildField('Price (₹)', TextField(
                    controller: TextEditingController(text: price)..selection = TextSelection.collapsed(offset: price.length),
                    onChanged: (v) => price = v,
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: AppColors.foreground, fontSize: 13),
                    decoration: _inputDeco(),
                  )),
                  _buildField('Tier', Row(
                    children: ['Basic', 'Standard', 'Premium'].map((t) {
                      final active = type == t;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => type = t),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                gradient: active ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                                color: active ? null : AppColors.secondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: active ? AppColors.primaryForeground : AppColors.mutedForeground)),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),
                  _buildField('Description', TextField(
                    controller: TextEditingController(text: description)..selection = TextSelection.collapsed(offset: description.length),
                    onChanged: (v) => description = v,
                    maxLines: 2,
                    style: TextStyle(color: AppColors.foreground, fontSize: 13),
                    decoration: _inputDeco(),
                  )),
                  _buildField('Features / Inclusions', Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...features.asMap().entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextField(
                          controller: TextEditingController(text: e.value)..selection = TextSelection.collapsed(offset: e.value.length),
                          onChanged: (v) => features[e.key] = v,
                          style: TextStyle(color: AppColors.foreground, fontSize: 13),
                          decoration: _inputDeco(),
                        ),
                      )),
                      InkWell(
                        onTap: () => setState(() => features.add('')),
                        child: Text('+ Add feature', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ),
          Divider(color: AppColors.border, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Cancel', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave({
                        'name': name,
                        'price': double.tryParse(price) ?? 0.0,
                        'type': type,
                        'description': description,
                        'features': features.where((f) => f.trim().isNotEmpty).toList(),
                      });
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: Text('Save Package', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground, letterSpacing: 1)),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco() {
    return InputDecoration(
      filled: true,
      fillColor: AppColors.input,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      isDense: true,
    );
  }
}
