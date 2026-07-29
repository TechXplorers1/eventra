import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_models.dart';
import '../data/mock_data.dart';
import '../data/seed_data.dart';

class AppState {
  final bool isLoggedIn;
  final Role? role;
  final String mobile;
  final String selectedCity;
  final List<String> savedEventIds;
  final List<String> savedVendorIds;
  final List<BookedTicket> bookedTickets;
  final List<ServiceBooking> serviceBookings;
  final List<ServiceRequest> serviceRequests;
  final List<EventData> publishedEvents;
  final List<AppNotification> notifications;
  final List<WalletTransaction> organizerTransactions;
  final List<WalletTransaction> spTransactions;
  final double organizerWalletBalance;
  final double spWalletBalance;
  final bool hideBottomNav;
  final OrganizerProfile organizer;
  final ServiceProviderProfile serviceProvider;
  // V1 — Invitation system
  final List<EventInvite> invitations;
  // Calendar blocking
  final List<String> blockedDates;        // 'yyyy-MM-dd'
  final List<CalendarEntry> calendarEntries;

  AppState({
    required this.isLoggedIn,
    this.role,
    this.mobile = '',
    this.selectedCity = 'Mumbai',
    this.savedEventIds = const [],
    this.savedVendorIds = const [],
    this.bookedTickets = const [],
    this.serviceBookings = const [],
    this.serviceRequests = const [],
    this.publishedEvents = const [],
    this.notifications = const [],
    this.organizerTransactions = const [],
    this.spTransactions = const [],
    this.organizerWalletBalance = 0.0,
    this.spWalletBalance = 0.0,
    this.hideBottomNav = false,
    required this.organizer,
    required this.serviceProvider,
    this.invitations = const [],
    this.blockedDates = const [],
    this.calendarEntries = const [],
  });

  AppState copyWith({
    bool? isLoggedIn,
    Role? role,
    String? mobile,
    String? selectedCity,
    List<String>? savedEventIds,
    List<String>? savedVendorIds,
    List<BookedTicket>? bookedTickets,
    List<ServiceBooking>? serviceBookings,
    List<ServiceRequest>? serviceRequests,
    List<EventData>? publishedEvents,
    List<AppNotification>? notifications,
    List<WalletTransaction>? organizerTransactions,
    List<WalletTransaction>? spTransactions,
    double? organizerWalletBalance,
    double? spWalletBalance,
    bool? hideBottomNav,
    OrganizerProfile? organizer,
    ServiceProviderProfile? serviceProvider,
    bool clearRole = false,
    List<EventInvite>? invitations,
    List<String>? blockedDates,
    List<CalendarEntry>? calendarEntries,
  }) {
    return AppState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      role: clearRole ? null : (role ?? this.role),
      mobile: mobile ?? this.mobile,
      selectedCity: selectedCity ?? this.selectedCity,
      savedEventIds: savedEventIds ?? this.savedEventIds,
      savedVendorIds: savedVendorIds ?? this.savedVendorIds,
      bookedTickets: bookedTickets ?? this.bookedTickets,
      serviceBookings: serviceBookings ?? this.serviceBookings,
      serviceRequests: serviceRequests ?? this.serviceRequests,
      publishedEvents: publishedEvents ?? this.publishedEvents,
      notifications: notifications ?? this.notifications,
      organizerTransactions: organizerTransactions ?? this.organizerTransactions,
      spTransactions: spTransactions ?? this.spTransactions,
      organizerWalletBalance: organizerWalletBalance ?? this.organizerWalletBalance,
      spWalletBalance: spWalletBalance ?? this.spWalletBalance,
      hideBottomNav: hideBottomNav ?? this.hideBottomNav,
      organizer: organizer ?? this.organizer,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      invitations: invitations ?? this.invitations,
      blockedDates: blockedDates ?? this.blockedDates,
      calendarEntries: calendarEntries ?? this.calendarEntries,
    );
  }

  // Convenience: all public events visible to attendees
  List<EventData> get allEvents => [
        ...mockEvents,
        ...publishedEvents.where((e) => e.visibility == 'public'),
      ];

  // All events (public + private) — for organizer views
  List<EventData> get allEventsUnfiltered => [...mockEvents, ...publishedEvents];

  // Unread notification count
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  // Pending invitation count
  int get pendingInviteCount => invitations.where((i) => i.status == 'pending').length;

  List<String> get savedVendors => savedVendorIds;
}

