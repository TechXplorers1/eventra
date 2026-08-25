import '../models/app_models.dart';

final Map<String, String> categoryImages = {
  'concert': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?auto=format&fit=crop&q=80',
  'sports': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?auto=format&fit=crop&q=80',
  'comedy': 'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?auto=format&fit=crop&q=80',
  'nightlife': 'https://images.unsplash.com/photo-1574169208507-84376144848b?auto=format&fit=crop&q=80',
  'arts': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&q=80',
  'performance': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&q=80',
};


const List<SeatSection> seatSections = [
  SeatSection(id: 'vip', name: 'VIP Lounge', price: 15000, colorHex: 0xFFA020F0, rows: 4, seatsPerRow: 12, available: 15),
  SeatSection(id: 'premium', name: 'Premium Front', price: 8000, colorHex: 0xFFFF1493, rows: 8, seatsPerRow: 20, available: 45),
  SeatSection(id: 'ga', name: 'General Admission', price: 2499, colorHex: 0xFF00BFFF, rows: 15, seatsPerRow: 30, available: 200),
];

class EventData {
  final String id;
  final String title;
  final String date;
  final String time;
  final String venue;
  final String city;
  final String category;
  final double price;
  final String description;
  final String imageKey;
  final List<String> offers;
  final bool featured;
  final bool spotlight;
  // V1 additions
  final String visibility; // 'public' | 'private'
  final List<TicketTier> ticketTiers;
  final List<SeatSection> seatingLayouts;
  final String linkedVenueId;
  final String venueStatus; // 'pending', 'confirmed', 'rejected'
  final String organizerId;

  const EventData({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.venue,
    required this.city,
    required this.category,
    required this.price,
    required this.description,
    required this.imageKey,
    this.offers = const [],
    this.featured = false,
    this.spotlight = false,
    this.visibility = 'public',
    this.ticketTiers = const [],
    this.seatingLayouts = const [],
    this.linkedVenueId = '',
    this.venueStatus = 'confirmed',
    this.organizerId = '',
  });

  EventData copyWith({
    String? id,
    String? title,
    String? date,
    String? time,
    String? venue,
    String? city,
    String? category,
    double? price,
    String? description,
    String? imageKey,
    List<String>? offers,
    bool? featured,
    bool? spotlight,
    String? visibility,
    List<TicketTier>? ticketTiers,
    List<SeatSection>? seatingLayouts,
    String? linkedVenueId,
    String? venueStatus,
    String? organizerId,
  }) {
    return EventData(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      city: city ?? this.city,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      imageKey: imageKey ?? this.imageKey,
      offers: offers ?? this.offers,
      featured: featured ?? this.featured,
      spotlight: spotlight ?? this.spotlight,
      visibility: visibility ?? this.visibility,
      ticketTiers: ticketTiers ?? this.ticketTiers,
      seatingLayouts: seatingLayouts ?? this.seatingLayouts,
      linkedVenueId: linkedVenueId ?? this.linkedVenueId,
      venueStatus: venueStatus ?? this.venueStatus,
      organizerId: organizerId ?? this.organizerId,
    );
  }
}


const List<SeatSection> _mockLayouts = [
  SeatSection(id: 'vip', name: 'VIP Lounge', price: 15000, colorHex: 0xFFA020F0, rows: 4, seatsPerRow: 12, available: 48),
  SeatSection(id: 'premium', name: 'Premium Front', price: 8000, colorHex: 0xFFFF1493, rows: 8, seatsPerRow: 20, available: 160),
  SeatSection(id: 'ga', name: 'General Admission', price: 2499, colorHex: 0xFF00BFFF, rows: 15, seatsPerRow: 30, available: 450),
];

String _getFormattedDate(int daysFromNow) {
  final d = DateTime.now().add(Duration(days: daysFromNow));
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[d.month - 1]} ${d.day}, ${d.year}';
}

final int _daysToSat = (6 - DateTime.now().weekday) % 7;

