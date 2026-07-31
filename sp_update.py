import os

filepath = r'd:\company-work\eventra\lib\features\service_provider\presentation\pages\service_provider_requests_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace _buildRequestCard
old_build_request_card = """  Widget _buildRequestCard(ServiceRequest req, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(req.categoryName, style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  req.status,
                  style: TextStyle(
                    color: isPending ? Colors.orange : Colors.green,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(LucideIcons.calendar, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Expanded(child: Text(
                req.eventName.isNotEmpty ? '${req.eventName} • ${req.eventDate}' : 'Coming up soon',
                style: TextStyle(color: AppColors.foreground, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(LucideIcons.mapPin, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 8),
              Expanded(child: Text(
                req.eventVenue.isNotEmpty ? req.eventVenue : 'Location TBD',
                style: TextStyle(color: AppColors.foreground, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              )),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(LucideIcons.indianRupee, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Budget: ₹${req.budget.toInt()}', style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
          if (isPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showQuoteDialog(context, req),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Submit Quote', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
              ),
            ),
          ],
        ],
      ),
    );
  }"""

new_build_request_card = """  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.foreground, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildRequestCard(ServiceRequest req, bool isPending) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPending ? AppColors.border : AppColors.primary, width: isPending ? 1 : 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(req.categoryName, style: TextStyle(color: AppColors.foreground, fontSize: 16, fontWeight: FontWeight.bold))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending ? AppColors.warning.withAlpha(25) : AppColors.success.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        req.status,
                        style: TextStyle(
                          color: isPending ? AppColors.warning : AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(req.eventName.isNotEmpty ? req.eventName : 'Event Details TBD', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _badge(LucideIcons.calendar, req.eventDate.isNotEmpty ? req.eventDate : 'TBD'),
                    _badge(LucideIcons.mapPin, req.eventVenue.isNotEmpty ? req.eventVenue : 'Location TBD'),
                    _badge(LucideIcons.indianRupee, 'Budget: ₹${req.budget.toInt()}'),
                  ],
                ),
              ],
            ),
          ),
          if (isPending)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(top: BorderSide(color: AppColors.border)),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: ElevatedButton(
                onPressed: () => _showQuoteDialog(context, req),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  minimumSize: const Size(double.infinity, 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Submit Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.primaryForeground)),
              ),
            ),
        ],
      ),
    );
  }"""

if old_build_request_card in content:
    content = content.replace(old_build_request_card, new_build_request_card)
else:
    print("Could not find old_build_request_card in service_provider_requests_screen.dart")

# Replace _showQuoteDialog for a better design
old_show_quote_dialog = """  void _showQuoteDialog(BuildContext context, ServiceRequest req) {
    final priceCtrl = TextEditingController(text: req.budget.toInt().toString());
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Send Quote', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 4),
            Text('${req.categoryName} • Client budget: ₹${req.budget.toInt()}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
            if (req.eventDate.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(children: [
                Icon(LucideIcons.calendarOff, size: 13, color: const Color(0xFFEF4444)),
                const SizedBox(width: 6),
                Text('${req.eventDate} will be auto-blocked in your calendar',
                    style: const TextStyle(fontSize: 11, color: Color(0xFFEF4444))),
              ]),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.foreground, fontSize: 24, fontWeight: FontWeight.bold),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: AppColors.primary, fontSize: 24, fontWeight: FontWeight.bold),
                filled: true,
                fillColor: AppColors.secondary,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                hintText: 'Your price',
                hintStyle: TextStyle(color: AppColors.mutedForeground),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceCtrl.text) ?? req.budget;
                  final notifier = ref.read(appProvider.notifier);
                  notifier.acceptServiceRequest(
                    req.id,
                    ref.read(appProvider).serviceProvider.businessName,
                    price,
                  );
                  // Auto-block the event date on calendar
                  if (req.eventDate.isNotEmpty) {
                    try {
                      // eventDate may be 'MMM dd, yyyy' or 'yyyy-MM-dd' — normalise to key
                      final dateKey = _normaliseDateKey(req.eventDate);
                      if (dateKey != null &&
                          !ref.read(appProvider).blockedDates.contains(dateKey)) {
                        notifier.toggleBlockDate(dateKey);
                      }
                    } catch (_) {}
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Quote of ₹${price.toInt()} submitted! Date blocked in calendar.'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Submit Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryForeground)),
              ),
            ),
          ],
        ),
      ),
    );
  }"""

new_show_quote_dialog = """  void _showQuoteDialog(BuildContext context, ServiceRequest req) {
    final priceCtrl = TextEditingController(text: req.budget.toInt().toString());
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 24, 20, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Send Quote', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                GestureDetector(onTap: () => Navigator.pop(context), child: Icon(LucideIcons.x, color: AppColors.mutedForeground)),
              ],
            ),
            const SizedBox(height: 8),
            Text('Client is requesting ${req.categoryName} for their event. The suggested budget is ₹${req.budget.toInt()}.', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5)),
            
            if (req.eventDate.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.warning.withAlpha(20), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.warning.withAlpha(50))),
                child: Row(children: [
                  Icon(LucideIcons.calendarOff, size: 16, color: AppColors.warning),
                  const SizedBox(width: 8),
                  Expanded(child: Text('${req.eventDate} will be auto-blocked in your calendar upon submission.', style: TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600))),
                ]),
              ),
            ],
            
            const SizedBox(height: 24),
            Text('Your Price (₹)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
            const SizedBox(height: 8),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppColors.foreground, fontSize: 28, fontWeight: FontWeight.w800),
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: TextStyle(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w800),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.border)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.primary, width: 2)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final price = double.tryParse(priceCtrl.text) ?? req.budget;
                  final notifier = ref.read(appProvider.notifier);
                  notifier.acceptServiceRequest(
                    req.id,
                    ref.read(appProvider).serviceProvider.businessName,
                    price,
                  );
                  // Auto-block the event date on calendar
                  if (req.eventDate.isNotEmpty) {
                    try {
                      final dateKey = _normaliseDateKey(req.eventDate);
                      if (dateKey != null &&
                          !ref.read(appProvider).blockedDates.contains(dateKey)) {
                        notifier.toggleBlockDate(dateKey);
                      }
                    } catch (_) {}
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Quote of ₹${price.toInt()} submitted!'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Confirm Quote', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryForeground)),
              ),
            ),
          ],
        ),
      ),
    );
  }"""

if old_show_quote_dialog in content:
    content = content.replace(old_show_quote_dialog, new_show_quote_dialog)
else:
    print("Could not find old_show_quote_dialog in service_provider_requests_screen.dart")

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated service_provider_requests_screen.dart")
