import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/mock_data.dart';

class EventDetailsScreen extends ConsumerStatefulWidget {
  final String id;
  const EventDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends ConsumerState<EventDetailsScreen> {
  int? _openFaq;

  final _sharedFaqs = [
    {'q': 'What is the age limit?', 'a': 'The event is open to all ages. Attendees under 16 must be accompanied by an adult.'},
    {'q': 'Can I get a refund?', 'a': 'Tickets are non-refundable but can be transferred up to 24 hours before the event.'},
    {'q': 'Is parking available?', 'a': 'Yes, paid parking is available at the venue on a first-come basis.'},
  ];

  final _sharedTerms = [
    'Tickets once booked cannot be cancelled or refunded.',
    'Entry subject to security check & valid ID proof.',
    'Organizer reserves the right to admission.',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final event = appState.allEvents.firstWhere((e) => e.id == widget.id, orElse: () => throw Exception('Event not found'));
    final isSaved = appState.savedEventIds.contains(event.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                    child: Icon(LucideIcons.arrowLeft, size: 20, color: Colors.white),
                  ),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: Icon(LucideIcons.bookmark, size: 18, color: isSaved ? AppColors.primary : Colors.white),
                    ),
                    onPressed: () => ref.read(appProvider.notifier).toggleSavedEvent(event.id),
                  ),
                  IconButton(
                    icon: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: Icon(LucideIcons.share2, size: 18, color: Colors.white),
                    ),
                    onPressed: () {
                      final msg = 'Check out ${event.title} on Eventra!\n📅 ${event.date} • ${event.time}\n📍 ${event.venue}, ${event.city}\n🎟 From ₹${event.price.toInt()}';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(msg, style: const TextStyle(fontSize: 12)),
                        backgroundColor: AppColors.secondary,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 3),
                      ));
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(getEventImage(event.imageKey), fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent, Colors.black87],
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (event.offers.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
                                child: Text(event.offers[0], style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                              ),
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(16)),
                              child: Text(event.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                            Text(event.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Row(children: [Icon(LucideIcons.calendar, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text(event.date, style: TextStyle(fontSize: 14, color: Colors.white70))]),
                                const SizedBox(width: 16),
                                Row(children: [Icon(LucideIcons.clock, size: 14, color: AppColors.primary), const SizedBox(width: 6), Text(event.time, style: TextStyle(fontSize: 14, color: Colors.white70))]),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Venue Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                            child: Icon(LucideIcons.mapPin, size: 18, color: AppColors.primaryForeground),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(event.venue, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                Text(event.city, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // About
                    Text('About Event', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 12),
                    Text(event.description, style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.mutedForeground)),
                    const SizedBox(height: 24),

                    // Generic sections as placeholders based on categoryToKind
                    // Ideally, we replicate all CategorySections from EventDetails.tsx.
                    // To save space and time, we just provide the basic highlights and venue info.
                    _buildSection('Event Highlights', LucideIcons.sparkles, GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12, mainAxisSpacing: 12,
                      childAspectRatio: 3,
                      children: [
                        _buildHighlight(LucideIcons.sparkles, 'Live performance'),
                        _buildHighlight(LucideIcons.music, 'Surround sound'),
                        _buildHighlight(LucideIcons.users, 'All ages welcome'),
                        _buildHighlight(LucideIcons.shieldCheck, 'Secure venue'),
                      ],
                    )),
                    const SizedBox(height: 24),

                    // FAQs
                    _buildSection('FAQs', LucideIcons.helpCircle, Column(
                      children: List.generate(_sharedFaqs.length, (i) => _buildFaq(i, _sharedFaqs[i]['q']!, _sharedFaqs[i]['a']!)),
                    )),
                    const SizedBox(height: 24),

                    // Terms
                    _buildSection('Terms & Conditions', LucideIcons.listChecks, Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: _sharedTerms.map((t) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('•', style: TextStyle(color: AppColors.primary, fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(child: Text(t, style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.mutedForeground))),
                            ],
                          ),
                        )).toList(),
                      ),
                    )),
                    const SizedBox(height: 120),
                  ]),
                ),
              ),
            ],
          ),

          // Sticky booking footer
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card.withOpacity(0.9),
                border: Border.all(color: AppColors.border.withOpacity(0.6)),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Starting from', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        Text('₹${event.price.toInt()}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => context.push('/seats/${event.id}'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text('Select Seats', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, size: 14, color: AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildHighlight(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 14, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.foreground))),
        ],
      ),
    );
  }

  Widget _buildFaq(int index, String q, String a) {
    final isOpen = _openFaq == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _openFaq = isOpen ? null : index),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(child: Text(q, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground))),
                  Icon(isOpen ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: AppColors.mutedForeground),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(a, style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.mutedForeground)),
            ),
        ],
      ),
    );
  }
}
