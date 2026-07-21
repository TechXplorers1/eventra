import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

class OrganizerInviteScreen extends ConsumerStatefulWidget {
  final String eventId;
  final String eventTitle;

  const OrganizerInviteScreen({
    super.key,
    required this.eventId,
    required this.eventTitle,
  });

  @override
  ConsumerState<OrganizerInviteScreen> createState() => _OrganizerInviteScreenState();
}

class _OrganizerInviteScreenState extends ConsumerState<OrganizerInviteScreen> {
  final List<TextEditingController> _controllers = [TextEditingController()];
  bool _isSending = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addField() {
    if (_controllers.length >= 10) return;
    setState(() => _controllers.add(TextEditingController()));
  }

  void _removeField(int index) {
    if (_controllers.length == 1) return;
    _controllers[index].dispose();
    setState(() => _controllers.removeAt(index));
  }

  Future<void> _sendInvitations() async {
    final contacts = _controllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter at least one contact.'),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isSending = true);

    // Simulate brief delay for realism
    await Future.delayed(const Duration(milliseconds: 600));

    final organizer = ref.read(appProvider).organizer;

    for (int i = 0; i < contacts.length; i++) {
      final invite = EventInvite(
        id: 'INV${DateTime.now().millisecondsSinceEpoch}$i',
        eventId: widget.eventId,
        eventTitle: widget.eventTitle,
        eventDate: 'Upcoming',
        eventVenue: 'See event details',
        organizerName: organizer.orgName.isNotEmpty ? organizer.orgName : organizer.fullName,
        contact: contacts[i],
        status: 'pending',
        sentAt: 'Just now',
        eventImageKey: 'nightlife',
      );
      ref.read(appProvider.notifier).sendInvite(invite);
    }

    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${contacts.length} invitation${contacts.length > 1 ? 's' : ''} sent successfully!',
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentInvites = ref.watch(appProvider).invitations
        .where((i) => i.eventId == widget.eventId)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
            child: Icon(LucideIcons.arrowLeft, size: 18, color: AppColors.foreground),
          ),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Invite Attendees', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            Text(widget.eventTitle, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Info Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.info, size: 16, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is a private event. Only invited attendees will be able to see and attend it.',
                    style: TextStyle(fontSize: 12, color: AppColors.foreground, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Enter Phone Numbers or Emails', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 4),
          Text('Add up to 10 contacts at a time', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          const SizedBox(height: 16),

          // Contact Fields
          ...List.generate(_controllers.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _controllers[i],
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: AppColors.foreground, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'e.g. +91 98765 43210 or email@example.com',
                        hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(LucideIcons.user, size: 16, color: AppColors.mutedForeground),
                        ),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  if (_controllers.length > 1) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _removeField(i),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                        child: Icon(LucideIcons.x, size: 16, color: Colors.red),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),

          // Add another
          if (_controllers.length < 10)
            InkWell(
              onTap: _addField,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Add Another Contact', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 28),

          // Send Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendInvitations,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSending
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryForeground)),
                        const SizedBox(width: 10),
                        const Text('Sending...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.send, size: 16, color: AppColors.primaryForeground),
                        const SizedBox(width: 8),
                        const Text('Send Invitations', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ],
                    ),
            ),
          ),

          // Already Sent Section
          if (sentInvites.isNotEmpty) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                Text('Already Invited', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: Text('${sentInvites.length}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...sentInvites.map((invite) {
              Color statusColor;
              String statusLabel;
              switch (invite.status) {
                case 'accepted': statusColor = Colors.green; statusLabel = 'Accepted'; break;
                case 'declined': statusColor = Colors.red; statusLabel = 'Declined'; break;
                default: statusColor = Colors.orange; statusLabel = 'Pending';
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(LucideIcons.user, size: 16, color: AppColors.mutedForeground),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(invite.contact, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                          Text('Sent ${invite.sentAt}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                      child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
