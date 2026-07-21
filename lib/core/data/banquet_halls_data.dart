class BanquetHall {
  final String id;
  final String name;
  final String city;
  final String area;
  final String address;
  final double rating;
  final int reviewCount;
  final int capacity;
  final int halls;
  final double startingPrice;
  final String venueType;
  final String indoorOutdoor;
  final bool parking;
  final bool ac;
  final String operatingHours;
  final String description;
  final List<String> highlights;
  final List<String> amenities;
  final List<String> features;
  final List<Map<String, dynamic>> gallery;
  final bool hasVirtualTour;
  final Map<String, dynamic> policies;
  final List<String> blockedDates;
  final List<String> bookedDates;
  final List<Map<String, dynamic>> cateringPackages;
  final List<Map<String, dynamic>> decorationPackages;
  final Map<String, double> coordinates;

  const BanquetHall({
    required this.id,
    required this.name,
    required this.city,
    required this.area,
    required this.address,
    required this.rating,
    required this.reviewCount,
    required this.capacity,
    required this.halls,
    required this.startingPrice,
    required this.venueType,
    required this.indoorOutdoor,
    required this.parking,
    required this.ac,
    required this.operatingHours,
    required this.description,
    required this.highlights,
    required this.amenities,
    required this.features,
    required this.gallery,
    required this.hasVirtualTour,
    required this.policies,
    required this.blockedDates,
    required this.bookedDates,
    required this.cateringPackages,
    required this.decorationPackages,
    required this.coordinates,
  });
}

const _palettes = [
  [0xFFAB47BC, 0xFFEC407A], // Purple to pink approx
  [0xFF5C6BC0, 0xFFAB47BC], // Indigo to purple
  [0xFFD81B60, 0xFFFFA726], // Rose to orange
];

List<Map<String, dynamic>> _galleryFor(String id, int i) {
  const cats = ['Hall Setup', 'Stage', 'Dining Setup', 'Outdoor Area', 'Entrance', 'Event Setup'];
  return List.generate(cats.length, (index) {
    final colors = _palettes[i % _palettes.length];
    return {
      'category': cats[index],
      'key': '$id-img-$index',
      'colors': colors,
    };
  });
}

const _baseHighlights = [
  'Spacious banquet halls', 'Premium ambience', 'In-house catering', 'Customizable decor',
  'Valet parking', 'Bridal suite', 'Power backup', 'Trained event staff',
];

const _baseAmenities = [
  'Valet Parking', 'Bridal Suite', 'In-House Catering', 'Event Coordinator',
  'Premium Bar', 'Live Stage', 'Wi-Fi', 'Air Conditioning',
  'Power Backup', 'Changing Rooms', 'Security Services', 'CCTV Surveillance',
];

const _baseFeatures = [
  'Multiple Halls', 'Open Lawn', 'Stage with Lighting', 'High Ceiling',
  'Mandap Setup', 'DJ Allowed', 'Outside Decorator Allowed',
];

const _baseCatering = [
  {'name': 'Silver Veg', 'pricePerPlate': 650, 'capacity': '100-500', 'menu': ['Welcome Drinks', '4 Starters', '6 Mains', '3 Desserts']},
  {'name': 'Gold Non-Veg', 'pricePerPlate': 950, 'capacity': '100-1000', 'menu': ['Live Counter', '6 Starters', '8 Mains', 'Premium Desserts']},
  {'name': 'Platinum Premium', 'pricePerPlate': 1450, 'capacity': '50-2000', 'menu': ['Multi-cuisine Live', '8 Starters', '10 Mains', 'Dessert Bar', 'Mocktails']},
];

const _baseDecor = [
  {'name': 'Classic Floral', 'theme': 'Floral', 'price': 35000, 'includes': ['Stage Backdrop', 'Entrance Arch', 'Centerpieces']},
  {'name': 'Royal Mandap', 'theme': 'Royal', 'price': 95000, 'includes': ['Mandap Setup', 'Premium Florals', 'Drapery', 'Ambient Lighting']},
  {'name': 'Modern Minimal', 'theme': 'Minimal', 'price': 55000, 'includes': ['LED Backdrops', 'Geometric Decor', 'Fairy Lights']},
];

const _citiesAreas = [
  {'city': 'Mumbai', 'areas': ['Andheri West', 'Juhu', 'Bandra', 'Powai', 'Lower Parel']},
  {'city': 'Delhi', 'areas': ['Saket', 'Vasant Kunj', 'Dwarka', 'Connaught Place']},
  {'city': 'Bangalore', 'areas': ['Indiranagar', 'Whitefield', 'Koramangala', 'JP Nagar']},
  {'city': 'Hyderabad', 'areas': ['Banjara Hills', 'Gachibowli', 'Hitech City']},
  {'city': 'Pune', 'areas': ['Koregaon Park', 'Baner', 'Viman Nagar']},
  {'city': 'Jaipur', 'areas': ['Civil Lines', 'Malviya Nagar', 'Vaishali Nagar']},
  {'city': 'Goa', 'areas': ['Calangute', 'Panjim', 'Candolim']},
  {'city': 'Chennai', 'areas': ['T. Nagar', 'OMR', 'ECR']},
];

