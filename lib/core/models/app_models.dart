enum Role { attendee, organizer, service }

// ─── Calendar Entry (custom note/block) ──────────────────────────────────────
class CalendarEntry {
  final String id;
  final String date; // 'yyyy-MM-dd'
  final String title;
  final String note;
  final String type; // 'event' | 'blocked'

  const CalendarEntry({
    required this.id,
    required this.date,
    required this.title,
    this.note = '',
    required this.type,
  });
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'booking' | 'reminder' | 'offer' | 'quote' | 'system' | 'invite'
  final String time;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      time: time,
      isRead: isRead ?? this.isRead,
    );
  }
}

class WalletTransaction {
  final String id;
  final String label;
  final String type; // 'credit' | 'debit'
  final double amount;
  final String date;

  const WalletTransaction({
    required this.id,
    required this.label,
    required this.type,
    required this.amount,
    required this.date,
  });
}

// ─── NEW: Ticket Tier ─────────────────────────────────────────────────────────
class TicketTier {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final int sold;

  const TicketTier({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.sold = 0,
  });

  TicketTier copyWith({int? sold}) {
    return TicketTier(
      id: id,
      name: name,
      price: price,
      quantity: quantity,
      sold: sold ?? this.sold,
    );
  }
}

// ─── NEW: Event Invite ────────────────────────────────────────────────────────
class EventInvite {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventDate;
  final String eventVenue;
  final String organizerName;
  final String contact; // phone or email
  final String status; // 'pending' | 'accepted' | 'declined'
  final String sentAt;
  final String eventImageKey;

  const EventInvite({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventVenue,
    required this.organizerName,
    required this.contact,
    this.status = 'pending',
    required this.sentAt,
    this.eventImageKey = 'concert',
  });

  EventInvite copyWith({String? status}) {
    return EventInvite(
      id: id,
      eventId: eventId,
      eventTitle: eventTitle,
      eventDate: eventDate,
      eventVenue: eventVenue,
      organizerName: organizerName,
      contact: contact,
      status: status ?? this.status,
      sentAt: sentAt,
      eventImageKey: eventImageKey,
    );
  }
}

// ─── NEW: Venue Data ──────────────────────────────────────────────────────────
class VenueData {
  final String id;
  final String name;
  final String address;
  final String city;
  final int capacity;
  final double pricePerDay;
  final double rating;
  final String imageUrl;
  final List<String> amenities;
  final String venueType;
  final String seatingLayout;
  final List<SeatSection> seatingLayouts;
  final String description;

  const VenueData({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.capacity,
    required this.pricePerDay,
    required this.rating,
    required this.imageUrl,
    this.amenities = const [],
    this.venueType = '',
    this.seatingLayout = '',
    this.seatingLayouts = const [],
    this.description = '',
  });
}

class BookedTicket {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventDate;
  final String eventTime;
  final String eventVenue;
  final String ticketType;
  final int quantity;
  final List<String> seats;
  final double totalPrice;
  final String qrCode;
  final String bookedAt;
  final String eventImageKey;

  BookedTicket({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventTime,
    required this.eventVenue,
    required this.ticketType,
    required this.quantity,
    required this.seats,
    required this.totalPrice,
    required this.qrCode,
    required this.bookedAt,
    required this.eventImageKey,
  });
}

class ServiceBooking {
  final String id;
  final String orderNumber;
  final String status;
  final String serviceId;
  final String vendorId;
  final String vendorName;
  final String vendorPhone;
  final String serviceName;
  final String packageName;
  final double servicePrice;
  final double platformFee;
  final double taxes;
  final double total;
  final String paymentMethod;
  final String bookedAt;
  final String eventName;
  final String eventType;
  final String eventDate;
  final String startTime;
  final String endTime;
  final String venueName;
  final String city;
  final int guests;
  final String specialRequirements;
  final String visibility;

  ServiceBooking({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.serviceId,
    this.vendorId = '',
    required this.vendorName,
    this.vendorPhone = '',
    required this.serviceName,
    required this.packageName,
    this.servicePrice = 0.0,
    this.platformFee = 0.0,
    this.taxes = 0.0,
    required this.total,
    this.paymentMethod = '',
    this.bookedAt = '',
    this.eventName = '',
    this.eventType = '',
    required this.eventDate,
    required this.startTime,
    this.endTime = '',
    required this.venueName,
    required this.city,
    this.guests = 0,
    this.specialRequirements = '',
    required this.visibility,
  });