class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState(
      isLoggedIn: false,
      organizer: OrganizerProfile.empty(),
      serviceProvider: ServiceProviderProfile.empty(),
      // Pre-seeded collections so every screen is populated from first launch
      bookedTickets: seededBookedTickets,
      serviceBookings: seededServiceBookings,
      serviceRequests: seededServiceRequests,
      publishedEvents: seededPublishedEvents,
      notifications: seededNotifications,
      organizerTransactions: seededOrganizerTransactions,
      spTransactions: seededSPTransactions,
      organizerWalletBalance: seededOrganizerBalance,
      spWalletBalance: seededSPBalance,
      invitations: seededInvitations,
    );
  }

  // ─── Auth ────────────────────────────────────────────────────────────────────
  void login() => state = state.copyWith(isLoggedIn: true);

  void logout() => state = state.copyWith(
        isLoggedIn: false,
        clearRole: true,
        organizer: OrganizerProfile.empty(),
        serviceProvider: ServiceProviderProfile.empty(),
      );

  void setRole(Role role) => state = state.copyWith(role: role);

  void setMobile(String mobile) => state = state.copyWith(mobile: mobile);

  // ─── City ────────────────────────────────────────────────────────────────────
  void setCity(String city) => state = state.copyWith(selectedCity: city);

  // ─── Events ──────────────────────────────────────────────────────────────────
  void publishEvent(EventData event) {
    state = state.copyWith(
      publishedEvents: [...state.publishedEvents, event],
      notifications: [
        AppNotification(
          id: 'N${DateTime.now().millisecondsSinceEpoch}',
          title: event.visibility == 'private' ? 'Private Event Created' : 'Event Published',
          body: event.visibility == 'private'
              ? '${event.title} is ready. Send invites to attendees.'
              : '${event.title} is now live for booking.',
          type: 'system',
          time: 'Just now',
          isRead: false,
        ),
        ...state.notifications,
      ],
    );
  }

  // ─── Invitations ─────────────────────────────────────────────────────────────
  /// Organizer sends invitation(s) for a private event
  void sendInvite(EventInvite invite) {
    state = state.copyWith(
      invitations: [...state.invitations, invite],
      notifications: [
        AppNotification(
          id: 'N${DateTime.now().millisecondsSinceEpoch}',
          title: 'Invitation Sent',
          body: 'Invite sent to ${invite.contact} for ${invite.eventTitle}.',
          type: 'invite',
          time: 'Just now',
          isRead: false,
        ),
        ...state.notifications,
      ],
    );
  }

  /// Attendee accepts or declines an invitation
  void respondToInvite(String inviteId, String status) {
    final updated = state.invitations.map((i) {
      if (i.id == inviteId) return i.copyWith(status: status);
      return i;
    }).toList();

    // If accepted, add a notification
    final invite = state.invitations.firstWhere((i) => i.id == inviteId);
    state = state.copyWith(
      invitations: updated,
      notifications: [
        AppNotification(
          id: 'N${DateTime.now().millisecondsSinceEpoch}',
          title: status == 'accepted' ? 'Invitation Accepted' : 'Invitation Declined',
          body: status == 'accepted'
              ? 'You\'re attending ${invite.eventTitle} on ${invite.eventDate}.'
              : 'You declined the invite to ${invite.eventTitle}.',
          type: 'invite',
          time: 'Just now',
          isRead: false,
        ),
        ...state.notifications,
      ],
    );
  }

  // ─── Saved ───────────────────────────────────────────────────────────────────
  void toggleSavedEvent(String id) {
    if (state.savedEventIds.contains(id)) {
      state = state.copyWith(
          savedEventIds: state.savedEventIds.where((e) => e != id).toList());
    } else {
      state = state.copyWith(savedEventIds: [...state.savedEventIds, id]);
    }
  }

  bool isSaved(String id) => state.savedEventIds.contains(id);

  void toggleSaveVendor(String id) {
    if (state.savedVendorIds.contains(id)) {
      state = state.copyWith(
          savedVendorIds:
              state.savedVendorIds.where((e) => e != id).toList());
    } else {
      state = state.copyWith(savedVendorIds: [...state.savedVendorIds, id]);
    }
  }

  bool isSavedVendor(String id) => state.savedVendorIds.contains(id);

  // ─── Bookings ────────────────────────────────────────────────────────────────
  void addBooking(BookedTicket ticket) {
    final credit = WalletTransaction(
      id: 'OT${DateTime.now().millisecondsSinceEpoch}',
      label: '${ticket.eventTitle} Ticket Sale',
      type: 'credit',
      amount: ticket.totalPrice,
      date: 'Today',
    );
    state = state.copyWith(
      bookedTickets: [...state.bookedTickets, ticket],
      organizerTransactions: [credit, ...state.organizerTransactions],
      organizerWalletBalance: state.organizerWalletBalance + ticket.totalPrice,
      notifications: [
        AppNotification(
          id: 'N${DateTime.now().millisecondsSinceEpoch}',
          title: 'Booking Confirmed',
          body:
              'Your ${ticket.eventTitle} ticket (${ticket.ticketType}) is confirmed.',
          type: 'booking',
          time: 'Just now',
          isRead: false,
        ),
        ...state.notifications,
      ],
    );
  }

  void addServiceBooking(ServiceBooking booking) {
    state = state.copyWith(
        serviceBookings: [...state.serviceBookings, booking]);
  }

  // ─── Service Requests ────────────────────────────────────────────────────────
  void addServiceRequest(ServiceRequest request) {
    state = state.copyWith(
        serviceRequests: [...state.serviceRequests, request]);
  }

  void removeServiceRequest(String id) {
    state = state.copyWith(
        serviceRequests:
            state.serviceRequests.where((r) => r.id != id).toList());
  }

  void updateServiceRequestStatus(String id, String status) {
    state = state.copyWith(
      serviceRequests: state.serviceRequests.map((r) => r.id == id ? r.copyWith(status: status) : r).toList(),
    );
  }

  /// SP accepts a booking request — updates request status and credits SP wallet
  void acceptServiceRequest(String id, String vendorName, double price) {
    final updated = state.serviceRequests.map((r) {
      if (r.id == id) {
        return r.copyWith(
          status: 'Confirmed',
          vendorId: state.serviceProvider.vendorId,
          vendorName: vendorName,
          vendorPrice: price,
        );
      }
      return r;
    }).toList();
    final credit = WalletTransaction(
      id: 'ST${DateTime.now().millisecondsSinceEpoch}',
      label: 'Booking Confirmed — ${state.serviceProvider.categoryOrFallback}',
      type: 'credit',
      amount: price,
      date: 'Today',
    );
    state = state.copyWith(
      serviceRequests: updated,
      spTransactions: [credit, ...state.spTransactions],
      spWalletBalance: state.spWalletBalance + price,
      notifications: [
        AppNotification(
          id: 'N${DateTime.now().millisecondsSinceEpoch}',
          title: 'Booking Accepted',
          body: 'You confirmed a booking for ₹${price.toInt()}.',
          type: 'quote',
          time: 'Just now',
          isRead: false,
        ),
        ...state.notifications,
      ],
    );
  }

  /// SP declines a request
  void declineServiceRequest(String id) {
    final updated = state.serviceRequests.map((r) {
      if (r.id == id) return r.copyWith(status: 'Cancelled');
      return r;
    }).toList();
    state = state.copyWith(serviceRequests: updated);
  }

  // ─── Calendar ──────────────────────────────────────────────────────────────────────────
  void toggleBlockDate(String dateKey) {
    final current = List<String>.from(state.blockedDates);
    if (current.contains(dateKey)) {
      current.remove(dateKey);
    } else {
      current.add(dateKey);
    }
    state = state.copyWith(blockedDates: current);
  }

  void addCalendarEntry(CalendarEntry entry) {
    state = state.copyWith(
      calendarEntries: [...state.calendarEntries, entry],
    );
  }

  void removeCalendarEntry(String id) {
    state = state.copyWith(
      calendarEntries: state.calendarEntries.where((e) => e.id != id).toList(),
    );
  }

  // ─── Profiles ────────────────────────────────────────────────────────────────
  void registerOrganizer(OrganizerProfile profile) {
    state = state.copyWith(
      organizer: OrganizerProfile(
        registered: true,
        status: 'unverified',
        fullName: profile.fullName,
        orgName: profile.orgName,
        type: profile.type,
        city: profile.city,
        state: profile.state,
        rating: '4.9',
        eventsHosted: 12,
        totalTicketsSold: 4800,
        totalRevenue: 820000.0,
      ),
      role: Role.organizer,
    );
  }

  void registerServiceProvider(ServiceProviderProfile profile) {
    state = state.copyWith(
      serviceProvider: ServiceProviderProfile(
        registered: true,
        status: 'unverified',
        fullName: profile.fullName,
        businessName: profile.businessName,
        vendorId: profile.vendorId.isNotEmpty ? profile.vendorId : 'v1',
        serviceCategory: profile.serviceCategory,
        rating: '4.8',
        totalGigs: 24,
        totalRevenue: 182000.0,
      ),
      role: Role.service,
    );
  }

  void updateServiceProviderProfile(ServiceProviderProfile profile) {
    state = state.copyWith(serviceProvider: profile);
  }

  void updateOrganizerStatus(String status) {
    state = state.copyWith(organizer: state.organizer.copyWith(status: status));
  }

  // ─── Wallet ──────────────────────────────────────────────────────────────────
  void requestOrganizerPayout(double amount) {
    final tx = WalletTransaction(
      id: 'OT${DateTime.now().millisecondsSinceEpoch}',
      label: 'Payout to Bank',
      type: 'debit',
      amount: amount,
      date: 'Today',
    );
    state = state.copyWith(
      organizerTransactions: [tx, ...state.organizerTransactions],
      organizerWalletBalance: state.organizerWalletBalance - amount,
    );
  }

  void requestSPWithdrawal(double amount) {
    final tx = WalletTransaction(
      id: 'ST${DateTime.now().millisecondsSinceEpoch}',
      label: 'Withdrawal to Bank',
      type: 'debit',
      amount: amount,
      date: 'Today',
    );
    final fee = WalletTransaction(
      id: 'ST${DateTime.now().millisecondsSinceEpoch + 1}',
      label: 'Platform Fee',
      type: 'debit',
      amount: (amount * 0.02).roundToDouble(),
      date: 'Today',
    );
    state = state.copyWith(
      spTransactions: [fee, tx, ...state.spTransactions],
      spWalletBalance: state.spWalletBalance - amount - (amount * 0.02),
    );
  }

  // ─── Notifications ───────────────────────────────────────────────────────────
  void markNotificationRead(String id) {
    final updated = state.notifications
        .map((n) => n.id == id ? n.copyWith(isRead: true) : n)
        .toList();
    state = state.copyWith(notifications: updated);
  }

  void markAllNotificationsRead() {
    final updated =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  List<String> get savedVendors => state.savedVendorIds;
}

// ─── Extension helpers ───────────────────────────────────────────────────────
extension SPProfileX on ServiceProviderProfile {
  String get categoryOrFallback =>
      serviceCategory.isNotEmpty ? serviceCategory : 'Service';
}

final appProvider = NotifierProvider<AppNotifier, AppState>(() {
  return AppNotifier();
});
