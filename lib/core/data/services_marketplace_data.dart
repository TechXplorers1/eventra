import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/app_models.dart';

class UserService {
  final String id;
  final String name;
  final String description;
  final int startingPrice;
  final double rating;
  final String availability; // 'Available' | 'Limited' | 'Busy'
  final List<String> features;
  final IconData icon;

  const UserService({
    required this.id,
    required this.name,
    required this.description,
    required this.startingPrice,
    required this.rating,
    required this.availability,
    required this.features,
    required this.icon,
  });
}

class ServiceGroup {
  final String id;
  final String name;
  final List<UserService> services;

  const ServiceGroup({
    required this.id,
    required this.name,
    required this.services,
  });
}

UserService _make(
  String id, String name, IconData icon, int startingPrice, String description,
  [List<String> features = const ['Verified vendors', 'Flexible packages', 'On-time delivery'],
  double rating = 4.7,
  String availability = 'Available']
) {
  return UserService(id: id, name: name, description: description, startingPrice: startingPrice, rating: rating, availability: availability, features: features, icon: icon);
}

final List<ServiceGroup> serviceGroups = [
  ServiceGroup(id: 'media', name: 'Media & Production', services: [
    _make('photographer', 'Photographer', LucideIcons.camera, 8000, 'Capture every moment in stunning detail.'),
    _make('videographer', 'Videographer', LucideIcons.video, 12000, 'Cinematic event films and highlight reels.'),
    _make('drone', 'Drone Operator', LucideIcons.plane, 6000, 'Aerial coverage with 4K & 6K drone footage.'),
    _make('livestream', 'Live Streaming', LucideIcons.radio, 15000, 'Multi-cam pro live streaming setup.'),
    _make('editing', 'Video Editing', LucideIcons.scissors, 5000, 'Post-production, color grading and edits.'),
    _make('content', 'Content Creation', LucideIcons.penTool, 7000, 'Reels, social cuts and creator-grade content.'),
  ]),
  ServiceGroup(id: 'entertainment', name: 'Entertainment', services: [
    _make('host', 'Host / MC', LucideIcons.megaphone, 7000, 'Engaging anchors to keep your crowd hyped.'),
    _make('dj', 'DJ', LucideIcons.disc3, 10000, 'Pro DJs with custom sets and own gear.'),
    _make('singer', 'Singer', LucideIcons.mic2, 12000, 'Solo vocal acts across genres.'),
    _make('band', 'Live Band', LucideIcons.music2, 20000, 'Full bands for concerts and parties.'),
    _make('comedian', 'Stand-up Comedian', LucideIcons.laugh, 15000, 'Headlining comics for any event size.'),
    _make('dance', 'Dance Group', LucideIcons.partyPopper, 10000, 'Choreographed performances and acts.'),
  ]),
  ServiceGroup(id: 'audio', name: 'Audio & Technical', services: [
    _make('sound', 'Sound System', LucideIcons.speaker, 9000, 'Pro audio setup and FOH engineering.'),
    _make('lighting', 'Lighting Setup', LucideIcons.lightbulb, 8500, 'Stage and ambient lighting design.'),
    _make('led', 'LED Wall', LucideIcons.monitor, 18000, 'High-brightness LED video walls.'),
    _make('projector', 'Projector Setup', LucideIcons.projector, 6000, 'HD projectors and screens.'),
    _make('av', 'AV Technician', LucideIcons.settings, 4000, 'On-site audio-visual technicians.'),
  ]),
  ServiceGroup(id: 'decor', name: 'Decoration & Branding', services: [
    _make('decorator', 'Event Decorator', LucideIcons.sparkles, 11000, 'Themed event decor and styling.'),
    _make('floral', 'Floral Decoration', LucideIcons.flower2, 9000, 'Fresh florals and installations.'),
    _make('balloon', 'Balloon Decoration', LucideIcons.partyPopper, 4000, 'Balloon arches and centerpieces.'),
    _make('banner', 'Banner Printing', LucideIcons.printer, 2000, 'Banners, flex and large-format prints.'),
    _make('standee', 'Standee Printing', LucideIcons.image, 1500, 'Standees and signage.'),
  ]),
  ServiceGroup(id: 'food', name: 'Food & Hospitality', services: [
    _make('caterer', 'Caterer', LucideIcons.utensilsCrossed, 350, 'Per-plate catering for any cuisine.'),
    _make('beverage', 'Beverage Services', LucideIcons.glassWater, 200, 'Bar and beverage stations.'),
    _make('coffee', 'Coffee Counter', LucideIcons.coffee, 4000, 'Specialty coffee carts.'),
    _make('hospitality', 'Hospitality Staff', LucideIcons.conciergeBell, 1200, 'Trained hospitality team.'),
  ]),
  ServiceGroup(id: 'venue', name: 'Venue & Logistics', services: [
    _make('banquet-hall', 'Banquet Halls', LucideIcons.building2, 50000, 'Premium banquet halls, marriage halls and resorts.'),
    _make('venue', 'Venue Booking', LucideIcons.building2, 25000, 'Curated venues across cities.'),
    _make('transport', 'Transportation', LucideIcons.bus, 8000, 'Shuttles and guest transport.'),
    _make('furniture', 'Furniture Rental', LucideIcons.sofa, 5000, 'Chairs, tables and lounge sets.'),
    _make('generator', 'Generator Rental', LucideIcons.zap, 6000, 'Silent gensets for any load.'),
    _make('parking', 'Parking Management', LucideIcons.car, 4000, 'Valet and parking coordinators.'),
  ]),
  ServiceGroup(id: 'security', name: 'Security & Safety', services: [
    _make('guards', 'Security Guards', LucideIcons.shieldCheck, 1500, 'Trained uniformed guards.'),
    _make('bouncers', 'Bouncers', LucideIcons.shieldAlert, 2500, 'Crowd control specialists.'),
    _make('medical', 'Medical Support', LucideIcons.heartPulse, 5000, 'On-site paramedics and ambulance.'),
    _make('fire', 'Fire Safety Team', LucideIcons.flame, 4000, 'Certified fire safety personnel.'),
  ]),
  ServiceGroup(id: 'marketing', name: 'Marketing & Promotion', services: [
    _make('social', 'Social Media Marketing', LucideIcons.share2, 10000, 'Event promo across socials.'),
    _make('influencer', 'Influencer Promotion', LucideIcons.star, 15000, 'Creator-led promotions.'),
    _make('graphic', 'Graphic Design', LucideIcons.palette, 5000, 'Posters, creatives and brand kits.'),
    _make('digital-ads', 'Digital Advertising', LucideIcons.trendingUp, 8000, 'Paid media across platforms.'),
  ]),
  ServiceGroup(id: 'staffing', name: 'Event Staffing', services: [
    _make('volunteers', 'Volunteers', LucideIcons.users, 800, 'On-ground volunteer crews.'),
    _make('registration', 'Registration Staff', LucideIcons.clipboardList, 1000, 'Guest registration and check-in.'),
    _make('verification', 'Ticket Verification Staff', LucideIcons.ticket, 1000, 'Entry and ticket verification.'),
    _make('coordinators', 'Event Coordinators', LucideIcons.userCog, 3000, 'Senior on-site coordinators.'),
  ]),
];

