import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/mock_data.dart';

class SeatSelectionScreen extends ConsumerStatefulWidget {
  final String eventId;
  const SeatSelectionScreen({super.key, required this.eventId});

  @override
  ConsumerState<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends ConsumerState<SeatSelectionScreen> {
  SeatSection? _selectedSection;
  final Set<String> _selectedSeats = {};
  
  Set<String>? _bookedSeats;
  Set<String>? _bestSeats;

  void _generateLayout(SeatSection sec) {
    final booked = <String>{};
    final best = <String>{};
    final seed = sec.id.codeUnitAt(0);

    for (int r = 0; r < sec.rows; r++) {
      for (int c = 0; c < sec.seatsPerRow; c++) {
        final id = '${String.fromCharCode(65 + r)}${c + 1}';
        final k = (r * 7 + c * 3 + seed) % 11;
        if (k == 0 || k == 4) booked.add(id);
      }
      if (r >= (sec.rows * 0.3).floor() && r <= (sec.rows * 0.6).floor()) {
        final mid = (sec.seatsPerRow / 2).floor();
        for (int c = mid - 2; c <= mid + 1; c++) {
          final id = '${String.fromCharCode(65 + r)}${c + 1}';
          if (!booked.contains(id)) best.add(id);
        }
      }
    }
    setState(() {
      _bookedSeats = booked;
      _bestSeats = best;
    });
  }

  void _toggleSeat(String seatId) {
    if (_bookedSeats?.contains(seatId) ?? false) return;
    setState(() {
      if (_selectedSeats.contains(seatId)) {
        _selectedSeats.remove(seatId);
      } else if (_selectedSeats.length < 10) {
        _selectedSeats.add(seatId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Prefer allEvents (includes organizer-created events), fallback to mockEvents
    final allEvents = ref.watch(appProvider.select((s) => s.allEvents));
    final fromState = allEvents.where((e) => e.id == widget.eventId).toList();
    final event = fromState.isNotEmpty
        ? fromState.first
        : mockEvents.firstWhere((e) => e.id == widget.eventId, orElse: () => mockEvents[0]);

    final totalPrice = _selectedSection != null ? _selectedSection!.price * _selectedSeats.length : 0.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (_selectedSection != null) {
                        setState(() {
                          _selectedSection = null;
                          _selectedSeats.clear();
                        });
                      } else {
                        context.pop();
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
                        Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('${event.date} • ${event.time} • ${event.venue}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_selectedSection == null) ...[
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: Container(
                        width: 224, height: 36,
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(100)),
                          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        alignment: Alignment.center,
                        child: Text('STAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryForeground, letterSpacing: 3)),
                      ),
                    ),
                    Text('Select a ticket category to view seats', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    const SizedBox(height: 16),
                    ...seatSections.map((sec) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedSection = sec;
                            _selectedSeats.clear();
                          });
                          _generateLayout(sec);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.card,
                                border: Border.all(color: AppColors.border),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(sec.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                      Text('${sec.available} seats available', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                  Text('₹${sec.price.toInt()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 0,
                              bottom: 0,
                              child: Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: Color(sec.colorHex),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ] else ...[
              // Legend
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Wrap(
                  spacing: 12, runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildLegendItem('Available', AppColors.secondary, AppColors.border),
                    _buildLegendItem('Best', AppColors.primary.withOpacity(0.3), AppColors.primary.withOpacity(0.6)),
                    _buildLegendItem('Selected', AppColors.primary, AppColors.primary),
                    _buildLegendItem('Booked', AppColors.muted.withOpacity(0.4), Colors.transparent),
                  ],
                ),
              ),
              
              // Map
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    boundaryMargin: const EdgeInsets.all(100),
                    constrained: false,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: [
                          Container(
                            width: 224, height: 28,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(100)),
                            ),
                            alignment: Alignment.center,
                            child: Text('STAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryForeground, letterSpacing: 3)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Color(_selectedSection!.colorHex).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text('${_selectedSection!.name} • ₹${_selectedSection!.price.toInt()}', style: TextStyle(color: Color(_selectedSection!.colorHex), fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                          ...List.generate(_selectedSection!.rows, (r) {
                            final rowLetter = String.fromCharCode(65 + r);
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 20, child: Text(rowLetter, textAlign: TextAlign.right, style: TextStyle(fontSize: 9, color: AppColors.mutedForeground))),
                                  const SizedBox(width: 8),
                                  ...List.generate(_selectedSection!.seatsPerRow, (c) {
                                    final seatId = '$rowLetter${c + 1}';
                                    final isBooked = _bookedSeats?.contains(seatId) ?? false;
                                    final isSelected = _selectedSeats.contains(seatId);
                                    final isBest = (_bestSeats?.contains(seatId) ?? false) && !isBooked && !isSelected;
                                    
                                    Color bgColor = AppColors.secondary;
                                    Color borderColor = AppColors.border;
                                    Color textColor = AppColors.mutedForeground;

                                    if (isBooked) {
                                      bgColor = AppColors.muted.withOpacity(0.4);
                                      borderColor = Colors.transparent;
                                      textColor = AppColors.mutedForeground.withOpacity(0.4);
                                    } else if (isSelected) {
                                      bgColor = AppColors.primary;
                                      borderColor = AppColors.primary;
                                      textColor = AppColors.primaryForeground;
                                    } else if (isBest) {
                                      bgColor = AppColors.primary.withOpacity(0.25);
                                      borderColor = AppColors.primary.withOpacity(0.6);
                                      textColor = AppColors.foreground;
                                    }

                                    return GestureDetector(
                                      onTap: () => _toggleSeat(seatId),
                                      child: Container(
                                        width: 20, height: 20,
                                        margin: const EdgeInsets.symmetric(horizontal: 2),
                                        decoration: BoxDecoration(
                                          color: bgColor,
                                          border: Border.all(color: borderColor),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        alignment: Alignment.center,
                                        child: Text('${c + 1}', style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: textColor)),
                                      ),
                                    );
                                  }),
                                  const SizedBox(width: 8),
                                  SizedBox(width: 20, child: Text(rowLetter, style: TextStyle(fontSize: 9, color: AppColors.mutedForeground))),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card.withOpacity(0.9),
                  border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.6))),
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
                            Text(_selectedSeats.isNotEmpty ? '${_selectedSeats.length} seat${_selectedSeats.length > 1 ? 's' : ''} • ${_selectedSeats.join(', ')}' : 'No seats selected', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            Text('₹${totalPrice.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _selectedSeats.isEmpty ? null : () {
                          // Note: In a real app we'd pass this via an extra parameter object, but we can pass state via Extra
                          final payload = {
                            'eventId': event.id,
                            'eventTitle': event.title,
                            'eventDate': event.date,
                            'eventTime': event.time,
                            'eventVenue': event.venue,
                            'eventCity': event.city,
                            'eventImageKey': event.imageKey,
                            'sectionName': _selectedSection!.name,
                            'seatCount': _selectedSeats.length,
                            'seats': _selectedSeats.toList(),
                            'pricePerSeat': _selectedSection!.price,
                            'totalPrice': totalPrice,
                          };
                          context.push('/order-summary', extra: payload);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                      ),
                    ],
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, Color border) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, border: Border.all(color: border), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
      ],
    );
  }
}
