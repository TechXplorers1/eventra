import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/theme/app_colors.dart';

class EventDetailsScreen extends StatelessWidget {
  final String id;
  const EventDetailsScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // Direct mockEvents lookup — no provider/Riverpod (avoids rebuild collapse bug on Flutter Web)
    EventData? ev;
    for (final e in mockEvents) {
      if (e.id == id) { ev = e; break; }
    }

    if (ev == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: const Color(0xFF121214),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              Text('Event not found (id: $id)',
                style: const TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final categoryColor = AppColors.primary;

    return Scaffold(
      backgroundColor: const Color(0xFF09090B),
      body: CustomScrollView(
        slivers: [
          // ── Collapsing Hero ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF09090B),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Material(
                color: Colors.black38,
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              title: const SizedBox.shrink(), // title is in hero content below
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(categoryImages[ev.imageKey] ?? 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?auto=format&fit=crop&q=80'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withAlpha(50),
                        Colors.black.withAlpha(120),
                        const Color(0xFF09090B),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                  child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withAlpha(50)),
                        ),
                        child: Text(ev.category,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold,
                              letterSpacing: 1.2)),
                      ),
                      const SizedBox(height: 12),
                      Text(ev.title,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.w900,
                            color: Colors.white, height: 1.2)),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _headerChip(Icons.calendar_today_rounded, ev.date),
                          const SizedBox(width: 12),
                          _headerChip(Icons.access_time_rounded, ev.time),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _headerChip(Icons.location_on_rounded, '${ev.venue}, ${ev.city}'),
                    ],
                  ),
                ),
                ),
              ),
            ),
          ),

          // ── Offer Strip ────────────────────────────────────────────
          if (ev.offers.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                color: categoryColor.withAlpha(25),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: categoryColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('OFFER', style: TextStyle(fontSize: 10, color: categoryColor, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 10),
                    Text(ev.offers[0],
                      style: TextStyle(fontSize: 14, color: categoryColor, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

          // ── Pricing Quick Info ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF121214),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(10)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _statBox('Starting From', '₹${ev.price.toInt()}', categoryColor),
                  ),
                  _divider(),
                  Expanded(child: _statBox('Category', ev.category, Colors.white70)),
                  _divider(),
                  Expanded(child: _statBox('City', ev.city, Colors.white70)),
                ],
              ),
            ),
          ),

          // ── About ──────────────────────────────────────────────────
          SliverToBoxAdapter(child: _sectionCard(
            'About this Event',
            child: Text(ev.description,
              style: const TextStyle(fontSize: 14, color: Colors.white60, height: 1.7)),
          )),

          // ── Highlights Grid ────────────────────────────────────────
          SliverToBoxAdapter(child: _sectionCard(
            'Event Highlights',
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _highlightPill('🎵', 'Live Music', categoryColor),
                _highlightPill('👥', 'All Ages', categoryColor),
                _highlightPill('🔒', 'Secure Venue', categoryColor),
                _highlightPill('🔊', 'HD Sound', categoryColor),
                _highlightPill('🅿️', 'Parking', categoryColor),
                _highlightPill('🎟️', 'E-Tickets', categoryColor),
              ],
            ),
          )),

          // ── FAQs ───────────────────────────────────────────────────
          SliverToBoxAdapter(child: _sectionCard(
            'FAQs',
            child: Column(
              children: [
                _faqTile('What is the age limit?',
                  'Open to all ages. Attendees under 16 must be accompanied by an adult.'),
                _faqTile('Can I get a refund?',
                  'Tickets are non-refundable but can be transferred up to 24 hours before the event.'),
                _faqTile('Is parking available?',
                  'Yes, paid parking is available at the venue on a first-come, first-served basis.'),
                _faqTile('What should I carry?',
                  'Your e-ticket (QR code), a valid government-issued photo ID, and comfortable footwear.'),
              ],
            ),
          )),

          // ── Terms ──────────────────────────────────────────────────
          SliverToBoxAdapter(child: _sectionCard(
            'Terms & Conditions',
            child: Column(
              children: [
                _termRow(categoryColor, 'Tickets once booked cannot be cancelled or refunded.'),
                _termRow(categoryColor, 'Entry is subject to security check & valid ID proof.'),
                _termRow(categoryColor, 'Organizer reserves the right to refuse admission.'),
                _termRow(categoryColor, 'Outside food & beverages are not permitted inside the venue.'),
                _termRow(categoryColor, 'The event is subject to change at the organizer\'s discretion.'),
              ],
            ),
          )),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),

      // ── Sticky Book Button ─────────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF121214),
          border: Border(top: BorderSide(color: Colors.white.withAlpha(15))),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 20)],
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Starting from',
                  style: TextStyle(fontSize: 11, color: Colors.white38)),
                Text('₹${ev.price.toInt()}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: categoryColor)),
              ],
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => context.push('/seats/${ev!.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor, categoryColor.withAlpha(200)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: categoryColor.withAlpha(80), blurRadius: 12, offset: const Offset(0, 4))],
                ),
                child: const Text('Book Tickets',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static Color _categoryColor(String category) {
    return const {
      'Music':     Color(0xFF9B66E0),
      'Sports':    Color(0xFF059669),
      'Comedy':    Color(0xFFD97706),
      'Nightlife': Color(0xFF2563EB),
      'Arts':      Color(0xFFDB2777),
      'Wedding':   Color(0xFFDC2626),
      'Festival':  Color(0xFF9B66E0),
    }[category] ?? const Color(0xFF9B66E0);
  }

  static Widget _headerChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: Colors.white60),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70)),
      ],
    );
  }

  static Widget _statBox(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white38)),
        const SizedBox(height: 6),
        Text(value,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: valueColor)),
      ],
    );
  }

  static Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.white.withAlpha(12));
  }

  static Widget _sectionCard(String title, {required Widget child}) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF121214),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  static Widget _highlightPill(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: color.withAlpha(15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 15)),
          const SizedBox(width: 7),
          Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  static Widget _faqTile(String q, String a) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Q  ', style: TextStyle(fontSize: 12, color: Color(0xFF9B66E0), fontWeight: FontWeight.bold)),
              Expanded(child: Text(q,
                style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: Text(a, style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.5)),
          ),
        ],
      ),
    );
  }

  static Widget _termRow(Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6, height: 6,
            margin: const EdgeInsets.only(top: 5, right: 10),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(child: Text(text,
            style: const TextStyle(fontSize: 13, color: Colors.white54, height: 1.5))),
        ],
      ),
    );
  }
}
