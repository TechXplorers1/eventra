import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import 'dart:math';

class _Faq {
  final String q;
  final String a;
  const _Faq(this.q, this.a);
}

const _faqs = [
  _Faq('How do I cancel my booking?', 'You can cancel your booking up to 24 hours before the event from the Tickets screen. Go to Tickets → Select your booking → Tap "Cancel Booking". Refunds are processed within 5–7 business days.'),
  _Faq('When will I receive my refund?', 'Refunds are processed to your original payment method within 5–7 business days for cards and 1–2 days for UPI. Eventra Wallet refunds are instant.'),
  _Faq('Can I transfer my ticket to someone else?', 'Yes! You can transfer tickets to another Eventra user. Go to Tickets → Select ticket → Tap "Transfer" → Enter the recipient\'s phone number.'),
  _Faq('Why is my QR code not scanning?', 'Ensure your screen brightness is at maximum. Try refreshing the ticket page. If the problem persists, show your booking confirmation email to the event staff.'),
  _Faq('How do I change my seat after booking?', 'Seat changes are subject to availability and event policy. Contact our support team with your booking ID and we\'ll do our best to accommodate the change.'),
  _Faq('How do I become an event organizer?', 'Switch to Organizer Mode from your Profile screen. You\'ll need to complete KYC verification and agree to our organizer terms. Approval takes 24–48 hours.'),
];

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  int? _openFaq;
  String _search = '';

  void _showTicketModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _TicketModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _faqs.where((f) => f.q.toLowerCase().contains(_search.toLowerCase()) || f.a.toLowerCase().contains(_search.toLowerCase())).toList();

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
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Help & Support', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              Text("We're here to help", style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Hero Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('24/7 Support Available', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 2),
                        Text('Average response time: 2 hours', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                      ],
                    ),
                  ),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact Us', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildActionItem(LucideIcons.messageCircle, 'Live Chat', 'Instant', Colors.blue.shade400),
                            const SizedBox(width: 12),
                            _buildActionItem(LucideIcons.phone, 'Call Us', '10am–8pm', Colors.green.shade400),
                            const SizedBox(width: 12),
                            _buildActionItem(LucideIcons.mail, 'Email', '24 hours', Colors.orange.shade400),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Raise Ticket
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: InkWell(
                      onTap: _showTicketModal,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                        child: Row(
                          children: [
                            Container(
                              width: 40, height: 40,
                              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                              child: Icon(LucideIcons.fileText, size: 18, color: AppColors.primaryForeground),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Raise a Support Ticket', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  Text('Track your issues & get updates', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ),
                            Icon(LucideIcons.chevronRight, size: 16, color: AppColors.mutedForeground),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // FAQ Search
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Frequently Asked Questions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 12),
                        TextField(
                          onChanged: (v) => setState(() => _search = v),
                          style: TextStyle(color: AppColors.foreground, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Search FAQs...',
                            hintStyle: TextStyle(color: AppColors.mutedForeground),
                            filled: true,
                            fillColor: AppColors.input,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // FAQ Accordion
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                      child: filtered.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(32),
                              child: Center(
                                child: Column(
                                  children: [
                                    Text('No FAQs found for "$_search"', style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
                                    const SizedBox(height: 8),
                                    TextButton(
                                      onPressed: _showTicketModal,
                                      child: Text('Raise a ticket instead →', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Column(
                              children: List.generate(filtered.length, (i) {
                                final faq = filtered[i];
                                final isOpen = _openFaq == i;
                                return Container(
                                  decoration: BoxDecoration(border: i < filtered.length - 1 ? Border(bottom: BorderSide(color: AppColors.border)) : null),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      InkWell(
                                        onTap: () => setState(() => _openFaq = isOpen ? null : i),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Row(
                                            children: [
                                              Expanded(child: Text(faq.q, style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500))),
                                              Icon(isOpen ? LucideIcons.chevronUp : LucideIcons.chevronDown, size: 16, color: AppColors.mutedForeground),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isOpen)
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                          child: Text(faq.a, style: TextStyle(color: AppColors.mutedForeground, fontSize: 14, height: 1.5)),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Center(
                    child: Text('Eventra v2.4.1 · Made with ❤️ in India', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
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

  Widget _buildActionItem(IconData icon, String label, String sub, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
          child: Column(
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 8),
              Text(label, style: TextStyle(color: AppColors.foreground, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(sub, style: TextStyle(color: AppColors.mutedForeground, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TicketModal extends StatefulWidget {
  const _TicketModal();

  @override
  State<_TicketModal> createState() => _TicketModalState();
}

class _TicketModalState extends State<_TicketModal> {
  String _subject = '';
  String _category = '';
  String _desc = '';
  Map<String, String> _errors = {};
  bool _submitted = false;
  final _categories = ['Booking Issue', 'Payment Problem', 'Ticket Not Received', 'App Bug', 'Refund Request', 'Other'];

  bool _validate() {
    final e = <String, String>{};
    if (_subject.trim().isEmpty) e['subject'] = 'Subject is required';
    if (_category.isEmpty) e['category'] = 'Please select a category';
    if (_desc.length < 20) e['desc'] = 'Please describe the issue in at least 20 characters';
    setState(() => _errors = e);
    return e.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Raise a Ticket', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                IconButton(icon: Icon(LucideIcons.x, size: 16, color: AppColors.mutedForeground), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 24),
            if (_submitted)
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), shape: BoxShape.circle),
                      child: const Icon(LucideIcons.check, size: 32, color: Colors.green),
                    ),
                    const SizedBox(height: 16),
                    Text('Ticket Raised!', style: TextStyle(color: AppColors.foreground, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text("Your ticket #EVT${Random().nextInt(90000) + 10000} has been submitted. We'll respond within 24 hours.", textAlign: TextAlign.center, style: TextStyle(color: AppColors.mutedForeground, fontSize: 14)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                        child: const Text('Done', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: (v) => setState(() => _subject = v),
                    style: TextStyle(color: AppColors.foreground, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Subject',
                      hintStyle: TextStyle(color: AppColors.mutedForeground),
                      filled: true,
                      fillColor: AppColors.input,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errors.containsKey('subject') ? AppColors.destructive : AppColors.border)),
                    ),
                  ),
                  if (_errors.containsKey('subject')) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_errors['subject']!, style: TextStyle(color: AppColors.destructive, fontSize: 12))),
                  const SizedBox(height: 16),

                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _categories.map((cat) {
                      final active = _category == cat;
                      return InkWell(
                        onTap: () => setState(() => _category = cat),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : AppColors.muted,
                            border: Border.all(color: active ? AppColors.primary : AppColors.border),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(cat, style: TextStyle(color: active ? AppColors.primaryForeground : AppColors.mutedForeground, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      );
                    }).toList(),
                  ),
                  if (_errors.containsKey('category')) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_errors['category']!, style: TextStyle(color: AppColors.destructive, fontSize: 12))),
                  const SizedBox(height: 16),

                  TextField(
                    onChanged: (v) => setState(() => _desc = v),
                    maxLines: 5,
                    style: TextStyle(color: AppColors.foreground, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Describe your issue in detail...',
                      hintStyle: TextStyle(color: AppColors.mutedForeground),
                      filled: true,
                      fillColor: AppColors.input,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: _errors.containsKey('desc') ? AppColors.destructive : AppColors.border)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _errors.containsKey('desc') ? Text(_errors['desc']!, style: TextStyle(color: AppColors.destructive, fontSize: 12)) : const SizedBox(),
                      Text('${_desc.length}/500', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_validate()) setState(() => _submitted = true);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.send, size: 16, color: Colors.white),
                          const SizedBox(width: 8),
                          const Text('Submit Ticket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
