import os
import re

filepath = r'd:\company-work\eventra\lib\core\models\app_models.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Add fields to class declaration
if 'final String venueType;' not in content:
    content = content.replace(
        '  final List<String> amenities;',
        '  final List<String> amenities;\n  final String venueType;\n  final String seatingLayout;'
    )

# Add to constructor
if 'this.venueType = \'\',' not in content:
    content = content.replace(
        '    this.amenities = const [],',
        '    this.amenities = const [],\n    this.venueType = \'\',\n    this.seatingLayout = \'\','
    )

# Add to copyWith parameters
if 'String? venueType,' not in content:
    content = content.replace(
        '    List<String>? amenities,',
        '    List<String>? amenities,\n    String? venueType,\n    String? seatingLayout,'
    )

# Add to copyWith return
if 'venueType: venueType' not in content:
    content = content.replace(
        '      amenities: amenities ?? this.amenities,',
        '      amenities: amenities ?? this.amenities,\n      venueType: venueType ?? this.venueType,\n      seatingLayout: seatingLayout ?? this.seatingLayout,'
    )

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Models updated.")
