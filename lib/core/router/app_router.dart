import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/role_select_screen.dart';
import '../../features/organizer/presentation/pages/organizer_onboarding_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_onboarding_screen.dart';
import '../../features/attendee/presentation/pages/home_screen.dart';
import '../../features/attendee/presentation/pages/explore_screen.dart';
import '../../features/attendee/presentation/pages/tickets_screen.dart';
import '../../features/attendee/presentation/pages/profile_screen.dart';
import '../../features/attendee/presentation/pages/search_screen.dart';
import '../../features/attendee/presentation/pages/event_details_screen.dart';
import '../../features/attendee/presentation/pages/order_summary_screen.dart';
import '../../features/attendee/presentation/pages/payment_screen.dart';
import '../../features/attendee/presentation/pages/booking_success_screen.dart';
import '../../features/attendee/presentation/pages/services_marketplace_screen.dart';
import '../../features/attendee/presentation/pages/service_vendors_screen.dart';
import '../../features/attendee/presentation/pages/vendor_profile_screen.dart';
import '../../features/attendee/presentation/pages/service_booking_screen.dart';
import '../../features/organizer/presentation/pages/organizer_dashboard_screen.dart';
import '../../features/organizer/presentation/pages/organizer_events_screen.dart';
import '../../features/organizer/presentation/pages/organizer_wallet_screen.dart';
import '../../features/organizer/presentation/pages/organizer_profile_screen.dart';
import '../../features/organizer/presentation/pages/organizer_create_event_screen.dart';
import '../../features/organizer/presentation/pages/organizer_verification_screen.dart';
import '../../features/organizer/presentation/pages/organizer_scan_screen.dart';
import '../../features/organizer/presentation/pages/organizer_event_detail_screen.dart';
import '../../features/organizer/presentation/pages/organizer_services_screen.dart';
import '../../features/organizer/presentation/pages/organizer_service_requests_screen.dart';
import '../../features/organizer/presentation/pages/organizer_invite_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_dashboard_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_requests_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_calendar_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_wallet_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_profile_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_portfolio_edit_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_packages_screen.dart';
import '../../features/service_provider/presentation/pages/service_provider_reviews_screen.dart';
import '../../features/shared/presentation/pages/notifications_screen.dart';
import '../../features/shared/presentation/pages/payment_methods_screen.dart';
import '../../features/shared/presentation/pages/help_support_screen.dart';
import '../../features/shared/presentation/pages/settings_screen.dart';
import '../providers/app_provider.dart';
import '../models/app_models.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final appState = ref.watch(appProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = appState.isLoggedIn;
      final role = appState.role;
      final path = state.uri.toString();

      if (!isLoggedIn && path != '/login' && path != '/') return '/login';

      if (isLoggedIn) {
        if (role == null && path != '/role-select') return '/role-select';

        if (path == '/login' || path == '/') {
          if (role == Role.attendee) return '/home';
          if (role == Role.organizer) {
            return appState.organizer.registered ? '/organizer' : '/organizer/onboarding';
          }
          if (role == Role.service) {
            return appState.serviceProvider.registered ? '/service-provider' : '/service-provider/onboarding';
          }
        }

        if (role == Role.organizer && !appState.organizer.registered &&
            !path.startsWith('/organizer/onboarding')) return '/organizer/onboarding';
        if (role == Role.service && !appState.serviceProvider.registered &&
            !path.startsWith('/service-provider/onboarding')) return '/service-provider/onboarding';
      }
      return null;
    },
    routes: [

      // ── Auth ─────────────────────────────────────────────────────────────
      GoRoute(path: '/',            builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',       builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/role-select', builder: (_, __) => const RoleSelectScreen()),
      GoRoute(path: '/organizer/onboarding',       builder: (_, __) => const OrganizerOnboardingScreen()),
      GoRoute(path: '/service-provider/onboarding',builder: (_, __) => const ServiceProviderOnboardingScreen()),

      // ── Attendee ─────────────────────────────────────────────────────────
      GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/explore', builder: (_, __) => const ExploreScreen()),
      GoRoute(path: '/search',  builder: (_, __) => const SearchScreen()),
      GoRoute(path: '/tickets', builder: (_, __) => const TicketsScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),

      GoRoute(path: '/event/:id',
          builder: (_, s) => EventDetailsScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/order-summary',
          builder: (_, s) => OrderSummaryScreen(bookingData: s.extra as Map<String, dynamic>)),
      GoRoute(path: '/payment',
          builder: (_, s) => PaymentScreen(bookingData: s.extra as Map<String, dynamic>)),
      GoRoute(path: '/booking-success',
          builder: (_, s) => BookingSuccessScreen(bookingData: s.extra as Map<String, dynamic>)),

      // Services marketplace
      GoRoute(path: '/services',
          builder: (_, __) => const ServicesMarketplaceScreen()),
      GoRoute(path: '/services/:id',
          builder: (_, s) => ServiceVendorsScreen(id: s.pathParameters['id']!)),
      GoRoute(path: '/services/:id/vendor/:vendorId',
          builder: (_, s) => VendorProfileScreen(
              serviceId: s.pathParameters['id']!, vendorId: s.pathParameters['vendorId']!)),
      GoRoute(path: '/services/:id/vendor/:vendorId/book',
          builder: (_, s) => ServiceBookingScreen(
              serviceId: s.pathParameters['id']!, vendorId: s.pathParameters['vendorId']!)),

      // ── Organizer ─────────────────────────────────────────────────────────
      GoRoute(path: '/organizer',          builder: (_, __) => const OrganizerDashboardScreen()),
      GoRoute(path: '/organizer/events',   builder: (_, __) => const OrganizerEventsScreen()),
      GoRoute(path: '/organizer/create',   builder: (_, __) => const OrganizerCreateEventScreen()),
      GoRoute(path: '/organizer/scan',     builder: (_, __) => const OrganizerScanScreen()),
      GoRoute(path: '/organizer/wallet',   builder: (_, __) => const OrganizerWalletScreen()),
      GoRoute(path: '/organizer/profile',  builder: (_, __) => const OrganizerProfileScreen()),
      GoRoute(path: '/organizer/verification', builder: (_, __) => const OrganizerVerificationScreen()),

      GoRoute(path: '/organizer/event/:id',
          builder: (_, s) => OrganizerEventDetailScreen(eventId: s.pathParameters['id']!)),
      GoRoute(path: '/organizer/invite/:eventId',
          builder: (_, s) => OrganizerInviteScreen(
            eventId: s.pathParameters['eventId']!,
            eventTitle: s.uri.queryParameters['title'] ?? 'Event',
          )),

      // Organizer Services (Browse + Requests in one screen with tabs)
      GoRoute(path: '/organizer/services',
          builder: (_, __) => const OrganizerServicesScreen()),
      GoRoute(path: '/organizer/services/requests',
          builder: (_, __) => const OrganizerServiceRequestsScreen()),

      // ── Service Provider ─────────────────────────────────────────────────
      GoRoute(path: '/service-provider',            builder: (_, __) => const ServiceProviderDashboardScreen()),
      GoRoute(path: '/service-provider/requests',   builder: (_, __) => const ServiceProviderRequestsScreen()),
      GoRoute(path: '/service-provider/calendar',   builder: (_, __) => const ServiceProviderCalendarScreen()),
      GoRoute(path: '/service-provider/wallet',     builder: (_, __) => const ServiceProviderWalletScreen()),
      GoRoute(path: '/service-provider/profile',    builder: (_, __) => const ServiceProviderProfileScreen()),
      GoRoute(path: '/service-provider/portfolio',  builder: (_, __) => const ServiceProviderPortfolioEditScreen()),
      GoRoute(path: '/service-provider/packages',   builder: (_, __) => const ServiceProviderPackagesScreen()),
      GoRoute(path: '/service-provider/reviews',    builder: (_, __) => const ServiceProviderReviewsScreen()),

      // ── Shared ───────────────────────────────────────────────────────────
      GoRoute(path: '/notifications',    builder: (_, __) => const NotificationsScreen()),
      GoRoute(path: '/payment-methods',  builder: (_, __) => const PaymentMethodsScreen()),
      GoRoute(path: '/help',             builder: (_, __) => const HelpSupportScreen()),
      GoRoute(path: '/settings',         builder: (_, __) => const SettingsScreen()),

      // Legacy redirects (keep for any existing navigation calls)
      GoRoute(path: '/help-support', redirect: (_, __) => '/help'),
      GoRoute(path: '/app-settings', redirect: (_, __) => '/profile'),
      GoRoute(path: '/preferences',  redirect: (_, __) => '/profile'),
      GoRoute(path: '/privacy-security', redirect: (_, __) => '/profile'),
      GoRoute(path: '/saved',        redirect: (_, __) => '/tickets'),
      GoRoute(path: '/all-events',   redirect: (_, __) => '/explore'),
      GoRoute(path: '/category/:category', redirect: (_, s) => '/explore'),
      GoRoute(path: '/banquet-halls', redirect: (_, __) => '/services'),
      GoRoute(path: '/banquet-halls/:id', redirect: (_, s) => '/services'),
      GoRoute(path: '/seats/:id', redirect: (_, s) => '/event/${s.pathParameters['id']}'),

      // Organizer legacy vendor screens — redirect to services
      GoRoute(path: '/organizer/services/providers/:id', redirect: (_, s) => '/organizer/services'),
      GoRoute(path: '/organizer/services/vendor/:categoryId/:providerId',
          redirect: (_, s) => '/organizer/services'),
    ],
  );
});
