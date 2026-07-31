import os

models_path = r'd:\company-work\eventra\lib\core\models\app_models.dart'
with open(models_path, 'r', encoding='utf-8') as f:
    models_content = f.read()

seat_section_code = """
class SeatSection {
  final String id;
  final String name;
  final double price;
  final int colorHex;
  final int rows;
  final int seatsPerRow;
  final int available;

  const SeatSection({
    required this.id,
    required this.name,
    required this.price,
    required this.colorHex,
    required this.rows,
    required this.seatsPerRow,
    required this.available,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'colorHex': colorHex,
      'rows': rows,
      'seatsPerRow': seatsPerRow,
      'available': available,
    };
  }

  factory SeatSection.fromJson(Map<String, dynamic> json) {
    return SeatSection(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      colorHex: json['colorHex'] ?? 0xFF000000,
      rows: json['rows'] ?? 0,
      seatsPerRow: json['seatsPerRow'] ?? 0,
      available: json['available'] ?? 0,
    );
  }
}
"""

if 'class SeatSection' not in models_content:
    models_content += seat_section_code

# Now add `layouts` to ServiceProviderProfile
if 'final List<SeatSection> seatingLayouts;' not in models_content:
    models_content = models_content.replace(
        '  final String seatingLayout;',
        '  final String seatingLayout;\n  final List<SeatSection> seatingLayouts;'
    )
    models_content = models_content.replace(
        '    this.seatingLayout = \'\',',
        '    this.seatingLayout = \'\',\n    this.seatingLayouts = const [],'
    )
    models_content = models_content.replace(
        '    String? seatingLayout,',
        '    String? seatingLayout,\n    List<SeatSection>? seatingLayouts,'
    )
    models_content = models_content.replace(
        '      seatingLayout: seatingLayout ?? this.seatingLayout,',
        '      seatingLayout: seatingLayout ?? this.seatingLayout,\n      seatingLayouts: seatingLayouts ?? this.seatingLayouts,'
    )

with open(models_path, 'w', encoding='utf-8') as f:
    f.write(models_content)

print("Updated app_models.dart")