  ServiceBooking copyWith({String? status}) {
    return ServiceBooking(
      id: id,
      orderNumber: orderNumber,
      status: status ?? this.status,
      serviceId: serviceId,
      vendorId: vendorId,
      vendorName: vendorName,
      vendorPhone: vendorPhone,
      serviceName: serviceName,
      packageName: packageName,
      servicePrice: servicePrice,
      platformFee: platformFee,
      taxes: taxes,
      total: total,
      paymentMethod: paymentMethod,
      bookedAt: bookedAt,
      eventName: eventName,
      eventType: eventType,
      eventDate: eventDate,
      startTime: startTime,
      endTime: endTime,
      venueName: venueName,
      city: city,
      guests: guests,
      specialRequirements: specialRequirements,
      visibility: visibility,
    );
  }
}

class ServiceRequest {
  final String id;
  final String categoryId;
  final String categoryName;
  final String status;
  final double budget;
  final int professionals;
  final String duration;
  final String notes;
  final int quotes;
  final DateTime createdAt;
  final String? vendorId;
  final String? vendorName;
  final String vendorPhone;
  final double? vendorPrice;
  final String eventId;
  final String eventName;
  final String eventDate;
  final String eventVenue;

  ServiceRequest({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.status,
    required this.budget,
    required this.professionals,
    required this.duration,
    required this.notes,
    required this.quotes,
    required this.createdAt,
    this.vendorId,
    this.vendorName,
    this.vendorPhone = '',
    this.vendorPrice,
    this.eventId = '',
    this.eventName = '',
    this.eventDate = '',
    this.eventVenue = '',
  });

  ServiceRequest copyWith({
    String? status,
    String? vendorId,
    String? vendorName,
    String? vendorPhone,
    double? vendorPrice,
    int? quotes,
  }) {
    return ServiceRequest(
      id: id,
      categoryId: categoryId,
      categoryName: categoryName,
      status: status ?? this.status,
      budget: budget,
      professionals: professionals,
      duration: duration,
      notes: notes,
      quotes: quotes ?? this.quotes,
      createdAt: createdAt,
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      vendorPhone: vendorPhone ?? this.vendorPhone,
      vendorPrice: vendorPrice ?? this.vendorPrice,
      eventId: eventId,
      eventName: eventName,
      eventDate: eventDate,
      eventVenue: eventVenue,
    );
  }
}

class OrganizerProfile {
  final bool registered;
  final String status;
  final String fullName;
  final String orgName;
  final String type;
  final String city;
  final String state;
  final String rating;
  final int eventsHosted;
  final int totalTicketsSold;
  final double totalRevenue;

  OrganizerProfile({
    required this.registered,
    required this.status,
    required this.fullName,
    required this.orgName,
    this.type = '',
    this.city = '',
    this.state = '',
    this.rating = '0.0',
    this.eventsHosted = 0,
    this.totalTicketsSold = 0,
    this.totalRevenue = 0.0,
  });

  factory OrganizerProfile.empty() => OrganizerProfile(
        registered: false,
        status: 'unverified',
        fullName: '',
        orgName: '',
      );

  OrganizerProfile copyWith({String? status}) {
    return OrganizerProfile(
      registered: registered,
      status: status ?? this.status,
      fullName: fullName,
      orgName: orgName,
      type: type,
      city: city,
      state: state,
      rating: rating,
      eventsHosted: eventsHosted,
      totalTicketsSold: totalTicketsSold,
      totalRevenue: totalRevenue,
    );
  }
}

class ServiceProviderProfile {
  final bool registered;
  final String status;
  final String fullName;
  final String businessName;
  final String vendorId;
  final String serviceCategory;
  final String rating;
  final int totalGigs;
  final double totalRevenue;
  
  // Portfolio fields
  final String bio;
  final int experienceYears;
  final String city;
  final int startingPrice;
  final List<String> equipment;
  final List<String> servicesOffered;
  final String availability; // 'Available' | 'Busy' | 'On Leave'
  final Map<String, String> socialLinks;

