import os
import re

screen_path = r'd:\company-work\eventra\lib\features\attendee\presentation\pages\seat_selection_screen.dart'
with open(screen_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace `seatSections` with `event.seatingLayouts`
content = content.replace('...seatSections.map((sec)', '...event.seatingLayouts.map((sec)')

# There might be a check for empty layout
if 'if (event.seatingLayouts.isEmpty)' not in content:
    # insert an empty state if no layouts
    old_list_view = "    return ListView("
    new_list_view = """    if (event.seatingLayouts.isEmpty) {
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
    }
    
    return ListView("""
    content = content.replace(old_list_view, new_list_view)


with open(screen_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated seat selection screen.")
