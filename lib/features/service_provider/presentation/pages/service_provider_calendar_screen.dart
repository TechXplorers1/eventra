import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../shared/widgets/bottom_nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────
String _dateKey(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime _parseKey(String key) {
  final p = key.split('-');
  return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
}

const _monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];
const _weekHeaders = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class ServiceProviderCalendarScreen extends ConsumerStatefulWidget {
  const ServiceProviderCalendarScreen({super.key});

  @override
  ConsumerState<ServiceProviderCalendarScreen> createState() =>
      _ServiceProviderCalendarScreenState();
}

class _ServiceProviderCalendarScreenState
    extends ConsumerState<ServiceProviderCalendarScreen> {
  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  // ── navigate months ────────────────────────────────────────────────────────
  void _prevMonth() => setState(
      () => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1));
  void _nextMonth() => setState(
      () => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1));

  // ── build calendar grid days ───────────────────────────────────────────────
  List<DateTime?> _buildGridDays() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final last = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    // weekday: Mon=1 … Sun=7; offset to make Mon the first column
    final startOffset = (first.weekday - 1) % 7;
    final total = startOffset + last.day;
    final cells = (total / 7).ceil() * 7;
    return List.generate(cells, (i) {
      final day = i - startOffset + 1;
      if (day < 1 || day > last.day) return null;
      return DateTime(_focusedMonth.year, _focusedMonth.month, day);
    });
  }

  // ── status for a date ─────────────────────────────────────────────────────
  _DayStatus _statusOf(
    DateTime d,
    List<String> blocked,
    List<CalendarEntry> entries,
    List<ServiceRequest> gigs,
    String vendorId,
    List<ServiceBooking> directBookings,
  ) {
    final key = _dateKey(d);
    final isBlocked = blocked.contains(key);
    final hasGig = gigs.any((r) {
      try {
        final gd = _parseKey(r.eventDate);
        return gd.year == d.year && gd.month == d.month && gd.day == d.day;
      } catch (_) {
        return false;
      }
    });
    final hasEntry = entries.any((e) => e.date == key);
    // Check direct bookings from attendees
    final hasDirectBooking = directBookings.any((b) {
      try {
        final gd = _parseKey(b.eventDate);
        return gd.year == d.year && gd.month == d.month && gd.day == d.day;
      } catch (_) {
        return false;
      }
    });
    return _DayStatus(isBlocked: isBlocked, hasGig: hasGig, hasEntry: hasEntry, hasDirectBooking: hasDirectBooking);
  }

  // ── tap on a day cell ─────────────────────────────────────────────────────
  void _onDayTap(DateTime day, List<ServiceRequest> gigs, String vendorId) {
    setState(() => _selectedDay = day);
    _showDaySheet(day, gigs, vendorId);
  }

  // ── bottom sheet ──────────────────────────────────────────────────────────
  void _showDaySheet(DateTime day, List<ServiceRequest> gigs, String vendorId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _DaySheet(day: day, gigs: gigs, vendorId: vendorId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final vendorId =
        state.serviceProvider.vendorId.isNotEmpty ? state.serviceProvider.vendorId : 'v1';
    final confirmedGigs =
        state.serviceRequests.where((r) => r.vendorId == vendorId && r.status == 'Confirmed').toList();
    final allGigs = state.serviceRequests.where((r) => r.status == 'Confirmed').toList();
    final displayGigs = confirmedGigs.isNotEmpty ? confirmedGigs : allGigs;
    // Fix 4: Include direct bookings from attendees
    final directBookings = state.serviceBookings.where((b) => b.vendorId == vendorId).toList();

    final gridDays = _buildGridDays();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text('My Calendar',
            style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.helpCircle, color: AppColors.mutedForeground, size: 20),
            onPressed: _showLegend,
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Month navigator ──────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _NavBtn(icon: LucideIcons.chevronLeft, onTap: _prevMonth),
                      Text(
                        '${_monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                        style: TextStyle(
                            color: AppColors.foreground,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      ),
                      _NavBtn(icon: LucideIcons.chevronRight, onTap: _nextMonth),
                    ],
                  ),
                ),

                // ── Week header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: _weekHeaders
                        .map((h) => Expanded(
                              child: Center(
                                child: Text(h,
                                    style: TextStyle(
                                        color: AppColors.mutedForeground,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 2),

                // ── Calendar grid ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: gridDays.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.4, // wide & short cells
                    ),
                    itemBuilder: (_, i) {
                      final day = gridDays[i];
                      if (day == null) return const SizedBox();
                      final status = _statusOf(
                          day,
                          state.blockedDates,
                          state.calendarEntries,
                          displayGigs,
                          vendorId,
                          directBookings);
                      final isSelected = _selectedDay != null &&
                          _selectedDay!.day == day.day &&
                          _selectedDay!.month == day.month &&
                          _selectedDay!.year == day.year;
                      final isToday = DateTime.now().day == day.day &&
                          DateTime.now().month == day.month &&
                          DateTime.now().year == day.year;
                      return _DayCell(
                        day: day,
                        isSelected: isSelected,
                        isToday: isToday,
                        status: status,
                        onTap: () => _onDayTap(day, displayGigs, vendorId),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 6),
                const Divider(height: 1),

                // ── Legend + Add/Block button ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Row(
                    children: [
                      _LegendDot(color: AppColors.primary, label: 'Booked'),
                      const SizedBox(width: 10),
                      _LegendDot(color: const Color(0xFF06B6D4), label: 'Direct'),
                      const SizedBox(width: 10),
                      _LegendDot(color: const Color(0xFFEF4444), label: 'Blocked'),
                      const SizedBox(width: 10),
                      _LegendDot(color: const Color(0xFFF59E0B), label: 'Custom'),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (_selectedDay != null) {
                            _showDaySheet(_selectedDay!, displayGigs, vendorId);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(LucideIcons.calendarPlus, size: 13, color: AppColors.primary),
                            const SizedBox(width: 5),
                            Text('Add / Block',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),
                const SizedBox(height: 4),

                // ── Selected day events list (inline, no Expanded needed) ──────
                if (_selectedDay != null)
                  _DayDetailList(
                    day: _selectedDay!,
                    gigs: displayGigs,
                    blockedDates: state.blockedDates,
                    calendarEntries: state.calendarEntries,
                    vendorId: vendorId,
                  ),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }


  void _showLegend() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Calendar Legend',
              style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _LegendRow(color: AppColors.primary, label: 'Booked Gig', desc: 'Confirmed service booking on this day'),
          _LegendRow(color: const Color(0xFFEF4444), label: 'Blocked Date', desc: 'You marked this day as unavailable'),
          _LegendRow(color: const Color(0xFFF59E0B), label: 'Custom Entry', desc: 'A note or personal event you added'),
          const SizedBox(height: 16),
          Text('Tap any date to view details, block it, or add a custom entry.',
              style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Cell
// ─────────────────────────────────────────────────────────────────────────────
class _DayStatus {
  final bool isBlocked;
  final bool hasGig;
  final bool hasEntry;
  final bool hasDirectBooking;
  const _DayStatus({required this.isBlocked, required this.hasGig, required this.hasEntry, this.hasDirectBooking = false});
}

class _DayCell extends StatelessWidget {
  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final _DayStatus status;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? bgColor;
    Color textColor = AppColors.foreground;
    Color borderColor = Colors.transparent;

    if (isSelected) {
      bgColor = AppColors.primary;
      textColor = Colors.white;
    } else if (status.isBlocked) {
      bgColor = const Color(0xFFEF4444).withOpacity(0.15);
      borderColor = const Color(0xFFEF4444).withOpacity(0.4);
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: bgColor ?? Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isToday && !isSelected ? AppColors.primary : borderColor, width: isToday && !isSelected ? 1.5 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontSize: 11,
                fontWeight: isToday || isSelected ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (status.hasGig) _Dot(color: isSelected ? Colors.white : AppColors.primary),
                if (status.hasDirectBooking && !status.hasGig) _Dot(color: isSelected ? Colors.white : const Color(0xFF06B6D4)),
                if (status.isBlocked && !isSelected) _Dot(color: const Color(0xFFEF4444)),
                if (status.hasEntry) _Dot(color: const Color(0xFFF59E0B)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) => Container(
        width: 4, height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Detail List (inline, below calendar)
// ─────────────────────────────────────────────────────────────────────────────
class _DayDetailList extends ConsumerWidget {
  final DateTime day;
  final List<ServiceRequest> gigs;
  final List<String> blockedDates;
  final List<CalendarEntry> calendarEntries;
  final String vendorId;

  const _DayDetailList({
    required this.day,
    required this.gigs,
    required this.blockedDates,
    required this.calendarEntries,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = _dateKey(day);
    final isBlocked = blockedDates.contains(key);

    final dayGigs = gigs.where((r) {
      try {
        final gd = _parseKey(r.eventDate);
        return gd.year == day.year && gd.month == day.month && gd.day == day.day;
      } catch (_) {
        return false;
      }
    }).toList();

    final dayEntries = calendarEntries.where((e) => e.date == key).toList();

    final hasNothing = !isBlocked && dayGigs.isEmpty && dayEntries.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Row(children: [
            Text(
              '${_monthNames[day.month - 1]} ${day.day}, ${day.year}',
              style: TextStyle(color: AppColors.foreground, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (isBlocked)
              _StatusChip(label: 'Blocked', color: const Color(0xFFEF4444)),
          ]),
          const SizedBox(height: 10),

          // Booked gigs
          ...dayGigs.map((g) => _GigTile(gig: g)),

          // Custom entries
          ...dayEntries.map((e) => _EntryTile(
              entry: e,
              onRemove: () => ref.read(appProvider.notifier).removeCalendarEntry(e.id))),

          // Empty state
          if (hasNothing)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Column(children: [
                  Icon(LucideIcons.calendarX, size: 32, color: AppColors.mutedForeground),
                  const SizedBox(height: 8),
                  Text('Nothing scheduled for this day',
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('Tap "Add / Block" above to manage this date',
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Day Bottom Sheet
// ─────────────────────────────────────────────────────────────────────────────
class _DaySheet extends ConsumerStatefulWidget {
  final DateTime day;
  final List<ServiceRequest> gigs;
  final String vendorId;
  const _DaySheet({required this.day, required this.gigs, required this.vendorId});

  @override
  ConsumerState<_DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends ConsumerState<_DaySheet> {
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _addingEntry = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final key = _dateKey(widget.day);
    final isBlocked = state.blockedDates.contains(key);

    final dayGigs = widget.gigs.where((r) {
      try {
        final gd = _parseKey(r.eventDate);
        return gd.year == widget.day.year &&
            gd.month == widget.day.month &&
            gd.day == widget.day.day;
      } catch (_) {
        return false;
      }
    }).toList();

    final dayEntries = state.calendarEntries.where((e) => e.date == key).toList();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title row
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(
                      '${_monthNames[widget.day.month - 1]} ${widget.day.day}, ${widget.day.year}',
                      style: TextStyle(
                          color: AppColors.foreground, fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                    if (isBlocked)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: _StatusChip(label: '🔒 Blocked — Unavailable', color: const Color(0xFFEF4444)),
                      ),
                  ]),
                ),
              ]),
              const SizedBox(height: 20),

              // Block / Unblock button
              _SheetActionBtn(
                icon: isBlocked ? LucideIcons.calendarCheck : LucideIcons.calendarOff,
                label: isBlocked ? 'Unblock This Date' : 'Block This Date',
                subtitle: isBlocked
                    ? 'Mark yourself as available again'
                    : 'Mark yourself as unavailable on this day',
                color: isBlocked ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                onTap: () {
                  ref.read(appProvider.notifier).toggleBlockDate(key);
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 10),

              // Add custom entry button
              _SheetActionBtn(
                icon: LucideIcons.plus,
                label: 'Add Custom Entry',
                subtitle: 'Add a personal event or reminder',
                color: const Color(0xFFF59E0B),
                onTap: () => setState(() => _addingEntry = !_addingEntry),
              ),

              // Add entry form
              if (_addingEntry) ...[
                const SizedBox(height: 14),
                _InputField(controller: _titleCtrl, hint: 'Entry title (e.g. Personal Event)'),
                const SizedBox(height: 8),
                _InputField(controller: _noteCtrl, hint: 'Note (optional)', maxLines: 2),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => _addingEntry = false),
                      child: Text('Cancel', style: TextStyle(color: AppColors.mutedForeground)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        final t = _titleCtrl.text.trim();
                        if (t.isEmpty) return;
                        ref.read(appProvider.notifier).addCalendarEntry(CalendarEntry(
                          id: 'CE${DateTime.now().millisecondsSinceEpoch}',
                          date: key,
                          title: t,
                          note: _noteCtrl.text.trim(),
                          type: 'event',
                        ));
                        _titleCtrl.clear();
                        _noteCtrl.clear();
                        setState(() => _addingEntry = false);
                      },
                      child: const Text('Save Entry'),
                    ),
                  ),
                ]),
              ],

              // Booked gigs on this day
              if (dayGigs.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text('Booked Gigs',
                    style: TextStyle(
                        color: AppColors.foreground, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...dayGigs.map((g) => _GigTile(gig: g)),
              ],

              // Custom entries on this day
              if (dayEntries.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('Custom Entries',
                    style: TextStyle(
                        color: AppColors.foreground, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                ...dayEntries.map((e) => _EntryTile(
                      entry: e,
                      onRemove: () => ref.read(appProvider.notifier).removeCalendarEntry(e.id),
                    )),
              ],

              if (dayGigs.isEmpty && dayEntries.isEmpty && !_addingEntry) ...[
                const SizedBox(height: 20),
                Center(
                  child: Text('Nothing scheduled for this day.',
                      style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable small widgets
// ─────────────────────────────────────────────────────────────────────────────

class _GigTile extends StatelessWidget {
  final ServiceRequest gig;
  const _GigTile({required this.gig});

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.foreground, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(gig.categoryName, style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.bold))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Confirmed',
                    style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(gig.eventName.isNotEmpty ? gig.eventName : 'Event Details TBD', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _badge(LucideIcons.mapPin, gig.eventVenue.isNotEmpty ? gig.eventVenue : 'Location TBD'),
                _badge(LucideIcons.indianRupee, '₹${gig.budget.toInt()}'),
                _badge(LucideIcons.clock, gig.duration),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  final CalendarEntry entry;
  final VoidCallback onRemove;
  const _EntryTile({required this.entry, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(LucideIcons.calendarDays, size: 16, color: Color(0xFFF59E0B)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(entry.title,
              style: TextStyle(color: AppColors.foreground, fontSize: 13, fontWeight: FontWeight.w700)),
          if (entry.note.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(entry.note, style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
          ],
        ])),
        IconButton(
          icon: Icon(LucideIcons.trash2, size: 15, color: AppColors.mutedForeground),
          onPressed: onRemove,
          splashRadius: 16,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ]),
    );
  }
}

class _SheetActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _SheetActionBtn({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label,
                style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w700)),
            Text(subtitle,
                style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
          ])),
          Icon(LucideIcons.chevronRight, size: 16, color: color.withOpacity(0.6)),
        ]),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  const _InputField({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: AppColors.foreground, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 13),
        filled: true,
        fillColor: AppColors.secondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 5),
      Text(label, style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
    ]);
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String label;
  final String desc;
  const _LegendRow({required this.color, required this.label, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(color: AppColors.foreground, fontSize: 13, fontWeight: FontWeight.w700)),
          Text(desc, style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
        ])),
      ]),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 16, color: AppColors.foreground),
      ),
    );
  }
}