final List<UserService> allUserServices = serviceGroups.expand((g) => g.services).toList();

UserService? findUserService(String id) {
  try {
    return allUserServices.firstWhere((s) => s.id == id);
  } catch (e) {
    return null;
  }
}

ServiceGroup? findGroupForService(String id) {
  try {
    return serviceGroups.firstWhere((g) => g.services.any((s) => s.id == id));
  } catch (e) {
    return null;
  }
}

class VendorPackage {
  final String name; // 'Basic' | 'Standard' | 'Premium'
  final int price;
  final List<String> features;

  const VendorPackage({required this.name, required this.price, required this.features});
}

class VendorDetailGroup {
  final String label;
  final List<String> items;

  const VendorDetailGroup({required this.label, required this.items});
}

class Vendor {
  final String id;
  final String serviceId;
  final String name;
  final double rating;
  final int reviews;
  final int experienceYears;
  final String city;
  final String specialization;
  final int startingPrice;
  final String availability; // 'Available' | 'Busy' | 'On Leave'
  final String bio;
  final List<String> equipment;
  final List<String> servicesOffered;
  final List<VendorDetailGroup> details;
  final List<String> portfolio;
  final List<VendorPackage> packages;
  final bool verified;
  final Map<String, String> socialLinks;

  const Vendor({
    required this.id, required this.serviceId, required this.name, required this.rating, required this.reviews,
    required this.experienceYears, required this.city, required this.specialization, required this.startingPrice,
    required this.availability, required this.bio, required this.equipment, required this.servicesOffered,
    required this.details, required this.portfolio, required this.packages, required this.verified,
    this.socialLinks = const {},
  });
}

const CITIES = ['Mumbai', 'Delhi', 'Bangalore', 'Hyderabad', 'Pune', 'Goa', 'Chennai', 'Kolkata', 'Ahmedabad', 'Jaipur'];

