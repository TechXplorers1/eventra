import os
import re

mock_path = r'd:\company-work\eventra\lib\core\data\mock_data.dart'
with open(mock_path, 'r', encoding='utf-8') as f:
    mock_content = f.read()

# Remove SeatSection class from mock_data
seat_section_pattern = re.compile(r'class SeatSection \{.*?\}\n', re.DOTALL)
mock_content = seat_section_pattern.sub('', mock_content)

# Add layouts to EventData
if 'final List<SeatSection> seatingLayouts;' not in mock_content:
    mock_content = mock_content.replace(
        '  final List<TicketTier> ticketTiers;',
        '  final List<TicketTier> ticketTiers;\n  final List<SeatSection> seatingLayouts;'
    )
    mock_content = mock_content.replace(
        '    this.ticketTiers = const [],',
        '    this.ticketTiers = const [],\n    this.seatingLayouts = const [],'
    )
    mock_content = mock_content.replace(
        '    List<TicketTier>? ticketTiers,',
        '    List<TicketTier>? ticketTiers,\n    List<SeatSection>? seatingLayouts,'
    )
    mock_content = mock_content.replace(
        '      ticketTiers: ticketTiers ?? this.ticketTiers,',
        '      ticketTiers: ticketTiers ?? this.ticketTiers,\n      seatingLayouts: seatingLayouts ?? this.seatingLayouts,'
    )

with open(mock_path, 'w', encoding='utf-8') as f:
    f.write(mock_content)

print("Updated mock_data.dart")
