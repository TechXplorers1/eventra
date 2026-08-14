import os

filepath = r'd:\company-work\eventra\lib\features\service_provider\presentation\pages\service_provider_dashboard_screen.dart'
with open(filepath, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace _RequestCard to match the modern look
old_request_card = """class _RequestCard extends StatelessWidget {
  final ServiceRequest req;
  const _RequestCard({required this.req});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/service-provider/requests'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(LucideIcons.briefcase, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(req.categoryName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground)),
            const SizedBox(height: 2),
            Text('Budget: ₹${req.budget.toInt()}  •  ${req.eventDate.isNotEmpty ? req.eventDate : "TBD"}',
                style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          ])),
          EvStatusBadge(req.status.toLowerCase()),
        ]),
      ),
    );
  }
}"""

new_request_card = """class _RequestCard extends StatelessWidget {
  final ServiceRequest req;
  const _RequestCard({required this.req});

  Widget _badge(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(6)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: AppColors.mutedForeground),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.foreground, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/service-provider/requests'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(req.categoryName, style: TextStyle(color: AppColors.foreground, fontSize: 15, fontWeight: FontWeight.bold))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: req.status == 'Quote Requested' ? AppColors.warning.withAlpha(25) : AppColors.success.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      req.status,
                      style: TextStyle(
                        color: req.status == 'Quote Requested' ? AppColors.warning : AppColors.success,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(req.eventName.isNotEmpty ? req.eventName : 'Event Details TBD', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _badge(LucideIcons.calendar, req.eventDate.isNotEmpty ? req.eventDate : 'TBD'),
                  _badge(LucideIcons.indianRupee, 'Budget: ₹${req.budget.toInt()}'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}"""

if old_request_card in content:
    content = content.replace(old_request_card, new_request_card)
else:
    print("Could not find old_request_card")


with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated dashboard")
