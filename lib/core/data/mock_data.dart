import '../models/app_models.dart';

final Map<String, String> categoryImages = {
  'concert': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?auto=format&fit=crop&q=80',
  'sports': 'https://images.unsplash.com/photo-1540747913346-19e32dc3e97e?auto=format&fit=crop&q=80',
  'comedy': 'https://images.unsplash.com/photo-1585699324551-f6c309eedeca?auto=format&fit=crop&q=80',
  'nightlife': 'https://images.unsplash.com/photo-1574169208507-84376144848b?auto=format&fit=crop&q=80',
  'arts': 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&q=80',
  'performance': 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&q=80',
};

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
}

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
  final String linkedVenueId;
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
    this.linkedVenueId = '',
    this.organizerId = '',
  });
}

final List<EventData> mockEvents = [
  EventData(
    id: '1', title: 'Coldplay: Music of the Spheres', date: 'Mar 15, 2026', time: '7:00 PM',
    venue: 'DY Patil Stadium', city: 'Mumbai', category: 'Music', price: 2499,
    description: 'Experience the magic of Coldplay live in concert. A mesmerizing journey through their greatest hits with spectacular visuals and an unforgettable atmosphere.',
    imageKey: 'concert', offers: ['20% Off'], featured: true, spotlight: true,
  ),
  EventData(
    id: '2', title: 'IPL Finals 2026', date: 'May 28, 2026', time: '7:30 PM',
    venue: 'Narendra Modi Stadium', city: 'Ahmedabad', category: 'Sports', price: 1999,
    description: 'Witness the grand finale of IPL 2026. The biggest cricket event of the year with electrifying atmosphere.',
    imageKey: 'sports', offers: ['Early Bird'], featured: true,
  ),
  EventData(
    id: '3', title: 'Zakir Khan Live', date: 'Apr 5, 2026', time: '8:00 PM',
    venue: 'JIO Convention Centre', city: 'Mumbai', category: 'Comedy', price: 999,
    description: 'Zakir Khan brings his hilarious new tour to Mumbai. An evening of non-stop laughter and relatable storytelling.',
    imageKey: 'comedy', featured: true, spotlight: true,
  ),
  EventData(
    id: '4', title: 'Sunburn Festival 2026', date: 'Dec 28, 2026', time: '4:00 PM',
    venue: 'Vagator Beach', city: 'Goa', category: 'Nightlife', price: 3499,
    description: 'Asia\'s biggest electronic dance music festival returns with world-class DJs and an incredible beachside experience.',
    imageKey: 'nightlife', offers: ['30% Off'], featured: true,
  ),
  EventData(
    id: '5', title: 'Kathak Mahotsav', date: 'Mar 22, 2026', time: '6:30 PM',
    venue: 'Kamani Auditorium', city: 'Delhi', category: 'Arts', price: 799,
    description: 'A celebration of classical Indian dance featuring maestros of Kathak performing timeless compositions.',
    imageKey: 'arts', spotlight: true,
  ),
  EventData(
    id: '6', title: 'Cirque du Soleil: Alegría', date: 'Apr 12, 2026', time: '7:00 PM',
    venue: 'NSCI Dome', city: 'Mumbai', category: 'Performances', price: 4999,
    description: 'The world-renowned circus spectacle brings its breathtaking acrobatics and artistry to India.',
    imageKey: 'performance', offers: ['VIP Upgrade'], featured: true, spotlight: true,
  ),
  EventData(
    id: '7', title: 'Arijit Singh Live', date: 'Mar 29, 2026', time: '7:30 PM',
    venue: 'Jawaharlal Nehru Stadium', city: 'Delhi', category: 'Music', price: 1799,
    description: 'The voice of a generation performs his greatest romantic ballads in an intimate concert setting.',
    imageKey: 'concert', offers: ['15% Off'],
  ),
  EventData(
    id: '8', title: 'Pro Kabaddi League', date: 'Jun 10, 2026', time: '8:00 PM',
    venue: 'Gachibowli Stadium', city: 'Hyderabad', category: 'Sports', price: 499,
    description: 'High-energy kabaddi action in the Pro Kabaddi League. Witness the thrill of India\'s fastest growing sport.',
    imageKey: 'sports',
  ),
  EventData(
    id: '9', title: 'Biswa Kalyan Rath', date: 'Apr 18, 2026', time: '8:30 PM',
    venue: 'Phoenix Marketcity', city: 'Bangalore', category: 'Comedy', price: 799,
    description: 'Biswa brings his signature observational comedy to Bangalore. Sharp, witty, and thought-provoking.',
    imageKey: 'comedy',
  ),
  EventData(
    id: '10', title: 'Echoes Music Fest', date: 'May 2, 2026', time: '5:00 PM',
    venue: 'Palace Grounds', city: 'Bangalore', category: 'Nightlife', price: 2999,
    description: 'A multi-genre music festival featuring indie, electronic, and hip-hop artists from around the world.',
    imageKey: 'nightlife', offers: ['Group Deal'],
  ),
  EventData(
    id: '11', title: 'Contemporary Art Exhibition', date: 'Mar 10, 2026', time: '10:00 AM',
    venue: 'National Gallery', city: 'Delhi', category: 'Arts', price: 299,
    description: 'Explore cutting-edge contemporary art from emerging Indian artists pushing creative boundaries.',
    imageKey: 'arts',
  ),
  EventData(
    id: '12', title: 'Broadway Musical: Hamilton', date: 'Jun 5, 2026', time: '6:00 PM',
    venue: 'Royal Opera House', city: 'Mumbai', category: 'Performances', price: 5999,
    description: 'The revolutionary musical sensation comes to India. Experience the story that changed Broadway forever.',
    imageKey: 'performance', offers: ['Premium Seats'], spotlight: true,
  ),
];

final List<String> cities = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Goa', 'Ahmedabad', 'Pune'];

String getEventImage(String imageKey) {
  return categoryImages[imageKey] ?? categoryImages['concert']!;
}