const _names = [
  'The Grand Pavilion', 'Royal Orchid Banquets', 'Crystal Ballroom', 'Heritage Mahal',
  'Emerald Gardens', 'Sapphire Convention', 'The Imperial Lawn', 'Pearl Banquet Hall',
  'Sunset Resort & Banquets', 'Celestial Hall', 'Lotus Gardens', 'Diamond Crown Hall',
  'Aurora Marriage Hall', 'Velvet Banquets', 'The Skyline Rooftop', 'Maple Convention',
  'Mystic Mahal', 'Ocean Breeze Resort', 'Sterling Banquets', 'Regalia Gardens',
];

const venueTypes = ['Banquet Hall', 'Marriage Hall', 'Resort', 'Hotel', 'Lawn', 'Convention Center', 'Rooftop'];

final List<BanquetHall> banquetHalls = List.generate(_names.length, (i) {
  final cityEntry = _citiesAreas[i % _citiesAreas.length];
  final areas = cityEntry['areas'] as List<String>;
  final area = areas[i % areas.length];
  final city = cityEntry['city'] as String;
  final name = _names[i];
  
  final capacity = 100 + ((i * 137) % 1900);
  final halls = 1 + (i % 5);
  final startingPrice = 50000.0 + ((i * 17000) % 350000);
  final rating = double.parse((4.3 + ((i * 7) % 7) / 10).toStringAsFixed(1));
  final reviewCount = 40 + ((i * 53) % 380);
  final venueType = venueTypes[i % venueTypes.length];
  final io = i % 3 == 0 ? 'Both' : i % 3 == 1 ? 'Indoor' : 'Outdoor';
  final id = 'hall-${i + 1}';

  return BanquetHall(
    id: id,
    name: name,
    city: city,
    area: area,
    address: '$name, $area, $city',
    rating: rating,
    reviewCount: reviewCount,
    capacity: capacity,
    halls: halls,
    startingPrice: startingPrice,
    venueType: venueType,
    indoorOutdoor: io,
    parking: i % 4 != 0,
    ac: i % 5 != 0,
    operatingHours: '9:00 AM – 12:00 AM',
    description: '$name is a premium ${venueType.toLowerCase()} in $area, $city, offering elegant interiors, lush surroundings, and bespoke event services for weddings, corporate events, and celebrations of every scale.',
    highlights: _baseHighlights.sublist(0, 6 + (i % 2)),
    amenities: _baseAmenities,
    features: _baseFeatures.sublist(0, 5 + (i % 3)),
    gallery: _galleryFor(id, i),
    hasVirtualTour: i % 2 == 0,
    policies: {
      'cancellation': 'Free cancellation up to 30 days before the event. 50% refund within 15 days.',
      'refund': 'Refunds processed within 7-10 business days to the original payment method.',
      'decoration': 'In-house decorator preferred. Outside decorators allowed with a refundable security deposit.',
      'vendors': 'Outside catering allowed for select packages. DJ and bar service through approved vendors only.',
      'terms': [
        'Loud music permitted until 11:00 PM as per local regulations.',
        'No use of crackers or open flames inside the hall.',
        'Damages to property will be charged from the security deposit.',
        'Final guest count must be confirmed 72 hours prior.',
      ],
    },
    blockedDates: [],
    bookedDates: [],
    cateringPackages: _baseCatering,
    decorationPackages: _baseDecor,
    coordinates: {'lat': 19.076 + i * 0.01, 'lng': 72.877 + i * 0.01},
  );
});

final List<String> allHallCities = banquetHalls.map((h) => h.city).toSet().toList()..sort();
final List<String> allVenueTypes = venueTypes;

const timeSlots = [
  {'id': 'morning', 'label': 'Morning', 'range': '8:00 AM – 12:00 PM', 'multiplier': 0.9},
  {'id': 'afternoon', 'label': 'Afternoon', 'range': '12:00 PM – 4:00 PM', 'multiplier': 1.0},
  {'id': 'evening', 'label': 'Evening', 'range': '6:00 PM – 11:00 PM', 'multiplier': 1.25},
  {'id': 'full-day', 'label': 'Full Day', 'range': '8:00 AM – 11:00 PM', 'multiplier': 2.4},
];

double computeHallSlotPrice(double basePrice, String slotId) {
  final s = timeSlots.firstWhere((x) => x['id'] == slotId, orElse: () => timeSlots[1]);
  return (basePrice * (s['multiplier'] as double)).roundToDouble();
}