class Catalogue {
  final List<String> brandNames;
  final List<String> specializations;
  final List<String> equipment;
  final List<String> services;
  final List<VendorDetailGroup> details;
  final String bio;

  const Catalogue({required this.brandNames, required this.specializations, required this.equipment, required this.services, required this.details, required this.bio});
}

final Map<String, Catalogue> _catalogues = {
  'photographer': Catalogue(
    brandNames: ['Lumen Studios', 'Pixel Theory', 'Frame Forge', 'Aperture House', 'Lens Sutra', 'Moments Co.', 'Studio Noir', 'Light & Shadow'],
    specializations: ['Wedding & Events', 'Concert Specialist', 'Corporate Events', 'Influencer Shoots', 'Portrait & Lifestyle'],
    equipment: ['Canon R5', 'Sony A7 IV', 'Pro Lighting Kit', 'Reflectors', 'Tripod Rig'],
    services: ['Event Photography', 'Concert Photography', 'Wedding Photography', 'Corporate Events', 'Influencer Events'],
    details: [
      VendorDetailGroup(label: 'Camera Models', items: ['Sony A7 IV', 'Canon R6 Mark II', 'Nikon Z9', 'Fujifilm X-T5']),
      VendorDetailGroup(label: 'Lenses', items: ['24-70mm f/2.8', '70-200mm f/2.8', '50mm f/1.2', '16-35mm f/4']),
      VendorDetailGroup(label: 'Photography Styles', items: ['Candid', 'Cinematic', 'Photojournalistic', 'Editorial']),
      VendorDetailGroup(label: 'Editing Services', items: ['Color Grading', 'Retouching', 'Album Design', 'Online Gallery']),
    ],
    bio: 'Award-winning event photographer with a passion for capturing authentic, cinematic moments.',
  ),
  'videographer': Catalogue(
    brandNames: ['Cinema Crew', 'Reel Factory', 'Motion Lab', 'Frame Films', 'Story Reels', 'Visual Wave'],
    specializations: ['Cinematic Weddings', 'Concert Films', 'Brand Films', 'Documentary Style'],
    equipment: ['Sony FX6', 'Canon C70', 'DJI Ronin', 'Wireless Mics', 'Pro Lights'],
    services: ['Event Coverage', 'Highlight Reels', 'Live Multi-cam', 'Promo Videos', 'Social Edits'],
    details: [
      VendorDetailGroup(label: 'Video Equipment', items: ['Sony FX6', 'Canon C70', 'DJI Ronin Gimbal', 'Atomos Ninja V']),
      VendorDetailGroup(label: 'Drone Support', items: ['DJI Inspire 3', 'DJI Mavic 3 Pro', '4K Aerial Coverage']),
      VendorDetailGroup(label: 'Cinematic Packages', items: ['Highlight Reel', 'Full Film', 'Multi-cam Edit']),
      VendorDetailGroup(label: 'Reel Creation', items: ['Instagram Reels', 'YouTube Shorts', 'Social Cuts']),
      VendorDetailGroup(label: 'Delivery Timeline', items: ['24h Teaser', '7 day Reels', '21 day Full Film']),
    ],
    bio: 'Cinematic event videographer creating films that feel alive long after the event ends.',
  ),
  'dj': Catalogue(
    brandNames: ['DJ Nova', 'Bass Theory', 'Sound Sutra', 'NightWave', 'Beatworks', 'Pulse DJ Co.'],
    specializations: ['House & Techno', 'Bollywood Mix', 'Hip-Hop & RnB', 'Weddings', 'Festivals'],
    equipment: ['Pioneer CDJ-3000', 'DJM-900 Mixer', 'RCF Speakers', 'Subwoofer Stack'],
    services: ['Club Nights', 'Wedding Sangeet', 'Corporate Parties', 'Festival Sets'],
    details: [
      VendorDetailGroup(label: 'Music Genres', items: ['EDM', 'Bollywood', 'Punjabi', 'Hip-Hop', 'House', 'Techno']),
      VendorDetailGroup(label: 'Sound Setup', items: ['Pioneer CDJ-3000', 'DJM-900 Mixer', 'RCF Line Array', 'Subwoofer Stack']),
      VendorDetailGroup(label: 'Lighting Equipment', items: ['Moving Heads', 'Laser Show', 'Strobe', 'Smoke Machine']),
      VendorDetailGroup(label: 'Performance Duration', items: ['2 Hour Set', '4 Hour Set', 'Full Night']),
    ],
    bio: 'Open-format DJ with a high-energy library spanning every dance floor.',
  ),
};

