import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class _ProviderReview {
  final String id;
  final String customer;
  final int rating;
  final String comment;
  final String eventType;
  final String packageName;
  final String eventDate;
  final int helpful;
  final String? reply;

  _ProviderReview({
    required this.id,
    required this.customer,
    required this.rating,
    required this.comment,
    required this.eventType,
    required this.packageName,
    required this.eventDate,
    required this.helpful,
    this.reply,
  });

  _ProviderReview copyWith({
    String? id,
    String? customer,
    int? rating,
    String? comment,
    String? eventType,
    String? packageName,
    String? eventDate,
    int? helpful,
    String? reply,
  }) {
    return _ProviderReview(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      eventType: eventType ?? this.eventType,
      packageName: packageName ?? this.packageName,
      eventDate: eventDate ?? this.eventDate,
      helpful: helpful ?? this.helpful,
      reply: reply ?? this.reply,
    );
  }
}

class ServiceProviderReviewsScreen extends ConsumerStatefulWidget {
  const ServiceProviderReviewsScreen({super.key});

  @override
  ConsumerState<ServiceProviderReviewsScreen> createState() => _ServiceProviderReviewsScreenState();
}

class _ServiceProviderReviewsScreenState extends ConsumerState<ServiceProviderReviewsScreen> {
  final _positives = ['Professional', 'On Time', 'Great Quality', 'Friendly Service'];
  final _improvements = ['Communication', 'Response Time'];
  
  List<_ProviderReview> _items = [
    _ProviderReview(
      id: 'rev-1',
      customer: 'Rahul Verma',
      rating: 5,
      comment: 'Absolutely brilliant service. The photos came out amazing and the team was very professional and on time.',
      eventType: 'Wedding',
      packageName: 'Premium',
      eventDate: 'Oct 12, 2023',
      helpful: 12,
    ),
    _ProviderReview(
      id: 'rev-2',
      customer: 'Priya Sharma',
      rating: 4,
      comment: 'Good experience overall. The pictures were great, but the delivery took a bit longer than expected.',
      eventType: 'Corporate Event',
      packageName: 'Standard',
      eventDate: 'Sep 28, 2023',
      helpful: 5,
    ),
    _ProviderReview(
      id: 'rev-3',
      customer: 'Amit Patel',
      rating: 5,
      comment: 'Highly recommended! Captured every special moment perfectly.',
      eventType: 'Birthday Party',
      packageName: 'Basic',
      eventDate: 'Sep 15, 2023',
      helpful: 8,
      reply: 'Thank you Amit! It was a pleasure working with you.',
    ),
  ];

  dynamic _filter = 'all'; // 'all' or int (1-5)
  String _sort = 'recent'; // 'recent', 'high', 'low'

