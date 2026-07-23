import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class _Category {
  final String id;
  final String label;
  final String emoji;
  const _Category(this.id, this.label, this.emoji);
}

const _categories = [
  _Category('music', 'Music', '🎵'),
  _Category('sports', 'Sports', '⚽'),
  _Category('comedy', 'Comedy', '😂'),
  _Category('nightlife', 'Nightlife', '🌙'),
  _Category('arts', 'Arts', '🎨'),
  _Category('performances', 'Performances', '🎭'),
  _Category('food', 'Food & Drink', '🍹'),
  _Category('tech', 'Tech & Business', '💻'),
  _Category('fitness', 'Fitness', '🏋️'),
  _Category('wellness', 'Wellness', '🧘'),
];

const _cities = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Chennai', 'Pune', 'Kolkata', 'Ahmedabad', 'Jaipur', 'Goa'];

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final List<String> _selectedCats = ['music', 'comedy'];
  final List<String> _selectedCities = ['Mumbai', 'Bangalore'];
  double _priceRange = 5000;
  bool _emailNotif = true;
  bool _pushNotif = true;
  bool _smsNotif = false;
  bool _saved = false;
  String _citySearch = '';

  void _toggleCat(String id) {
    setState(() {
      if (_selectedCats.contains(id)) {
        _selectedCats.remove(id);
      } else {
        _selectedCats.add(id);
      }
    });
  }

  void _toggleCity(String city) {
    setState(() {
      if (_selectedCities.contains(city)) {
        _selectedCities.remove(city);
      } else {
        _selectedCities.add(city);
      }
    });
  }

  void _handleSave() {
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _saved = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCities = _cities.where((c) => c.toLowerCase().contains(_citySearch.toLowerCase())).toList();

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
                    padding: const EdgeInsets.all(16),
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Preferences', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              Text('Personalize your event experience', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Categories
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Event Interests', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('Select categories you love', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _categories.map((cat) {
                            final active = _selectedCats.contains(cat.id);
                            return InkWell(
                              onTap: () => _toggleCat(cat.id),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: active ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                                  color: active ? null : AppColors.secondary,
                                  border: Border.all(color: active ? AppColors.primary.withOpacity(0.5) : AppColors.border),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(cat.emoji, style: const TextStyle(fontSize: 12)),
                                    const SizedBox(width: 4),
                                    Text(cat.label, style: TextStyle(color: active ? AppColors.primaryForeground : AppColors.mutedForeground, fontSize: 12, fontWeight: FontWeight.bold)),
                                    if (active) ...[
                                      const SizedBox(width: 4),
                                      Icon(LucideIcons.check, size: 12, color: AppColors.primaryForeground),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_selectedCats.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text('Please select at least one category', style: TextStyle(color: AppColors.destructive, fontSize: 12)),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Cities
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preferred Cities', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('Get events from your favourite cities', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (val) => setState(() => _citySearch = val),
                          style: TextStyle(color: AppColors.foreground, fontSize: 14),
                          decoration: InputDecoration(
                            prefixIcon: Icon(LucideIcons.mapPin, size: 16, color: AppColors.mutedForeground),
                            hintText: 'Search city...',
                            hintStyle: TextStyle(color: AppColors.mutedForeground),
                            filled: true,
                            fillColor: AppColors.input,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: filteredCities.map((city) {
                            final active = _selectedCities.contains(city);
                            return InkWell(
                              onTap: () => _toggleCity(city),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: active ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                                  color: active ? null : AppColors.secondary,
                                  border: Border.all(color: active ? AppColors.primary.withOpacity(0.5) : AppColors.border),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(LucideIcons.mapPin, size: 10, color: active ? AppColors.primaryForeground : AppColors.mutedForeground),
                                    const SizedBox(width: 4),
                                    Text(city, style: TextStyle(color: active ? AppColors.primaryForeground : AppColors.mutedForeground, fontSize: 12, fontWeight: FontWeight.bold)),
                                    if (active) ...[
                                      const SizedBox(width: 4),
                                      Icon(LucideIcons.check, size: 12, color: AppColors.primaryForeground),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Price Range
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price Range', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('Filter events by ticket price', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('₹0', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 14)),
                                  Text('₹${_priceRange.toInt()}', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold, fontSize: 14)),
                                ],
                              ),
                              SliderTheme(
                                data: SliderThemeData(
                                  activeTrackColor: AppColors.primary,
                                  inactiveTrackColor: AppColors.muted,
                                  thumbColor: AppColors.primary,
                                  overlayColor: AppColors.primary.withOpacity(0.2),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: _priceRange,
                                  min: 0,
                                  max: 10000,
                                  divisions: 100,
                                  onChanged: (val) => setState(() => _priceRange = val),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Free', style: TextStyle(color: AppColors.mutedForeground, fontSize: 10)),
                                  Text('₹10,000+', style: TextStyle(color: AppColors.mutedForeground, fontSize: 10)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildPricePreset(500),
                                  const SizedBox(width: 8),
                                  _buildPricePreset(1000),
                                  const SizedBox(width: 8),
                                  _buildPricePreset(2500),
                                  const SizedBox(width: 8),
                                  _buildPricePreset(5000),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notification Preferences
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Notification Preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              _buildToggle('Email Notifications', 'Booking confirmations & offers', _emailNotif, (v) => setState(() => _emailNotif = v), true),
                              _buildToggle('Push Notifications', 'Real-time alerts & reminders', _pushNotif, (v) => setState(() => _pushNotif = v), true),
                              _buildToggle('SMS Alerts', 'OTP & booking updates', _smsNotif, (v) => setState(() => _smsNotif = v), false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: _handleSave,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: _saved ? null : LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                          color: _saved ? Colors.green.withOpacity(0.2) : null,
                          border: _saved ? Border.all(color: Colors.green.withOpacity(0.3)) : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _saved ? '✓ Preferences Saved!' : 'Save Preferences',
                            style: TextStyle(
                              color: _saved ? Colors.green : AppColors.primaryForeground,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
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

  Widget _buildPricePreset(int value) {
    final active = _priceRange == value;
    final text = value >= 1000 ? '${value ~/ 1000}k' : '$value';
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _priceRange = value.toDouble()),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.muted,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: active ? AppColors.primary : AppColors.border),
          ),
          child: Center(
            child: Text('₹$text', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: active ? AppColors.primaryForeground : AppColors.mutedForeground)),
          ),
        ),
      ),
    );
  }

  Widget _buildToggle(String label, String desc, bool value, Function(bool) onChanged, bool bottomBorder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: bottomBorder ? Border(bottom: BorderSide(color: AppColors.border)) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(desc, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.muted,
          ),
        ],
      ),
    );
  }
}