final List<EventData> mockEvents = [
  EventData(
    id: '1', title: 'Coldplay: Music of the Spheres', date: _getFormattedDate(0), time: '7:00 PM',
    venue: 'DY Patil Stadium', city: 'Mumbai', category: 'Music', price: 2499,
    description: 'Experience the magic of Coldplay live in concert. A mesmerizing journey through their greatest hits with spectacular visuals and an unforgettable atmosphere.',
    imageKey: 'concert', offers: ['20% Off'], featured: true, spotlight: true,
    seatingLayouts: _mockLayouts,
  ),
  EventData(
    id: '2', title: 'IPL Finals 2026', date: _getFormattedDate(1), time: '7:30 PM',
    venue: 'Narendra Modi Stadium', city: 'Ahmedabad', category: 'Sports', price: 1999,
    description: 'Witness the grand finale of IPL 2026. The biggest cricket event of the year with electrifying atmosphere.',
    imageKey: 'sports', offers: ['Early Bird'], featured: true,
    seatingLayouts: _mockLayouts,
  ),
  EventData(
    id: '3', title: 'Zakir Khan Live', date: _getFormattedDate(_daysToSat == 0 ? 0 : _daysToSat), time: '8:00 PM',
    venue: 'JIO Convention Centre', city: 'Mumbai', category: 'Comedy', price: 999,
    description: 'Zakir Khan brings his hilarious new tour to Mumbai. An evening of non-stop laughter and relatable storytelling.',
    imageKey: 'comedy', featured: true, spotlight: true,
    seatingLayouts: _mockLayouts,
  ),
  EventData(
    id: '4', title: 'Sunburn Festival 2026', date: _getFormattedDate(_daysToSat + 1), time: '4:00 PM',
    venue: 'Vagator Beach', city: 'Goa', category: 'Nightlife', price: 3499,
    description: 'Asia\'s biggest electronic dance music festival returns with world-class DJs and an incredible beachside experience.',
    imageKey: 'nightlife', offers: ['30% Off'], featured: true,
  ),
  EventData(
    id: '5', title: 'Kathak Mahotsav', date: _getFormattedDate(4), time: '6:30 PM',
    venue: 'Kamani Auditorium', city: 'Delhi', category: 'Arts', price: 799,
    description: 'A celebration of classical Indian dance featuring maestros of Kathak performing timeless compositions.',
    imageKey: 'arts', spotlight: true,
    seatingLayouts: _mockLayouts,
  ),
  EventData(
    id: '6', title: 'Cirque du Soleil: Alegría', date: _getFormattedDate(7), time: '7:00 PM',
    venue: 'NSCI Dome', city: 'Mumbai', category: 'Performances', price: 4999,
    description: 'The world-renowned circus spectacle brings its breathtaking acrobatics and artistry to India.',
    imageKey: 'performance', offers: ['VIP Upgrade'], featured: true, spotlight: true,
    seatingLayouts: _mockLayouts,
  ),
  EventData(
    id: '7', title: 'Arijit Singh Live', date: _getFormattedDate(12), time: '7:30 PM',
    venue: 'Jawaharlal Nehru Stadium', city: 'Delhi', category: 'Music', price: 1799,
    description: 'The voice of a generation performs his greatest romantic ballads in an intimate concert setting.',
    imageKey: 'concert', offers: ['15% Off'],
    seatingLayouts: _mockLayouts,
  ),
  EventData(
    id: '8', title: 'Pro Kabaddi League', date: _getFormattedDate(18), time: '8:00 PM',
    venue: 'Gachibowli Stadium', city: 'Hyderabad', category: 'Sports', price: 499,
    description: 'High-energy kabaddi action in the Pro Kabaddi League. Witness the thrill of India\'s fastest growing sport.',
    imageKey: 'sports',
    seatingLayouts: _mockLayouts,
  ),
  EventData(
    id: '9', title: 'Biswa Kalyan Rath', date: _getFormattedDate(25), time: '8:30 PM',
    venue: 'Phoenix Marketcity', city: 'Bangalore', category: 'Comedy', price: 799,
    description: 'Biswa brings his signature observational comedy to Bangalore. Sharp, witty, and thought-provoking.',
    imageKey: 'comedy',
    seatingLayouts: _mockLayouts,
  ),
  EventData(
    id: '10', title: 'Echoes Music Fest', date: _getFormattedDate(32), time: '5:00 PM',
    venue: 'Palace Grounds', city: 'Bangalore', category: 'Nightlife', price: 2999,
    description: 'A multi-genre music festival featuring indie, electronic, and hip-hop artists from around the world.',
    imageKey: 'nightlife', offers: ['Group Deal'],
  ),
  EventData(
    id: '11', title: 'Contemporary Art Exhibition', date: _getFormattedDate(45), time: '10:00 AM',
    venue: 'National Gallery', city: 'Delhi', category: 'Arts', price: 299,
    description: 'Explore cutting-edge contemporary art from emerging Indian artists pushing creative boundaries.',
    imageKey: 'arts',
  ),
  EventData(
    id: '12', title: 'Broadway Musical: Hamilton', date: _getFormattedDate(60), time: '6:00 PM',
    venue: 'Royal Opera House', city: 'Mumbai', category: 'Performances', price: 5999,
    description: 'The revolutionary musical sensation comes to India. Experience the story that changed Broadway forever.',
    imageKey: 'performance', offers: ['Premium Seats'], spotlight: true,
    seatingLayouts: _mockLayouts,
  ),
];

final List<String> cities = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Goa', 'Ahmedabad', 'Pune'];

String getEventImage(String imageKey) {
  return categoryImages[imageKey] ?? categoryImages['concert']!;
}
