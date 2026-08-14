import os

file_path = r'd:\company-work\eventra\lib\features\attendee\presentation\pages\seat_selection_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add _ticketQuantity to state
if 'int _ticketQuantity = 1;' not in content:
    content = content.replace(
        '  Set<String> _bestSeats = {};',
        '  Set<String> _bestSeats = {};\n  int _ticketQuantity = 1;'
    )

# Replace the empty state with GA picker
old_empty = """    if (event.seatingLayouts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_seat, size: 48, color: Colors.white24),
            const SizedBox(height: 16),
            const Text('No Seating Layout Available', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('This event does not have a defined layout.', style: TextStyle(color: Colors.white54)),
          ],
        ),
      );
    }"""

new_empty = """    if (event.seatingLayouts.isEmpty) {
      return _buildGeneralAdmissionPicker(event);
    }"""

content = content.replace(old_empty, new_empty)

# Add _buildGeneralAdmissionPicker method before _buildSeatMap
ga_picker = """
  Widget _buildGeneralAdmissionPicker(EventData event) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.confirmation_number_outlined, size: 64, color: _purple.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
          const Text('General Admission', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Unassigned seating / standing area.', style: TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ticket Quantity', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 4),
                    Text('₹${event.price.toInt()} each', style: const TextStyle(color: _purple, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _ticketQuantity > 1 ? () => setState(() => _ticketQuantity--) : null,
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.white),
                    ),
                    Text('$_ticketQuantity', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      onPressed: _ticketQuantity < 10 ? () => setState(() => _ticketQuantity++) : null,
                      icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                context.push('/order-summary', extra: {
                  'eventId': event.id,
                  'eventTitle': event.title,
                  'eventDate': event.date,
                  'eventTime': event.time,
                  'eventVenue': event.venue,
                  'eventCity': event.city,
                  'eventImageKey': event.imageKey,
                  'sectionName': 'General Admission',
                  'seatCount': _ticketQuantity,
                  'seats': <String>[],
                  'pricePerSeat': event.price,
                  'totalPrice': event.price * _ticketQuantity,
                });
              },
              child: Text('Continue - ₹${(event.price * _ticketQuantity).toInt()}', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
"""

if '_buildGeneralAdmissionPicker' not in content:
    content = content.replace('  // ── SEAT MAP ────────────────────────────────────────────────────────────────',
                              ga_picker + '\n  // ── SEAT MAP ────────────────────────────────────────────────────────────────')


with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated GA picker")
