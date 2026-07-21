import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../core/models/app_models.dart';

class ServiceProviderCalendarScreen extends ConsumerStatefulWidget {
  const ServiceProviderCalendarScreen({super.key});

  @override
  ConsumerState<ServiceProviderCalendarScreen> createState() => _ServiceProviderCalendarScreenState();
}

class _ServiceProviderCalendarScreenState extends ConsumerState<ServiceProviderCalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final vendorId = appState.serviceProvider.vendorId.isNotEmpty ? appState.serviceProvider.vendorId : 'v1';
    final allGigs = appState.serviceRequests.where((r) => r.vendorId == vendorId && r.status == 'Confirmed').toList();

    // Filter gigs for selected date (match eventDate string) — show all as fallback
    final gigsOnDate = allGigs.isNotEmpty ? allGigs : appState.serviceRequests.where((r) => r.status == 'Confirmed').toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('Calendar', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              _buildCalendarHeader(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
                  itemCount: gigsOnDate.length,
                  itemBuilder: (context, index) {
                    final gig = gigsOnDate[index];
                    return _buildGigCard(gig);
                  },
                ),
              ),
            ],
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      color: AppColors.card,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(LucideIcons.chevronLeft, color: AppColors.foreground),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                    });
                  },
                ),
                Text(
                  '${_monthName(_selectedDate.month)} ${_selectedDate.year}',
                  style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(LucideIcons.chevronRight, color: AppColors.foreground),
                  onPressed: () {
                    setState(() {
                      _selectedDate = _selectedDate.add(const Duration(days: 7));
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Simplified horizontal date scroller
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(14, (index) {
                final date = _selectedDate.subtract(Duration(days: 3)).add(Duration(days: index));
                final isSelected = date.day == _selectedDate.day && date.month == _selectedDate.month;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _weekdayName(date.weekday),
                          style: TextStyle(
                            color: isSelected ? AppColors.primaryForeground : AppColors.mutedForeground,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${date.day}',
                          style: TextStyle(
                            color: isSelected ? AppColors.primaryForeground : AppColors.foreground,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGigCard(ServiceRequest gig) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('6:00', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 16)),
                Text('PM', style: TextStyle(color: AppColors.primary, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wedding Reception', style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(LucideIcons.mapPin, size: 14, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Text('Taj Lands End, Mumbai', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Photography', style: TextStyle(color: AppColors.mutedForeground, fontSize: 10)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('${gig.duration}', style: TextStyle(color: AppColors.mutedForeground, fontSize: 10)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _weekdayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }
}