  void _showReplyModal(_ProviderReview review) {
    String replyText = review.reply ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: BoxDecoration(color: AppColors.background, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Reply to ${review.customer}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(LucideIcons.x, size: 16, color: AppColors.foreground),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: TextEditingController(text: replyText)..selection = TextSelection.collapsed(offset: replyText.length),
                onChanged: (v) => replyText = v,
                maxLines: 4,
                style: TextStyle(color: AppColors.foreground, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Thank the customer or address their feedback...',
                  hintStyle: TextStyle(color: AppColors.mutedForeground),
                  filled: true,
                  fillColor: AppColors.input,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('Cancel', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (replyText.trim().isNotEmpty) {
                          setState(() {
                            final idx = _items.indexWhere((r) => r.id == review.id);
                            if (idx != -1) {
                              _items[idx] = _items[idx].copyWith(reply: replyText.trim());
                            }
                          });
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text('Submit Reply', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double avg = _items.isEmpty ? 0.0 : _items.fold(0, (s, r) => s + r.rating) / _items.length;
    List<Map<String, dynamic>> breakdown = [5, 4, 3, 2, 1].map((n) => {
      'n': n,
      'count': _items.where((r) => r.rating == n).length,
    }).toList();

    List<_ProviderReview> filtered = _items.where((r) => _filter == 'all' || r.rating == _filter).toList();
    if (_sort == 'high') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_sort == 'low') {
      filtered.sort((a, b) => a.rating.compareTo(b.rating));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            child: Icon(LucideIcons.arrowLeft, size: 18, color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('SERVICE MODE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1.5)),
                              Text('Reviews & Ratings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _sort = _sort == 'recent' ? 'high' : _sort == 'high' ? 'low' : 'recent';
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            child: Icon(LucideIcons.arrowUpDown, size: 16, color: AppColors.foreground),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Rating overview
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Column(
                              children: [
                                Text(avg.toStringAsFixed(1), style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.foreground)),
                                Row(
                                  children: List.generate(5, (i) => Icon(LucideIcons.star, size: 12, color: i < avg.round() ? Colors.amber : AppColors.muted)),
                                ),
                                const SizedBox(height: 4),
                                Text('${_items.length} reviews', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: breakdown.map((b) {
                                  final pct = _items.isEmpty ? 0.0 : (b['count'] as int) / _items.length;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        Text('${b['n']}', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                        const SizedBox(width: 4),
                                        const Icon(LucideIcons.star, size: 9, color: Colors.amber),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Container(
                                            height: 6,
                                            decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(3)),
                                            child: FractionallySizedBox(
                                              alignment: Alignment.centerLeft,
                                              widthFactor: pct,
                                              child: Container(
                                                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(3)),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        SizedBox(width: 20, child: Text('${b['count']}', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground), textAlign: TextAlign.right)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Divider(color: AppColors.border),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildMini('Total Reviews', '${_items.length}')),
                            Expanded(child: _buildMini('Avg Rating', avg.toStringAsFixed(1))),
                            Expanded(child: _buildMini('Completed', '245')),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Service-specific metrics
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PERFORMANCE METRICS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildMetricCard('Quality of Work', '4.8')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMetricCard('Professionalism', '4.9')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: _buildMetricCard('Punctuality', '4.7')),
                            const SizedBox(width: 8),
                            Expanded(child: _buildMetricCard('Value for Money', '4.6')),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Insights
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('REVIEW INSIGHTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text('Most mentioned positives', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: _positives.map((p) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text('✓ $p', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.greenAccent)),
                          )).toList(),
                        ),
                        const SizedBox(height: 12),
                        Text('Areas for improvement', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: _improvements.map((p) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                            child: Text('⚠ $p', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.orangeAccent)),
                          )).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Filter chips
                  SizedBox(
                    height: 32,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(LucideIcons.slidersHorizontal, size: 14, color: AppColors.mutedForeground),
                        ),
                        ...['all', 5, 4, 3, 2, 1].map((f) {
                          final active = _filter == f;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setState(() => _filter = f),
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  gradient: active ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                                  color: active ? null : AppColors.secondary,
                                  border: Border.all(color: active ? Colors.transparent : AppColors.border),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.center,
                                child: Text(f == 'all' ? 'All' : '$f Star', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: active ? AppColors.primaryForeground : AppColors.mutedForeground)),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Reviews List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: filtered.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                            child: Column(
                              children: [
                                Icon(LucideIcons.star, size: 24, color: AppColors.mutedForeground),
                                const SizedBox(height: 8),
                                Text('No reviews yet', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                const SizedBox(height: 4),
                                Text('Complete bookings to start receiving customer reviews.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                              ],
                            ),
                          )
                        : Column(
                            children: filtered.map((r) => Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), shape: BoxShape.circle),
                                    alignment: Alignment.center,
                                    child: Text(r.customer.characters.first, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(r.customer, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                            Row(
                                              children: List.generate(5, (i) => Icon(LucideIcons.star, size: 11, color: i < r.rating ? Colors.amber : AppColors.muted)),
                                            ),
                                          ],
                                        ),
                                        Text('${r.eventType} · ${r.packageName} Package · ${r.eventDate}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                        const SizedBox(height: 8),
                                        Text(r.comment, style: TextStyle(fontSize: 12, color: AppColors.foreground)),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(LucideIcons.thumbsUp, size: 11, color: AppColors.mutedForeground),
                                                const SizedBox(width: 4),
                                                Text('Helpful: ${r.helpful}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                              ],
                                            ),
                                            InkWell(
                                              onTap: () => _showReplyModal(r),
                                              child: Row(
                                                children: [
                                                  Icon(LucideIcons.messageCircle, size: 11, color: AppColors.primary),
                                                  const SizedBox(width: 4),
                                                  Text(r.reply != null ? 'Edit Reply' : 'Reply', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (r.reply != null) ...[
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), border: Border(left: BorderSide(color: AppColors.primary, width: 2)), borderRadius: BorderRadius.circular(12)),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text('YOUR REPLY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
                                                const SizedBox(height: 4),
                                                Text(r.reply!, style: TextStyle(fontSize: 12, color: AppColors.foreground)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                  ),
                ],
              ),
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  Widget _buildMini(String label, String value) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.secondary, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              const SizedBox(width: 4),
              const Icon(LucideIcons.star, size: 11, color: Colors.amber),
            ],
          ),
        ],
      ),
    );
  }
}
