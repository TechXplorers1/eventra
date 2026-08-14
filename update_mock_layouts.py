import os

mock_path = r'd:\company-work\eventra\lib\core\data\mock_data.dart'
with open(mock_path, 'r', encoding='utf-8') as f:
    mock_content = f.read()

# Add a default mock layout array before mockEvents
default_layouts_code = """
const List<SeatSection> _mockLayouts = [
  SeatSection(id: 'vip', name: 'VIP Lounge', price: 15000, colorHex: 0xFFA020F0, rows: 4, seatsPerRow: 12, available: 48),
  SeatSection(id: 'premium', name: 'Premium Front', price: 8000, colorHex: 0xFFFF1493, rows: 8, seatsPerRow: 20, available: 160),
  SeatSection(id: 'ga', name: 'General Admission', price: 2499, colorHex: 0xFF00BFFF, rows: 15, seatsPerRow: 30, available: 450),
];

"""

if '_mockLayouts' not in mock_content:
    mock_content = mock_content.replace(
        'final List<EventData> mockEvents = [',
        default_layouts_code + 'final List<EventData> mockEvents = ['
    )

# Find all EventData instantiation and inject seatingLayouts: _mockLayouts
import re
pattern = re.compile(r'(EventData\([^)]+?)\s*\),', re.DOTALL)

def replacer(match):
    full_match = match.group(0)
    if 'seatingLayouts:' not in full_match:
        # insert before the closing parenthesis
        last_paren_index = full_match.rfind(')')
        return full_match[:last_paren_index] + '  seatingLayouts: _mockLayouts,\n  ),'
    return full_match

new_content = pattern.sub(replacer, mock_content)

with open(mock_path, 'w', encoding='utf-8') as f:
    f.write(new_content)

print("Injected mock layouts into mockEvents.")