  // Venue-specific fields
  final int capacity;
  final String address;
  final List<String> amenities;
  final String venueType;
  final String seatingLayout;
  final List<SeatSection> seatingLayouts;

  // Caterer-specific
  final List<String> menuTypes;
  final int maxGuests;

  ServiceProviderProfile({
    required this.registered,
    required this.status,
    required this.fullName,
    required this.businessName,
    this.vendorId = '',
    this.serviceCategory = '',
    this.rating = '0.0',
    this.totalGigs = 0,
    this.totalRevenue = 0.0,
    this.bio = '',
    this.experienceYears = 0,
    this.city = '',
    this.startingPrice = 0,
    this.equipment = const [],
    this.servicesOffered = const [],
    this.availability = 'Available',
    this.socialLinks = const {},
    this.capacity = 0,
    this.address = '',
    this.amenities = const [],
    this.venueType = '',
    this.seatingLayout = '',
    this.seatingLayouts = const [],
    this.menuTypes = const [],
    this.maxGuests = 0,
  });

  factory ServiceProviderProfile.empty() => ServiceProviderProfile(
        registered: false,
        status: 'unverified',
        fullName: '',
        businessName: '',
      );

  ServiceProviderProfile copyWith({
    String? status,
    String? fullName,
    String? businessName,
    String? vendorId,
    String? serviceCategory,
    String? rating,
    int? totalGigs,
    double? totalRevenue,
    String? bio,
    int? experienceYears,
    String? city,
    int? startingPrice,
    List<String>? equipment,
    List<String>? servicesOffered,
    String? availability,
    Map<String, String>? socialLinks,
    int? capacity,
    String? address,
    List<String>? amenities,
    String? venueType,
    String? seatingLayout,
    List<SeatSection>? seatingLayouts,
    List<String>? menuTypes,
    int? maxGuests,
  }) {
    return ServiceProviderProfile(
      registered: registered,
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      businessName: businessName ?? this.businessName,
      vendorId: vendorId ?? this.vendorId,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      rating: rating ?? this.rating,
      totalGigs: totalGigs ?? this.totalGigs,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      bio: bio ?? this.bio,
      experienceYears: experienceYears ?? this.experienceYears,
      city: city ?? this.city,
      startingPrice: startingPrice ?? this.startingPrice,
      equipment: equipment ?? this.equipment,
      servicesOffered: servicesOffered ?? this.servicesOffered,
      availability: availability ?? this.availability,
      socialLinks: socialLinks ?? this.socialLinks,
      capacity: capacity ?? this.capacity,
      address: address ?? this.address,
      amenities: amenities ?? this.amenities,
      venueType: venueType ?? this.venueType,
      seatingLayout: seatingLayout ?? this.seatingLayout,
      seatingLayouts: seatingLayouts ?? this.seatingLayouts,
      menuTypes: menuTypes ?? this.menuTypes,
      maxGuests: maxGuests ?? this.maxGuests,
    );
  }
}

class SeatSection {
  final String id;
  final String name;
  final double price;
  final int colorHex;
  final int rows;
  final int seatsPerRow;
  final int available;
  final List<String> disabledSeats;

  const SeatSection({
    required this.id,
    required this.name,
    required this.price,
    required this.colorHex,
    required this.rows,
    required this.seatsPerRow,
    required this.available,
    this.disabledSeats = const [],
  });

  SeatSection copyWith({
    String? id,
    String? name,
    double? price,
    int? colorHex,
    int? rows,
    int? seatsPerRow,
    int? available,
    List<String>? disabledSeats,
  }) {
    return SeatSection(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      colorHex: colorHex ?? this.colorHex,
      rows: rows ?? this.rows,
      seatsPerRow: seatsPerRow ?? this.seatsPerRow,
      available: available ?? this.available,
      disabledSeats: disabledSeats ?? this.disabledSeats,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'colorHex': colorHex,
      'rows': rows,
      'seatsPerRow': seatsPerRow,
      'available': available,
      'disabledSeats': disabledSeats,
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
      disabledSeats: List<String>.from(json['disabledSeats'] ?? []),
    );
  }
}