const _defaultCatalogue = Catalogue(
  brandNames: ['ProVendor Co.', 'Eventra Partner', 'Trusted Crew', 'PremierWorks', 'EliteCrew'],
  specializations: ['Events', 'Concerts', 'Weddings', 'Corporate'],
  equipment: ['Pro-grade Gear', 'Backup Equipment', 'Custom Tools'],
  services: ['On-site Service', 'Consultation', 'Custom Packages', 'After-event Support'],
  details: [
    VendorDetailGroup(label: 'Highlights', items: ['Verified Vendor', 'Insured Crew', 'On-time Delivery']),
    VendorDetailGroup(label: 'Packages', items: ['Basic', 'Standard', 'Premium']),
  ],
  bio: 'Trusted event service provider with a strong track record across India.',
);

T _pick<T>(List<T> arr, int i) => arr[i % arr.length];

List<Vendor> getVendorsForService(String serviceId, int basePrice, [ServiceProviderProfile? currentProfile]) {
  final cat = _catalogues[serviceId] ?? _defaultCatalogue;
  final count = cat.brandNames.length;
  final List<Vendor> vendors = [];
  
  for (int i = 0; i < count; i++) {
    final generatedId = '$serviceId-${i + 1}';
    
    // Default generated data
    String name = cat.brandNames[i];
    String city = _pick(CITIES, i + serviceId.length);
    String spec = _pick(cat.specializations, i);
    double rating = double.parse((4.5 + ((i * 7) % 5) / 10).toStringAsFixed(1));
    int reviews = 40 + ((i * 53) % 220);
    int experience = 2 + ((i * 3) % 12);
    double priceFactor = 0.7 + (i % 5) * 0.18;
    int startingPrice = ((basePrice * priceFactor) / 100).round() * 100;
    String availability = i % 5 == 0 ? 'Busy' : i % 7 == 0 ? 'On Leave' : 'Available';
    String bio = cat.bio;
    List<String> equipment = cat.equipment;
    List<String> servicesOffered = cat.services;
    
    // Inject current user profile data if IDs match
    if (currentProfile != null && currentProfile.registered && currentProfile.vendorId == generatedId) {
      name = currentProfile.businessName.isNotEmpty ? currentProfile.businessName : name;
      city = currentProfile.city.isNotEmpty ? currentProfile.city : city;
      experience = currentProfile.experienceYears > 0 ? currentProfile.experienceYears : experience;
      startingPrice = currentProfile.startingPrice > 0 ? currentProfile.startingPrice : startingPrice;
      availability = currentProfile.availability;
      bio = currentProfile.bio.isNotEmpty ? currentProfile.bio : bio;
      if (currentProfile.equipment.isNotEmpty) equipment = currentProfile.equipment;
      if (currentProfile.servicesOffered.isNotEmpty) servicesOffered = currentProfile.servicesOffered;
    }
    
    vendors.add(Vendor(
      id: generatedId,
      serviceId: serviceId,
      name: name,
      rating: rating,
      reviews: reviews,
      experienceYears: experience,
      city: city,
      specialization: spec,
      startingPrice: startingPrice,
      availability: availability,
      bio: bio,
      equipment: equipment,
      servicesOffered: servicesOffered,
      details: cat.details,
      portfolio: List.generate(6, (k) => 'https://picsum.photos/seed/$generatedId-$k/400/400'),
      packages: [
        VendorPackage(name: 'Basic', price: startingPrice, features: ['4 hour coverage', 'Standard delivery', 'Single resource']),
        VendorPackage(name: 'Standard', price: (startingPrice * 1.6).round(), features: ['Full day coverage', 'Edited deliverables', 'Two resources']),
        VendorPackage(name: 'Premium', price: (startingPrice * 2.4).round(), features: ['Multi-day coverage', 'Premium edits', 'Full crew', 'Priority support']),
      ],
      verified: i % 3 != 0,
      socialLinks: {
        'instagram': '@${name.replaceAll(' ', '').toLowerCase()}',
        'facebook': 'facebook.com/${name.replaceAll(' ', '').toLowerCase()}',
        'website': 'www.${name.replaceAll(' ', '').toLowerCase()}.com',
      },
    ));
  }
  return vendors;
}

Vendor? getVendor(String serviceId, String vendorId, int basePrice, [ServiceProviderProfile? currentProfile]) {
  try {
    return getVendorsForService(serviceId, basePrice, currentProfile).firstWhere((v) => v.id == vendorId);
  } catch (e) {
    return null;
  }
}
