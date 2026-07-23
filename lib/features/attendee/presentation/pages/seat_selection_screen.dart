import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/mock_data.dart';

class SeatSelectionScreen extends StatefulWidget {
  final String eventId;
  const SeatSelectionScreen({super.key, required this.eventId});

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  SeatSection? _selectedSection;
  final Set<String> _selectedSeats = {};
  Set<String> _bookedSeats = {};
  Set<String> _bestSeats = {};

  static const _bg = Color(0xFF0A0A0F);
  static const _card = Color(0xFF18181B);
  static const _muted = Color(0xFF71717A);
  static const _purple = Color(0xFF7C3AED);
  static const _border = Color(0xFF27272A);

  void _selectSection(SeatSection sec) {
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
      _selectedSection = sec;
      _selectedSeats.clear();
      _bookedSeats = booked;
      _bestSeats = best;
    });
  }

  void _toggleSeat(String seatId) {
    if (_bookedSeats.contains(seatId)) return;
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
    // Direct mockEvents lookup — no Riverpod
    final event = mockEvents.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => mockEvents[0],
    );

    final sec = _selectedSection;
    final totalPrice = sec != null ? sec.price * _selectedSeats.length : 0.0;
    final sectionColor = sec != null ? Color(sec.colorHex) : _purple;

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (sec != null) {
              setState(() { _selectedSection = null; _selectedSeats.clear(); });
            } else {
              context.canPop() ? context.pop() : context.go('/home');
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.title,
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${event.date} · ${event.time} · ${event.venue}',
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white54)),
          ],
        ),
      ),
      body: sec == null ? _buildSectionPicker(event) : _buildSeatMap(sec, sectionColor),
      bottomNavigationBar: sec == null ? null : _buildBottomBar(event, totalPrice),
    );
  }

  // ── SECTION PICKER ──────────────────────────────────────────────────────────
  Widget _buildSectionPicker(EventData event) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Stage indicator
        Center(
          child: Container(
            width: 200, height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFFF6B35)]),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(100)),
              boxShadow: [BoxShadow(color: const Color(0xFF7C3AED).withAlpha(80), blurRadius: 12)],
            ),
            alignment: Alignment.center,
            child: const Text('STAGE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
          ),
        ),
        const SizedBox(height: 24),
        const Text('Choose a Ticket Category', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white70)),
        const SizedBox(height: 20),
        ...seatSections.map((sec) {
          final col = Color(sec.colorHex);
          return GestureDetector(
            onTap: () => _selectSection(sec),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _border),
              ),
              child: Row(
                children: [
                  Container(width: 4, height: 48,
                    decoration: BoxDecoration(color: col, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sec.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 4),
                        Text('${sec.available} seats available',
                          style: const TextStyle(fontSize: 12, color: Colors.white54)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('₹${sec.price.toInt()}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: col)),
                      const Text('per seat', style: TextStyle(fontSize: 10, color: Colors.white38)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.white38),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ── SEAT MAP ────────────────────────────────────────────────────────────────
  Widget _buildSeatMap(SeatSection sec, Color sectionColor) {
    return Column(
      children: [
        // Legend
        Container(
          color: _card,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend('Available', _border, Colors.white54),
              const SizedBox(width: 16),
              _legend('Best', sectionColor.withAlpha(60), sectionColor),
              const SizedBox(width: 16),
              _legend('Selected', sectionColor, Colors.white),
              const SizedBox(width: 16),
              _legend('Booked', const Color(0xFF3F3F46), const Color(0xFF52525B)),
            ],
          ),
        ),
        // Stage label
        Container(
          color: _bg,
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Center(
            child: Container(
              width: 160, height: 28,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [sectionColor, sectionColor.withAlpha(160)]),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(100)),
              ),
              alignment: Alignment.center,
              child: const Text('STAGE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 3)),
            ),
          ),
        ),
        // Seat grid — scrollable
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(sec.rows, (r) {
                  final rowLetter = String.fromCharCode(65 + r);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        SizedBox(width: 20,
                          child: Text(rowLetter,
                            style: const TextStyle(fontSize: 9, color: Colors.white38))),
                        const SizedBox(width: 6),
                        ...List.generate(sec.seatsPerRow, (c) {
                          final seatId = '$rowLetter${c + 1}';
                          final isBooked = _bookedSeats.contains(seatId);
                          final isSelected = _selectedSeats.contains(seatId);
                          final isBest = _bestSeats.contains(seatId) && !isBooked && !isSelected;

                          Color bg, border;
                          if (isBooked) {
                            bg = const Color(0xFF3F3F46); border = Colors.transparent;
                          } else if (isSelected) {
                            bg = sectionColor; border = sectionColor;
                          } else if (isBest) {
                            bg = sectionColor.withAlpha(60); border = sectionColor;
                          } else {
                            bg = _border; border = const Color(0xFF3F3F46);
                          }

                          return GestureDetector(
                            onTap: () => _toggleSeat(seatId),
                            child: Container(
                              width: 22, height: 22,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: bg,
                                border: Border.all(color: border, width: 1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              alignment: Alignment.center,
                              child: Text('${c + 1}',
                                style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : Colors.white54)),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── BOTTOM BAR ──────────────────────────────────────────────────────────────
  Widget _buildBottomBar(EventData event, double totalPrice) {
    final sec = _selectedSection!;
    return Container(
      color: _card,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedSeats.isEmpty
                    ? 'No seats selected'
                    : '${_selectedSeats.length} seat(s) · ${_selectedSeats.take(4).join(', ')}${_selectedSeats.length > 4 ? '…' : ''}',
                  style: const TextStyle(fontSize: 11, color: Colors.white54)),
                Text('₹${totalPrice.toInt()}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF7C3AED))),
              ],
            ),
          ),
          GestureDetector(
            onTap: _selectedSeats.isEmpty ? null : () {
              context.push('/order-summary', extra: {
                'eventId': event.id,
                'eventTitle': event.title,
                'eventDate': event.date,
                'eventTime': event.time,
                'eventVenue': event.venue,
                'eventCity': event.city,
                'eventImageKey': event.imageKey,
                'sectionName': sec.name,
                'seatCount': _selectedSeats.length,
                'seats': _selectedSeats.toList(),
                'pricePerSeat': sec.price,
                'totalPrice': totalPrice,
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                color: _selectedSeats.isEmpty ? _border : const Color(0xFF7C3AED),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _selectedSeats.isEmpty ? 'Select Seats' : 'Continue →',
                style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold,
                  color: _selectedSeats.isEmpty ? _muted : Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, Color bg, Color textColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 14, height: 14,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white54)),
      ],
    );
  }
}
